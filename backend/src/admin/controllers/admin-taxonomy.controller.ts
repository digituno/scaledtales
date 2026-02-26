import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Param,
  Body,
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
} from '@nestjs/swagger';
import { JwtAuthGuard } from '@/auth/guards/jwt-auth.guard';
import { AdminGuard } from '../guards/admin.guard';
import { AdminTaxonomyService } from '../services/admin-taxonomy.service';
import { CreateTaxonomyClassDto } from '../dto/create-taxonomy-class.dto';
import { CreateTaxonomyOrderDto } from '../dto/create-taxonomy-order.dto';
import { CreateTaxonomyFamilyDto } from '../dto/create-taxonomy-family.dto';
import { CreateTaxonomyGenusDto } from '../dto/create-taxonomy-genus.dto';

@ApiTags('Admin - Taxonomy')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, AdminGuard)
@Controller('admin/taxonomy')
export class AdminTaxonomyController {
  constructor(private readonly adminTaxonomyService: AdminTaxonomyService) {}

  // ── 전체 트리 ────────────────────────────────────────────────
  @Get('tree')
  @ApiOperation({ summary: '분류 트리 전체 조회 (관리자)' })
  @ApiOkResponse({ description: '강→목→과→속 계층 트리' })
  async getTree() {
    return this.adminTaxonomyService.getTree();
  }

  // ── Class ────────────────────────────────────────────────────
  @Post('classes')
  @ApiOperation({ summary: '강(Class) 생성' })
  @ApiCreatedResponse({ description: '생성된 강' })
  async createClass(@Body() dto: CreateTaxonomyClassDto) {
    return this.adminTaxonomyService.createClass(dto);
  }

  @Patch('classes/:id')
  @ApiOperation({ summary: '강(Class) 수정' })
  @ApiOkResponse({ description: '수정된 강' })
  async updateClass(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: Partial<CreateTaxonomyClassDto>,
  ) {
    return this.adminTaxonomyService.updateClass(id, dto);
  }

  @Delete('classes/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: '강(Class) 삭제' })
  @ApiNoContentResponse({ description: '삭제 완료' })
  async deleteClass(@Param('id', ParseUUIDPipe) id: string) {
    return this.adminTaxonomyService.deleteClass(id);
  }

  // ── Order ────────────────────────────────────────────────────
  @Post('orders')
  @ApiOperation({ summary: '목(Order) 생성' })
  @ApiCreatedResponse({ description: '생성된 목' })
  async createOrder(@Body() dto: CreateTaxonomyOrderDto) {
    return this.adminTaxonomyService.createOrder(dto);
  }

  @Patch('orders/:id')
  @ApiOperation({ summary: '목(Order) 수정' })
  @ApiOkResponse({ description: '수정된 목' })
  async updateOrder(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: Partial<CreateTaxonomyOrderDto>,
  ) {
    return this.adminTaxonomyService.updateOrder(id, dto);
  }

  @Delete('orders/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: '목(Order) 삭제' })
  @ApiNoContentResponse({ description: '삭제 완료' })
  async deleteOrder(@Param('id', ParseUUIDPipe) id: string) {
    return this.adminTaxonomyService.deleteOrder(id);
  }

  // ── Family ────────────────────────────────────────────────────
  @Post('families')
  @ApiOperation({ summary: '과(Family) 생성' })
  @ApiCreatedResponse({ description: '생성된 과' })
  async createFamily(@Body() dto: CreateTaxonomyFamilyDto) {
    return this.adminTaxonomyService.createFamily(dto);
  }

  @Patch('families/:id')
  @ApiOperation({ summary: '과(Family) 수정' })
  @ApiOkResponse({ description: '수정된 과' })
  async updateFamily(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: Partial<CreateTaxonomyFamilyDto>,
  ) {
    return this.adminTaxonomyService.updateFamily(id, dto);
  }

  @Delete('families/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: '과(Family) 삭제' })
  @ApiNoContentResponse({ description: '삭제 완료' })
  async deleteFamily(@Param('id', ParseUUIDPipe) id: string) {
    return this.adminTaxonomyService.deleteFamily(id);
  }

  // ── Genus ────────────────────────────────────────────────────
  @Post('genera')
  @ApiOperation({ summary: '속(Genus) 생성' })
  @ApiCreatedResponse({ description: '생성된 속' })
  async createGenus(@Body() dto: CreateTaxonomyGenusDto) {
    return this.adminTaxonomyService.createGenus(dto);
  }

  @Patch('genera/:id')
  @ApiOperation({ summary: '속(Genus) 수정' })
  @ApiOkResponse({ description: '수정된 속' })
  async updateGenus(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: Partial<CreateTaxonomyGenusDto>,
  ) {
    return this.adminTaxonomyService.updateGenus(id, dto);
  }

  @Delete('genera/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: '속(Genus) 삭제' })
  @ApiNoContentResponse({ description: '삭제 완료' })
  async deleteGenus(@Param('id', ParseUUIDPipe) id: string) {
    return this.adminTaxonomyService.deleteGenus(id);
  }
}
