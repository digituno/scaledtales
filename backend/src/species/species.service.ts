import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TaxonomyClass } from './entities/taxonomy-class.entity';
import { Order } from './entities/order.entity';
import { Family } from './entities/family.entity';
import { Genus } from './entities/genus.entity';
import { Species } from './entities/species.entity';
import { SearchSpeciesDto } from './dto/search-species.dto';

@Injectable()
export class SpeciesService {
  constructor(
    @InjectRepository(TaxonomyClass)
    private classRepo: Repository<TaxonomyClass>,
    @InjectRepository(Order)
    private orderRepo: Repository<Order>,
    @InjectRepository(Family)
    private familyRepo: Repository<Family>,
    @InjectRepository(Genus)
    private genusRepo: Repository<Genus>,
    @InjectRepository(Species)
    private speciesRepo: Repository<Species>,
  ) {}

  async getClasses() {
    return this.classRepo.find({ order: { code: 'ASC' } });
  }

  async getOrdersByClass(classId: string) {
    return this.orderRepo.find({
      where: { classId },
      order: { name_en: 'ASC' },
    });
  }

  async getFamiliesByOrder(orderId: string) {
    return this.familyRepo.find({
      where: { orderId },
      order: { name_en: 'ASC' },
    });
  }

  async getGeneraByFamily(familyId: string) {
    return this.genusRepo.find({
      where: { familyId },
      order: { name_en: 'ASC' },
    });
  }

  async getSpeciesByGenus(genusId: string) {
    return this.speciesRepo.find({
      where: { genusId },
      order: { scientific_name: 'ASC' },
    });
  }

  async searchSpecies(dto: SearchSpeciesDto) {
    const qb = this.speciesRepo
      .createQueryBuilder('s')
      .innerJoin('s.genus', 'g')
      .innerJoin('g.family', 'f')
      .innerJoin('f.order', 'o')
      .innerJoin('o.taxonomyClass', 'c')
      .select([
        's.id',
        's.scientific_name',
        's.common_name_kr',
        's.common_name_en',
        's.species_kr',
        's.species_en',
        's.is_cites',
        's.cites_level',
        's.is_whitelist',
        'c.code',
      ]);

    // Text search across multiple fields
    const searchTerm = `%${dto.q}%`;
    qb.where(
      '(s.scientific_name ILIKE :q OR s.common_name_kr ILIKE :q OR s.common_name_en ILIKE :q OR s.species_kr ILIKE :q)',
      { q: searchTerm },
    );

    if (dto.class_code) {
      qb.andWhere('c.code = :classCode', { classCode: dto.class_code });
    }

    qb.orderBy('s.common_name_kr', 'ASC').limit(dto.limit);

    const results = await qb.getRawMany();

    return results.map((r) => ({
      id: r.s_id,
      scientific_name: r.s_scientific_name,
      common_name_kr: r.s_common_name_kr,
      common_name_en: r.s_common_name_en,
      species_kr: r.s_species_kr,
      species_en: r.s_species_en,
      class_code: r.c_code,
      is_cites: r.s_is_cites,
      cites_level: r.s_cites_level,
      is_whitelist: r.s_is_whitelist,
    }));
  }

  async getSpeciesById(id: string) {
    const species = await this.speciesRepo.findOne({
      where: { id },
      relations: {
        genus: {
          family: {
            order: {
              taxonomyClass: true,
            },
          },
        },
      },
    });

    if (!species) {
      throw new NotFoundException('종을 찾을 수 없습니다');
    }

    const { genus, ...speciesData } = species;
    const { family, ...genusData } = genus;
    const { order, ...familyData } = family;
    const { taxonomyClass, ...orderData } = order;

    return {
      id: speciesData.id,
      class: {
        id: taxonomyClass.id,
        name_kr: taxonomyClass.name_kr,
        name_en: taxonomyClass.name_en,
        code: taxonomyClass.code,
      },
      order: {
        id: orderData.id,
        name_kr: orderData.name_kr,
        name_en: orderData.name_en,
      },
      family: {
        id: familyData.id,
        name_kr: familyData.name_kr,
        name_en: familyData.name_en,
      },
      genus: {
        id: genusData.id,
        name_kr: genusData.name_kr,
        name_en: genusData.name_en,
      },
      species_kr: speciesData.species_kr,
      species_en: speciesData.species_en,
      scientific_name: speciesData.scientific_name,
      common_name_kr: speciesData.common_name_kr,
      common_name_en: speciesData.common_name_en,
      is_cites: speciesData.is_cites,
      cites_level: speciesData.cites_level,
      is_whitelist: speciesData.is_whitelist,
    };
  }
}
