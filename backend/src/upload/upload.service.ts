import { Injectable, BadRequestException } from '@nestjs/common';
import { SupabaseService } from '@config/supabase.service';
import { v4 as uuidv4 } from 'uuid';

@Injectable()
export class UploadService {
  private readonly BUCKET = 'animal-profiles';
  private readonly MAX_SIZE = 5 * 1024 * 1024; // 5MB
  private readonly ALLOWED_TYPES = [
    'image/jpeg',
    'image/png',
    'image/webp',
    'image/heic',
  ];

  constructor(private readonly supabaseService: SupabaseService) {}

  async uploadProfileImage(
    file: Express.Multer.File,
    userId: string,
  ): Promise<string> {
    this.validateFile(file);

    const ext = file.originalname.split('.').pop() || 'jpg';
    const path = `${userId}/${uuidv4()}.${ext}`;

    const { error } = await this.supabaseService
      .getClient()
      .storage.from(this.BUCKET)
      .upload(path, file.buffer, {
        contentType: file.mimetype,
        upsert: false,
      });

    if (error) {
      throw new BadRequestException(`이미지 업로드 실패: ${error.message}`);
    }

    const {
      data: { publicUrl },
    } = this.supabaseService
      .getClient()
      .storage.from(this.BUCKET)
      .getPublicUrl(path);

    return publicUrl;
  }

  async uploadCareLogImages(
    files: Express.Multer.File[],
    userId: string,
  ): Promise<string[]> {
    if (files.length > 3) {
      throw new BadRequestException('최대 3개의 이미지만 업로드 가능합니다');
    }

    const urls: string[] = [];
    for (const file of files) {
      this.validateFile(file);

      const ext = file.originalname.split('.').pop() || 'jpg';
      const path = `care-logs/${userId}/${uuidv4()}.${ext}`;

      const { error } = await this.supabaseService
        .getClient()
        .storage.from(this.BUCKET)
        .upload(path, file.buffer, {
          contentType: file.mimetype,
          upsert: false,
        });

      if (error) {
        throw new BadRequestException(`이미지 업로드 실패: ${error.message}`);
      }

      const {
        data: { publicUrl },
      } = this.supabaseService
        .getClient()
        .storage.from(this.BUCKET)
        .getPublicUrl(path);

      urls.push(publicUrl);
    }

    return urls;
  }

  private validateFile(file: Express.Multer.File) {
    if (file.size > this.MAX_SIZE) {
      throw new BadRequestException('파일 크기는 5MB 이하여야 합니다');
    }
    if (!this.ALLOWED_TYPES.includes(file.mimetype)) {
      throw new BadRequestException(
        '지원하는 이미지 형식: JPEG, PNG, WebP, HEIC',
      );
    }
  }
}
