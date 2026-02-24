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
import { AnimalsService } from './animals.service';
import { CreateAnimalDto } from './dto/create-animal.dto';
import { UpdateAnimalDto } from './dto/update-animal.dto';
import { QueryAnimalDto } from './dto/query-animal.dto';

@ApiTags('Animals')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('animals')
export class AnimalsController {
  constructor(private readonly animalsService: AnimalsService) {}

  @Post()
  @ApiOperation({ summary: '개체 등록' })
  create(@CurrentUser('id') userId: string, @Body() dto: CreateAnimalDto) {
    return this.animalsService.create(userId, dto);
  }

  @Get()
  @ApiOperation({ summary: '개체 목록 조회' })
  findAll(@CurrentUser('id') userId: string, @Query() query: QueryAnimalDto) {
    return this.animalsService.findAll(userId, query);
  }

  @Get(':id')
  @ApiOperation({ summary: '개체 상세 조회' })
  @ApiParam({ name: 'id', description: '개체 ID' })
  findOne(@CurrentUser('id') userId: string, @Param('id') id: string) {
    return this.animalsService.findOne(userId, id);
  }

  @Patch(':id')
  @ApiOperation({ summary: '개체 수정' })
  @ApiParam({ name: 'id', description: '개체 ID' })
  update(
    @CurrentUser('id') userId: string,
    @Param('id') id: string,
    @Body() dto: UpdateAnimalDto,
  ) {
    return this.animalsService.update(userId, id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: '개체 삭제' })
  @ApiParam({ name: 'id', description: '개체 ID' })
  remove(@CurrentUser('id') userId: string, @Param('id') id: string) {
    return this.animalsService.remove(userId, id);
  }
}
