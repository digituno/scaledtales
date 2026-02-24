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

    return {
      id: data.user.id,
      email: data.user.email,
      created_at: data.user.created_at,
    };
  }
}
