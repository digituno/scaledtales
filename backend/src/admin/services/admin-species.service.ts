import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like } from 'typeorm';
import { Species } from '@/species/entities/species.entity';
import { Genus } from '@/species/entities/genus.entity';
import { CreateSpeciesDto } from '../dto/create-species.dto';
import { UpdateSpeciesDto } from '../dto/update-species.dto';

@Injectable()
export class AdminSpeciesService {
  constructor(
    @InjectRepository(Species)
    private readonly speciesRepo: Repository<Species>,
    @InjectRepository(Genus)
    private readonly genusRepo: Repository<Genus>,
  ) {}

  async listSpecies(query: {
    page?: number;
    limit?: number;
    search?: string;
    genusId?: string;
  }) {
    const { page = 1, limit = 20, search, genusId } = query;
    const skip = (page - 1) * limit;

    const qb = this.speciesRepo
      .createQueryBuilder('s')
      .leftJoinAndSelect('s.genus', 'genus')
      .leftJoinAndSelect('genus.family', 'family')
      .leftJoinAndSelect('family.order', 'order')
      .leftJoinAndSelect('order.taxonomyClass', 'class')
      .orderBy('s.species_kr', 'ASC')
      .skip(skip)
      .take(limit);

    if (search) {
      qb.andWhere(
        '(s.species_kr ILIKE :q OR s.species_en ILIKE :q OR s.scientific_name ILIKE :q)',
        { q: `%${search}%` },
      );
    }

    if (genusId) {
      qb.andWhere('s.genusId = :genusId', { genusId });
    }

    const [items, total] = await qb.getManyAndCount();

    return {
      data: items,
      pagination: { page, limit, total },
    };
  }

  async createSpecies(dto: CreateSpeciesDto): Promise<Species> {
    const genus = await this.genusRepo.findOne({
      where: { id: dto.genusId },
    });
    if (!genus) {
      throw new BadRequestException(
        `Genus를 찾을 수 없습니다: ${dto.genusId}`,
      );
    }

    if (dto.is_cites && !dto.cites_level) {
      throw new BadRequestException(
        'is_cites가 true인 경우 cites_level이 필요합니다',
      );
    }

    const species = this.speciesRepo.create({
      ...dto,
      genus,
    });
    return this.speciesRepo.save(species);
  }

  async updateSpecies(id: string, dto: UpdateSpeciesDto): Promise<Species> {
    const species = await this.speciesRepo.findOne({
      where: { id },
      relations: ['genus'],
    });
    if (!species) {
      throw new NotFoundException(`종을 찾을 수 없습니다: ${id}`);
    }

    if (dto.genusId && dto.genusId !== species.genusId) {
      const genus = await this.genusRepo.findOne({
        where: { id: dto.genusId },
      });
      if (!genus) {
        throw new BadRequestException(
          `Genus를 찾을 수 없습니다: ${dto.genusId}`,
        );
      }
    }

    const updated = this.speciesRepo.merge(species, dto);
    return this.speciesRepo.save(updated);
  }

  async deleteSpecies(id: string): Promise<void> {
    const species = await this.speciesRepo.findOne({ where: { id } });
    if (!species) {
      throw new NotFoundException(`종을 찾을 수 없습니다: ${id}`);
    }
    await this.speciesRepo.remove(species);
  }
}
