import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Country } from './entities/country.entity';

@Injectable()
export class CountriesService {
  constructor(
    @InjectRepository(Country)
    private countryRepo: Repository<Country>,
  ) {}

  async getCountries(lang: string = 'ko') {
    const countries = await this.countryRepo.find({
      where: { is_active: true },
      order: { display_order: 'ASC' },
    });

    return countries.map((c) => ({
      code: c.code,
      name: lang === 'en' ? c.name_en : c.name_kr,
    }));
  }
}
