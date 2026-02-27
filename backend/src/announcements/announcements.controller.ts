import { Controller, Get, UseGuards } from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiOkResponse,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '@/auth/guards/jwt-auth.guard';
import { AnnouncementsService } from './announcements.service';

@ApiTags('Announcements')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('announcements')
export class AnnouncementsController {
  constructor(private readonly announcementsService: AnnouncementsService) {}

  @Get('active')
  @ApiOperation({ summary: '활성 공지사항 목록 조회' })
  @ApiOkResponse({ description: '공지 기간 내 활성 공지사항 목록' })
  async getActive() {
    return this.announcementsService.findActive();
  }
}
