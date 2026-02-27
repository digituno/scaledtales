import { Injectable, NotFoundException } from '@nestjs/common';
import { SupabaseService } from '@config/supabase.service';
import { QueryAdminUsersDto } from '../dto/query-admin-users.dto';
import { PatchUserRoleDto } from '../dto/patch-user-role.dto';

@Injectable()
export class AdminUsersService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async listUsers(dto: QueryAdminUsersDto) {
    const { page = 1, limit = 20, email } = dto;

    // 이메일 검색 시: Supabase Admin Auth API는 서버사이드 이메일 필터를 지원하지
    // 않으므로, 전체 사용자를 한 번에 가져온 뒤 in-memory 필터링 후 페이지네이션.
    // 이메일 없는 일반 목록: 페이지 단위로 가져와 DB join.
    if (email) {
      return this.listUsersWithEmailSearch(email, page, limit);
    }

    // 일반 페이지네이션 (이메일 검색 없음)
    const { data: authData, error: authError } = await this.supabaseService
      .getAdminAuth()
      .listUsers({
        page,
        perPage: limit,
      });

    if (authError) throw new Error(authError.message);

    return this.buildResult(
      authData.users,
      page,
      limit,
      (authData as any).total ?? 0,
    );
  }

  /** 이메일 검색: 전체 사용자 fetch 후 in-memory 필터 + 페이지네이션 */
  private async listUsersWithEmailSearch(
    email: string,
    page: number,
    limit: number,
  ) {
    // Supabase Admin Auth listUsers 최대 perPage = 1000
    const PER_PAGE = 1000;
    let allUsers: any[] = [];
    let currentPage = 1;
    let hasMore = true;

    while (hasMore) {
      const { data, error } = await this.supabaseService
        .getAdminAuth()
        .listUsers({ page: currentPage, perPage: PER_PAGE });

      if (error) throw new Error(error.message);

      allUsers = allUsers.concat(data.users);

      // 마지막 페이지 판단: 받은 수가 perPage보다 적으면 끝
      hasMore = data.users.length === PER_PAGE;
      currentPage++;
    }

    // in-memory 이메일 필터
    const lowerEmail = email.toLowerCase();
    const filtered = allUsers.filter((u) =>
      u.email?.toLowerCase().includes(lowerEmail),
    );

    // 페이지네이션 적용
    const total = filtered.length;
    const start = (page - 1) * limit;
    const paged = filtered.slice(start, start + limit);

    return this.buildResult(paged, page, limit, total);
  }

  /** Auth users → user_profile role 조인 후 응답 객체 생성 */
  private async buildResult(
    users: any[],
    page: number,
    limit: number,
    total: number,
  ) {
    const userIds = users.map((u) => u.id);

    const { data: profiles } = userIds.length
      ? await this.supabaseService
          .getClient()
          .from('user_profile')
          .select('id, role')
          .in('id', userIds)
      : { data: [] };

    const profileMap = new Map((profiles ?? []).map((p: any) => [p.id, p]));

    const result = users.map((u) => {
      const profile = profileMap.get(u.id);
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
      pagination: { page, limit, total },
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
