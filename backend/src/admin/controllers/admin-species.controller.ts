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
import { AdminSpeciesService } from '../services/admin-species.service';
import { CreateSpeciesDto } from '../dto/create-species.dto';
import { UpdateSpeciesDto } from '../dto/update-species.dto';

@ApiTags('Admin - Species')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, AdminGuard)
@Controller('admin/species')
export class AdminSpeciesController {
  constructor(private readonly adminSpeciesService: AdminSpeciesService) {}

  @Get()
  @ApiOperation({ summary: '종 목록 조회 (관리자)' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiQuery({ name: 'search', required: false, type: String })
  @ApiQuery({ name: 'genusId', required: false, type: String })
  @ApiOkResponse({ description: '종 목록과 페이지네이션' })
  async listSpecies(
    @Query('page') page?: number,
    @Query('limit') limit?: number,
    @Query('search') search?: string,
    @Query('genusId') genusId?: string,
  ) {
    return this.adminSpeciesService.listSpecies({ page, limit, search, genusId });
  }

  @Post()
  @ApiOperation({ summary: '종 생성 (관리자)' })
  @ApiCreatedResponse({ description: '생성된 종' })
  async createSpecies(@Body() dto: CreateSpeciesDto) {
    return this.adminSpeciesService.createSpecies(dto);
  }

  @Patch(':id')
  @ApiOperation({ summary: '종 수정 (관리자)' })
  @ApiOkResponse({ description: '수정된 종' })
  async updateSpecies(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateSpeciesDto,
  ) {
    return this.adminSpeciesService.updateSpecies(id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: '종 삭제 (관리자)' })
  @ApiNoContentResponse({ description: '삭제 완료' })
  async deleteSpecies(@Param('id', ParseUUIDPipe) id: string) {
    return this.adminSpeciesService.deleteSpecies(id);
  }
}
