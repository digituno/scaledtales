import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiParam,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '@/auth/guards/jwt-auth.guard';
import { CurrentUser } from '@common/decorators/current-user.decorator';
import { CareLogsService } from './care-logs.service';
import { CreateCareLogDto } from './dto/create-care-log.dto';
import { UpdateCareLogDto } from './dto/update-care-log.dto';
import { QueryCareLogDto } from './dto/query-care-log.dto';

@ApiTags('Care Logs')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller()
export class CareLogsController {
  constructor(private readonly careLogsService: CareLogsService) {}

  @Post('animals/:animalId/care-logs')
  @ApiOperation({ summary: '사육 일지 등록' })
  @ApiParam({ name: 'animalId', description: '개체 ID' })
  create(
    @CurrentUser('id') userId: string,
    @Param('animalId') animalId: string,
    @Body() dto: CreateCareLogDto,
  ) {
    return this.careLogsService.create(userId, animalId, dto);
  }

  @Get('animals/:animalId/care-logs')
  @ApiOperation({ summary: '개체별 일지 목록 조회' })
  @ApiParam({ name: 'animalId', description: '개체 ID' })
  findAll(
    @CurrentUser('id') userId: string,
    @Param('animalId') animalId: string,
    @Query() query: QueryCareLogDto,
  ) {
    return this.careLogsService.findAll(userId, animalId, query);
  }

  @Get('care-logs')
  @ApiOperation({ summary: '내 전체 일지 목록 조회' })
  findAllForUser(
    @CurrentUser('id') userId: string,
    @Query() query: QueryCareLogDto,
  ) {
    return this.careLogsService.findAllForUser(userId, query);
  }

  @Get('care-logs/:id')
  @ApiOperation({ summary: '일지 상세 조회' })
  @ApiParam({ name: 'id', description: '일지 ID' })
  findOne(@CurrentUser('id') userId: string, @Param('id') id: string) {
    return this.careLogsService.findOne(userId, id);
  }

  @Patch('care-logs/:id')
  @ApiOperation({ summary: '일지 수정' })
  @ApiParam({ name: 'id', description: '일지 ID' })
  update(
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
    @Body() dto: UpdateCareLogDto,
  ) {
    return this.careLogsService.update(userId, id, dto);
  }

  @Delete('care-logs/:id')
  @ApiOperation({ summary: '일지 삭제' })
  @ApiParam({ name: 'id', description: '일지 ID' })
  remove(@CurrentUser('id') userId: string, @Param('id') id: string) {
    return this.careLogsService.remove(userId, id);
  }
}
