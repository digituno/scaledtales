import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, ILike } from 'typeorm';
import { Species } from '@/species/entities/species.entity';
import { Genus } from '@/species/entities/genus.entity';
import { CreateSpeciesDto } from '../dto/create-species.dto';
import { UpdateSpeciesDto } from '../dto/update-species.dto';
import { BulkSpeciesRowDto } from '../dto/bulk-import-species.dto';

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
      throw new BadRequestException(`Genus를 찾을 수 없습니다: ${dto.genusId}`);
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

  // ── CSV 대량 임포트 ───────────────────────────────────────────
  async bulkImport(rows: BulkSpeciesRowDto[]): Promise<{
    success: number;
    failed: number;
    errors: { row: number; genus_name: string; reason: string }[];
  }> {
    // 전체 Genus를 한 번에 로드해서 name_en 기준 맵 생성 (대소문자 무시)
    const allGenera = await this.genusRepo.find();
    const genusMap = new Map<string, Genus>();
    for (const g of allGenera) {
      genusMap.set(g.name_en.toLowerCase(), g);
    }

    // 기존 학명 목록 캐시 (중복 방지)
    const existingScientific = new Set<string>(
      (await this.speciesRepo.find({ select: ['scientific_name'] })).map((s) =>
        s.scientific_name.toLowerCase(),
      ),
    );

    const errors: { row: number; genus_name: string; reason: string }[] = [];
    const toSave: Species[] = [];

    for (let i = 0; i < rows.length; i++) {
      const row = rows[i];
      const rowNum = i + 1;

      // 필수값 검증
      if (
        !row.genus_name ||
        !row.species_kr ||
        !row.species_en ||
        !row.scientific_name
      ) {
        errors.push({
          row: rowNum,
          genus_name: row.genus_name ?? '',
          reason: '필수 항목 누락',
        });
        continue;
      }

      // CITES 일관성 검증
      if (row.is_cites && !row.cites_level) {
        errors.push({
          row: rowNum,
          genus_name: row.genus_name,
          reason: 'is_cites=true이지만 cites_level 누락',
        });
        continue;
      }

      // Genus 조회
      const genus = genusMap.get(row.genus_name.toLowerCase());
      if (!genus) {
        errors.push({
          row: rowNum,
          genus_name: row.genus_name,
          reason: `속(Genus) '${row.genus_name}'를 찾을 수 없음`,
        });
        continue;
      }

      // 학명 중복 확인
      if (existingScientific.has(row.scientific_name.toLowerCase())) {
        errors.push({
          row: rowNum,
          genus_name: row.genus_name,
          reason: `학명 '${row.scientific_name}' 중복`,
        });
        continue;
      }

      // 이번 배치 내 중복 방지
      existingScientific.add(row.scientific_name.toLowerCase());

      const entity = Object.assign(new Species(), {
        species_kr: row.species_kr,
        species_en: row.species_en,
        scientific_name: row.scientific_name,
        common_name_kr: row.common_name_kr ?? undefined,
        common_name_en: row.common_name_en ?? undefined,
        is_cites: row.is_cites,
        cites_level: row.is_cites ? row.cites_level : undefined,
        is_whitelist: row.is_whitelist,
        genus,
      } as Partial<Species>);
      toSave.push(entity);
    }

    if (toSave.length > 0) {
      await this.speciesRepo.save(toSave);
    }

    return {
      success: toSave.length,
      failed: errors.length,
      errors,
    };
  }
}
