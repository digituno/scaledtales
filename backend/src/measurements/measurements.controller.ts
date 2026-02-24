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
import { MeasurementsService } from './measurements.service';
import { CreateMeasurementDto } from './dto/create-measurement.dto';
import { UpdateMeasurementDto } from './dto/update-measurement.dto';
import { QueryMeasurementDto } from './dto/query-measurement.dto';

@ApiTags('Measurements')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller()
export class MeasurementsController {
  constructor(private readonly measurementsService: MeasurementsService) {}

  @Post('animals/:animalId/measurements')
  @ApiOperation({ summary: '측정 기록 등록' })
  @ApiParam({ name: 'animalId', description: '개체 ID' })
  create(
    @CurrentUser('id') userId: string,
    @Param('animalId') animalId: string,
    @Body() dto: CreateMeasurementDto,
  ) {
    return this.measurementsService.create(userId, animalId, dto);
  }

  @Get('animals/:animalId/measurements')
  @ApiOperation({ summary: '측정 기록 목록 조회' })
  @ApiParam({ name: 'animalId', description: '개체 ID' })
  findAll(
    @CurrentUser('id') userId: string,
    @Param('animalId') animalId: string,
    @Query() query: QueryMeasurementDto,
  ) {
    return this.measurementsService.findAll(userId, animalId, query);
  }

  @Patch('measurements/:id')
  @ApiOperation({ summary: '측정 기록 수정' })
  @ApiParam({ name: 'id', description: '측정 기록 ID' })
  update(
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
    @Body() dto: UpdateMeasurementDto,
  ) {
    return this.measurementsService.update(userId, id, dto);
  }

  @Delete('measurements/:id')
  @ApiOperation({ summary: '측정 기록 삭제' })
  @ApiParam({ name: 'id', description: '측정 기록 ID' })
  remove(@CurrentUser('id') userId: string, @Param('id') id: string) {
    return this.measurementsService.remove(userId, id);
  }
}
