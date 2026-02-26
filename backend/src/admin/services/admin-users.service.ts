import { Injectable, NotFoundException } from '@nestjs/common';
import { SupabaseService } from '@config/supabase.service';
import { QueryAdminUsersDto } from '../dto/query-admin-users.dto';
import { PatchUserRoleDto } from '../dto/patch-user-role.dto';

@Injectable()
export class AdminUsersService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async listUsers(dto: QueryAdminUsersDto) {
    const { page = 1, limit = 20, email } = dto;
    const offset = (page - 1) * limit;

    // Supabase Admin Auth에서 전체 사용자 목록 조회
    const { data: authData, error: authError } =
      await this.supabaseService.getAdminAuth().listUsers({
        page,
        perPage: limit,
      });

    if (authError) throw new Error(authError.message);

    // 이메일 필터링
    let users = authData.users;
    if (email) {
      const lowerEmail = email.toLowerCase();
      users = users.filter((u) =>
        u.email?.toLowerCase().includes(lowerEmail),
      );
    }

    const userIds = users.map((u) => u.id);

    // user_profile에서 role 조회
    const { data: profiles } = await this.supabaseService
      .getClient()
      .from('user_profile')
      .select('id, role, created_at')
      .in('id', userIds);

    const profileMap = new Map(
      (profiles ?? []).map((p: any) => [p.id, p]),
    );

    const result = users.map((u) => {
      const profile = profileMap.get(u.id) as any;
      return {
        id: u.id,
        email: u.email,
        created_at: u.created_at,
        last_sign_in_at: u.last_sign_in_at,
        role: profile?.role ?? 'user',
      };
    });

    return {
      data: result,
      pagination: {
        page,
        limit,
        total: authData.total ?? result.length,
      },
    };
  }

  async updateUserRole(userId: string, dto: PatchUserRoleDto) {
    // user_profile 존재 확인
    const { data: profile, error } = await this.supabaseService
      .getClient()
      .from('user_profile')
      .select('id')
      .eq('id', userId)
      .single();

    if (error || !profile) {
      throw new NotFoundException(`사용자를 찾을 수 없습니다: ${userId}`);
    }

    const { error: updateError } = await this.supabaseService
      .getClient()
      .from('user_profile')
      .update({ role: dto.role })
      .eq('id', userId);

    if (updateError) throw new Error(updateError.message);

    return { id: userId, role: dto.role };
  }
}
