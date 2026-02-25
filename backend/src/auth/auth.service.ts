import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../config/supabase.service';

@Injectable()
export class AuthService {
  constructor(private supabaseService: SupabaseService) {}

  async getUserById(userId: string) {
    const { data, error } = await this.supabaseService
      .getAdminAuth()
      .getUserById(userId);

    if (error) {
      throw error;
    }

    const { data: profileData } = await this.supabaseService
      .getClient()
      .from('user_profile')
      .select('role')
      .eq('id', userId)
      .single();

    const role = profileData?.role ?? 'user';

    return {
      id: data.user.id,
      email: data.user.email,
      role,
      created_at: data.user.created_at,
    };
  }
}
