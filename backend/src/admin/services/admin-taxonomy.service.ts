import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TaxonomyClass } from '@/species/entities/taxonomy-class.entity';
import { Order } from '@/species/entities/order.entity';
import { Family } from '@/species/entities/family.entity';
import { Genus } from '@/species/entities/genus.entity';
import { CreateTaxonomyClassDto } from '../dto/create-taxonomy-class.dto';
import { CreateTaxonomyOrderDto } from '../dto/create-taxonomy-order.dto';
import { CreateTaxonomyFamilyDto } from '../dto/create-taxonomy-family.dto';
import { CreateTaxonomyGenusDto } from '../dto/create-taxonomy-genus.dto';

@Injectable()
export class AdminTaxonomyService {
  constructor(
    @InjectRepository(TaxonomyClass)
    private readonly classRepo: Repository<TaxonomyClass>,
    @InjectRepository(Order)
    private readonly orderRepo: Repository<Order>,
    @InjectRepository(Family)
    private readonly familyRepo: Repository<Family>,
    @InjectRepository(Genus)
    private readonly genusRepo: Repository<Genus>,
  ) {}

  // ── 전체 트리 조회 ──────────────────────────────────────────
  async getTree() {
    const classes = await this.classRepo.find({
      relations: ['orders', 'orders.families', 'orders.families.genera'],
      order: { name_en: 'ASC' },
    });
    return classes;
  }

  // ── Class ──────────────────────────────────────────────────
  async createClass(dto: CreateTaxonomyClassDto): Promise<TaxonomyClass> {
    const entity = this.classRepo.create(dto);
    return this.classRepo.save(entity);
  }

  async updateClass(
    id: string,
    dto: Partial<CreateTaxonomyClassDto>,
  ): Promise<TaxonomyClass> {
    const entity = await this.classRepo.findOne({ where: { id } });
    if (!entity)
      throw new NotFoundException(`강(Class)을 찾을 수 없습니다: ${id}`);
    Object.assign(entity, dto);
    return this.classRepo.save(entity);
  }

  async deleteClass(id: string): Promise<void> {
    const entity = await this.classRepo.findOne({ where: { id } });
    if (!entity)
      throw new NotFoundException(`강(Class)을 찾을 수 없습니다: ${id}`);
    await this.classRepo.remove(entity);
  }

  // ── Order ──────────────────────────────────────────────────
  async createOrder(dto: CreateTaxonomyOrderDto): Promise<Order> {
    const cls = await this.classRepo.findOne({ where: { id: dto.classId } });
    if (!cls)
      throw new NotFoundException(
        `강(Class)을 찾을 수 없습니다: ${dto.classId}`,
      );
    const entity = this.orderRepo.create({ ...dto, taxonomyClass: cls });
    return this.orderRepo.save(entity);
  }

  async updateOrder(
    id: string,
    dto: Partial<CreateTaxonomyOrderDto>,
  ): Promise<Order> {
    const entity = await this.orderRepo.findOne({ where: { id } });
    if (!entity)
      throw new NotFoundException(`목(Order)을 찾을 수 없습니다: ${id}`);
    if (dto.classId) entity.classId = dto.classId;
    if (dto.name_kr) entity.name_kr = dto.name_kr;
    if (dto.name_en) entity.name_en = dto.name_en;
    return this.orderRepo.save(entity);
  }

  async deleteOrder(id: string): Promise<void> {
    const entity = await this.orderRepo.findOne({ where: { id } });
    if (!entity)
      throw new NotFoundException(`목(Order)을 찾을 수 없습니다: ${id}`);
    await this.orderRepo.remove(entity);
  }

  // ── Family ──────────────────────────────────────────────────
  async createFamily(dto: CreateTaxonomyFamilyDto): Promise<Family> {
    const order = await this.orderRepo.findOne({ where: { id: dto.orderId } });
    if (!order)
      throw new NotFoundException(
        `목(Order)을 찾을 수 없습니다: ${dto.orderId}`,
      );
    const entity = this.familyRepo.create({ ...dto, order });
    return this.familyRepo.save(entity);
  }

  async updateFamily(
    id: string,
    dto: Partial<CreateTaxonomyFamilyDto>,
  ): Promise<Family> {
    const entity = await this.familyRepo.findOne({ where: { id } });
    if (!entity)
      throw new NotFoundException(`과(Family)를 찾을 수 없습니다: ${id}`);
    if (dto.orderId) entity.orderId = dto.orderId;
    if (dto.name_kr) entity.name_kr = dto.name_kr;
    if (dto.name_en) entity.name_en = dto.name_en;
    return this.familyRepo.save(entity);
  }

  async deleteFamily(id: string): Promise<void> {
    const entity = await this.familyRepo.findOne({ where: { id } });
    if (!entity)
      throw new NotFoundException(`과(Family)를 찾을 수 없습니다: ${id}`);
    await this.familyRepo.remove(entity);
  }

  // ── Genus ──────────────────────────────────────────────────
  async createGenus(dto: CreateTaxonomyGenusDto): Promise<Genus> {
    const family = await this.familyRepo.findOne({
      where: { id: dto.familyId },
    });
    if (!family)
      throw new NotFoundException(
        `과(Family)를 찾을 수 없습니다: ${dto.familyId}`,
      );
    const entity = this.genusRepo.create({ ...dto, family });
    return this.genusRepo.save(entity);
  }

  async updateGenus(
    id: string,
    dto: Partial<CreateTaxonomyGenusDto>,
  ): Promise<Genus> {
    const entity = await this.genusRepo.findOne({ where: { id } });
    if (!entity)
      throw new NotFoundException(`속(Genus)을 찾을 수 없습니다: ${id}`);
    if (dto.familyId) entity.familyId = dto.familyId;
    if (dto.name_kr) entity.name_kr = dto.name_kr;
    if (dto.name_en) entity.name_en = dto.name_en;
    return this.genusRepo.save(entity);
  }

  async deleteGenus(id: string): Promise<void> {
    const entity = await this.genusRepo.findOne({ where: { id } });
    if (!entity)
      throw new NotFoundException(`속(Genus)을 찾을 수 없습니다: ${id}`);
    await this.genusRepo.remove(entity);
  }
}
