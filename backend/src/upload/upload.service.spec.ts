import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException } from '@nestjs/common';
import { UploadService } from './upload.service';
import { SupabaseService } from '@config/supabase.service';

const makeFile = (
  overrides: Partial<Express.Multer.File> = {},
): Express.Multer.File => ({
  fieldname: 'file',
  originalname: 'test.jpg',
  encoding: '7bit',
  mimetype: 'image/jpeg',
  size: 1024, // 1KB
  buffer: Buffer.from('fake-image'),
  stream: null as any,
  destination: '',
  filename: 'test.jpg',
  path: '',
  ...overrides,
});

describe('UploadService', () => {
  let service: UploadService;
  let mockStorageBucket: {
    upload: jest.Mock;
    getPublicUrl: jest.Mock;
  };

  beforeEach(async () => {
    mockStorageBucket = {
      upload: jest.fn().mockResolvedValue({ error: null }),
      getPublicUrl: jest.fn().mockReturnValue({
        data: { publicUrl: 'https://cdn.example.com/test.jpg' },
      }),
    };

    const mockSupabaseClient = {
      storage: {
        from: jest.fn().mockReturnValue(mockStorageBucket),
      },
    };

    const mockSupabaseService = {
      getClient: jest.fn().mockReturnValue(mockSupabaseClient),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UploadService,
        { provide: SupabaseService, useValue: mockSupabaseService },
      ],
    }).compile();

    service = module.get<UploadService>(UploadService);
  });

  // ── 파일 유효성 검증 ──

  describe('validateFile — 파일 크기', () => {
    it('5MB 초과 파일 → BadRequestException', async () => {
      const bigFile = makeFile({ size: 6 * 1024 * 1024 }); // 6MB

      await expect(
        service.uploadProfileImage(bigFile, 'user1'),
      ).rejects.toThrow(BadRequestException);
    });

    it('5MB 초과 파일 → 오류 메시지 포함', async () => {
      const bigFile = makeFile({ size: 6 * 1024 * 1024 });

      await expect(
        service.uploadProfileImage(bigFile, 'user1'),
      ).rejects.toThrow('5MB');
    });

    it('정확히 5MB → 통과', async () => {
      const exactFile = makeFile({ size: 5 * 1024 * 1024 });
      await expect(
        service.uploadProfileImage(exactFile, 'user1'),
      ).resolves.toBeTruthy();
    });
  });

  describe('validateFile — MIME type', () => {
    it('미지원 MIME type (image/gif) → BadRequestException', async () => {
      const gifFile = makeFile({
        mimetype: 'image/gif',
        originalname: 'test.gif',
      });

      await expect(
        service.uploadProfileImage(gifFile, 'user1'),
      ).rejects.toThrow(BadRequestException);
    });

    it('지원 MIME type (image/png) → 통과', async () => {
      const pngFile = makeFile({
        mimetype: 'image/png',
        originalname: 'test.png',
      });
      await expect(
        service.uploadProfileImage(pngFile, 'user1'),
      ).resolves.toBeTruthy();
    });

    it('지원 MIME type (image/webp) → 통과', async () => {
      const webpFile = makeFile({
        mimetype: 'image/webp',
        originalname: 'test.webp',
      });
      await expect(
        service.uploadProfileImage(webpFile, 'user1'),
      ).resolves.toBeTruthy();
    });

    it('지원 MIME type (image/heic) → 통과', async () => {
      const heicFile = makeFile({
        mimetype: 'image/heic',
        originalname: 'test.heic',
      });
      await expect(
        service.uploadProfileImage(heicFile, 'user1'),
      ).resolves.toBeTruthy();
    });
  });

  // ── uploadProfileImage ──

  describe('uploadProfileImage', () => {
    it('정상 업로드 → Public URL 반환', async () => {
      const file = makeFile();
      const url = await service.uploadProfileImage(file, 'user1');

      expect(url).toBe('https://cdn.example.com/test.jpg');
    });

    it('Supabase 업로드 실패 → BadRequestException', async () => {
      mockStorageBucket.upload.mockResolvedValue({
        error: { message: 'Storage bucket not found' },
      });

      const file = makeFile();
      await expect(service.uploadProfileImage(file, 'user1')).rejects.toThrow(
        BadRequestException,
      );
    });

    it('Supabase 업로드 실패 → 오류 메시지 포함', async () => {
      mockStorageBucket.upload.mockResolvedValue({
        error: { message: 'Storage bucket not found' },
      });

      const file = makeFile();
      await expect(service.uploadProfileImage(file, 'user1')).rejects.toThrow(
        '이미지 업로드 실패',
      );
    });
  });

  // ── uploadCareLogImages ──

  describe('uploadCareLogImages', () => {
    it('4개 이상 파일 → BadRequestException (최대 3개)', async () => {
      const files = Array.from({ length: 4 }, () => makeFile());

      await expect(service.uploadCareLogImages(files, 'user1')).rejects.toThrow(
        BadRequestException,
      );
    });

    it('4개 이상 파일 → "최대 3개" 메시지 포함', async () => {
      const files = Array.from({ length: 4 }, () => makeFile());

      await expect(service.uploadCareLogImages(files, 'user1')).rejects.toThrow(
        '최대 3개',
      );
    });

    it('3개 이하 파일 → URL 배열 반환', async () => {
      const files = [makeFile(), makeFile(), makeFile()];
      const urls = await service.uploadCareLogImages(files, 'user1');

      expect(urls).toHaveLength(3);
      expect(urls[0]).toBe('https://cdn.example.com/test.jpg');
    });

    it('1개 파일 → 1개 URL 배열 반환', async () => {
      const files = [makeFile()];
      const urls = await service.uploadCareLogImages(files, 'user1');

      expect(urls).toHaveLength(1);
    });

    it('care-log 업로드도 파일 크기 검증 적용', async () => {
      const files = [makeFile({ size: 6 * 1024 * 1024 })];

      await expect(service.uploadCareLogImages(files, 'user1')).rejects.toThrow(
        BadRequestException,
      );
    });
  });
});
