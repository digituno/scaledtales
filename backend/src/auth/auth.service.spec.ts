import { Test, TestingModule } from '@nestjs/testing';
import { AuthService } from './auth.service';
import { SupabaseService } from '../config/supabase.service';

describe('AuthService', () => {
  let service: AuthService;
  let mockGetUserById: jest.Mock;

  beforeEach(async () => {
    mockGetUserById = jest.fn();

    const mockSupabaseService = {
      getAdminAuth: jest.fn().mockReturnValue({
        getUserById: mockGetUserById,
      }),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: SupabaseService, useValue: mockSupabaseService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  // ── getUserById ──

  describe('getUserById', () => {
    it('존재하는 userId → { id, email, created_at } 반환', async () => {
      const mockUser = {
        id: 'user-uuid-1',
        email: 'test@example.com',
        created_at: '2024-01-01T00:00:00Z',
      };
      mockGetUserById.mockResolvedValue({
        data: { user: mockUser },
        error: null,
      });

      const result = await service.getUserById('user-uuid-1');

      expect(result).toEqual({
        id: 'user-uuid-1',
        email: 'test@example.com',
        created_at: '2024-01-01T00:00:00Z',
      });
    });

    it('올바른 userId로 Supabase Admin Auth 호출', async () => {
      const mockUser = {
        id: 'user-uuid-1',
        email: 'test@example.com',
        created_at: '2024-01-01T00:00:00Z',
      };
      mockGetUserById.mockResolvedValue({
        data: { user: mockUser },
        error: null,
      });

      await service.getUserById('user-uuid-1');

      expect(mockGetUserById).toHaveBeenCalledWith('user-uuid-1');
    });

    it('Supabase에서 error 반환 → 에러 throw', async () => {
      const supabaseError = new Error('User not found');
      mockGetUserById.mockResolvedValue({
        data: { user: null },
        error: supabaseError,
      });

      await expect(service.getUserById('nonexistent')).rejects.toThrow(
        'User not found',
      );
    });

    it('email 필드가 없는 사용자도 처리 (email undefined)', async () => {
      const mockUser = {
        id: 'user-uuid-no-email',
        email: undefined,
        created_at: '2024-01-01T00:00:00Z',
      };
      mockGetUserById.mockResolvedValue({
        data: { user: mockUser },
        error: null,
      });

      const result = await service.getUserById('user-uuid-no-email');

      expect(result.id).toBe('user-uuid-no-email');
      expect(result.email).toBeUndefined();
    });
  });
});
