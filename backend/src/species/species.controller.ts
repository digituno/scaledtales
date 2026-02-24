import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiOperation, ApiParam, ApiTags } from '@nestjs/swagger';
import { SpeciesService } from './species.service';
import { SearchSpeciesDto } from './dto/search-species.dto';

@ApiTags('Species')
@Controller('species')
export class SpeciesController {
  constructor(private readonly speciesService: SpeciesService) {}

  @Get('classes')
  @ApiOperation({ summary: '강(Class) 목록 조회' })
  getClasses() {
    return this.speciesService.getClasses();
  }

  @Get('classes/:classId/orders')
  @ApiOperation({ summary: '목(Order) 목록 조회' })
  @ApiParam({ name: 'classId', description: '강 ID' })
  getOrders(@Param('classId') classId: string) {
    return this.speciesService.getOrdersByClass(classId);
  }

  @Get('orders/:orderId/families')
  @ApiOperation({ summary: '과(Family) 목록 조회' })
  @ApiParam({ name: 'orderId', description: '목 ID' })
  getFamilies(@Param('orderId') orderId: string) {
    return this.speciesService.getFamiliesByOrder(orderId);
  }

  @Get('families/:familyId/genera')
  @ApiOperation({ summary: '속(Genus) 목록 조회' })
  @ApiParam({ name: 'familyId', description: '과 ID' })
  getGenera(@Param('familyId') familyId: string) {
    return this.speciesService.getGeneraByFamily(familyId);
  }

  @Get('genera/:genusId/species')
  @ApiOperation({ summary: '종(Species) 목록 조회' })
  @ApiParam({ name: 'genusId', description: '속 ID' })
  getSpeciesByGenus(@Param('genusId') genusId: string) {
    return this.speciesService.getSpeciesByGenus(genusId);
  }

  @Get('search')
  @ApiOperation({ summary: '종 검색' })
  search(@Query() dto: SearchSpeciesDto) {
    return this.speciesService.searchSpecies(dto);
  }

  @Get(':id')
  @ApiOperation({ summary: '종 상세 조회' })
  @ApiParam({ name: 'id', description: '종 ID' })
  getOne(@Param('id') id: string) {
    return this.speciesService.getSpeciesById(id);
  }
}
