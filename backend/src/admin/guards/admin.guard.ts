import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';
import { SupabaseService } from '@config/supabase.service';

@Injectable()
export class AdminGuard implements CanActivate {
  constructor(private readonly supabaseService: SupabaseService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const user = request.user; // JwtAuthGuard 가 설정한 user 객체

    if (!user?.id) {
      throw new ForbiddenException('관리자 권한이 필요합니다');
    }

    const { data } = await this.supabaseService
      .getClient()
      .from('user_profile')
      .select('role')
      .eq('id', user.id)
      .single();

    if (data?.role !== 'admin') {
      throw new ForbiddenException('관리자 권한이 필요합니다');
    }

    return true;
  }
}
