import { Controller, Get, UseGuards } from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiOkResponse,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '@/auth/guards/jwt-auth.guard';
import { AdminGuard } from '../guards/admin.guard';
import { AdminStatsService } from '../services/admin-stats.service';

@ApiTags('Admin - Stats')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, AdminGuard)
@Controller('admin/stats')
export class AdminStatsController {
  constructor(private readonly adminStatsService: AdminStatsService) {}

  @Get()
  @ApiOperation({ summary: '대시보드 통계 조회 (관리자)' })
  @ApiOkResponse({ description: '개체/케어로그/종/사용자 통계' })
  async getStats() {
    return this.adminStatsService.getStats();
  }
}
