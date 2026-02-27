import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Body,
  Query,
  UseGuards,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiOkResponse,
  ApiCreatedResponse,
  ApiNoContentResponse,
  ApiQuery,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '@/auth/guards/jwt-auth.guard';
import { AdminGuard } from '../guards/admin.guard';
import { AdminAnnouncementsService } from '../services/admin-announcements.service';
import { CreateAnnouncementDto } from '../dto/create-announcement.dto';
import { UpdateAnnouncementDto } from '../dto/update-announcement.dto';

@ApiTags('Admin - Announcements')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, AdminGuard)
@Controller('admin/announcements')
export class AdminAnnouncementsController {
  constructor(
    private readonly adminAnnouncementsService: AdminAnnouncementsService,
  ) {}

  @Get()
  @ApiOperation({ summary: '공지사항 목록 조회 (관리자)' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiOkResponse({ description: '공지사항 목록과 페이지네이션' })
  async listAnnouncements(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.adminAnnouncementsService.listAnnouncements({ page, limit });
  }

  @Post()
  @ApiOperation({ summary: '공지사항 생성 (관리자)' })
  @ApiCreatedResponse({ description: '생성된 공지사항' })
  async createAnnouncement(@Body() dto: CreateAnnouncementDto) {
    return this.adminAnnouncementsService.createAnnouncement(dto);
  }

  @Patch(':id')
  @ApiOperation({ summary: '공지사항 수정 (관리자)' })
  @ApiOkResponse({ description: '수정된 공지사항' })
  async updateAnnouncement(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateAnnouncementDto,
  ) {
    return this.adminAnnouncementsService.updateAnnouncement(id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: '공지사항 소프트 삭제 (관리자)' })
  @ApiNoContentResponse({ description: '소프트 삭제 완료' })
  async deleteAnnouncement(@Param('id', ParseUUIDPipe) id: string) {
    return this.adminAnnouncementsService.softDeleteAnnouncement(id);
  }
}
