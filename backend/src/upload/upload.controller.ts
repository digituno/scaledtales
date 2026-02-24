import {
  Controller,
  Post,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  UploadedFiles,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiConsumes,
} from '@nestjs/swagger';
import { FileInterceptor, FilesInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '@/auth/guards/jwt-auth.guard';
import { CurrentUser } from '@common/decorators/current-user.decorator';
import { UploadService } from './upload.service';

@ApiTags('Upload')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('upload')
export class UploadController {
  constructor(private readonly uploadService: UploadService) {}

  @Post('profile')
  @ApiOperation({ summary: '프로필 이미지 업로드' })
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FileInterceptor('file'))
  async uploadProfile(
    @CurrentUser('id') userId: string,
    @UploadedFile() file: Express.Multer.File,
  ) {
    const url = await this.uploadService.uploadProfileImage(file, userId);
    return { url };
  }

  @Post('care-log')
  @ApiOperation({ summary: '일지 이미지 업로드 (최대 3개)' })
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FilesInterceptor('files', 3))
  async uploadCareLog(
    @CurrentUser('id') userId: string,
    @UploadedFiles() files: Express.Multer.File[],
  ) {
    const urls = await this.uploadService.uploadCareLogImages(files, userId);
    return { urls };
  }
}
