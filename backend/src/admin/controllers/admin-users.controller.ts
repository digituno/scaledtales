import {
  Controller,
  Get,
  Patch,
  Param,
  Body,
  Query,
  UseGuards,
  ParseUUIDPipe,
} from '@nestjs/common';
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiOkResponse,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '@/auth/guards/jwt-auth.guard';
import { AdminGuard } from '../guards/admin.guard';
import { AdminUsersService } from '../services/admin-users.service';
import { QueryAdminUsersDto } from '../dto/query-admin-users.dto';
import { PatchUserRoleDto } from '../dto/patch-user-role.dto';

@ApiTags('Admin - Users')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, AdminGuard)
@Controller('admin/users')
export class AdminUsersController {
  constructor(private readonly adminUsersService: AdminUsersService) {}

  @Get()
  @ApiOperation({ summary: '사용자 목록 조회 (관리자)' })
  @ApiOkResponse({ description: '사용자 목록과 페이지네이션' })
  async listUsers(@Query() dto: QueryAdminUsersDto) {
    return this.adminUsersService.listUsers(dto);
  }

  @Patch(':userId/role')
  @ApiOperation({ summary: '사용자 역할 변경 (관리자)' })
  @ApiOkResponse({ description: '변경된 사용자 역할' })
  async updateUserRole(
    @Param('userId', ParseUUIDPipe) userId: string,
    @Body() dto: PatchUserRoleDto,
  ) {
    return this.adminUsersService.updateUserRole(userId, dto);
  }
}
