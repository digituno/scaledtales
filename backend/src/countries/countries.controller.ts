import { Controller, Get, Query } from '@nestjs/common';
import { ApiOperation, ApiQuery, ApiTags } from '@nestjs/swagger';
import { CountriesService } from './countries.service';

@ApiTags('Countries')
@Controller('countries')
export class CountriesController {
  constructor(private readonly countriesService: CountriesService) {}

  @Get()
  @ApiOperation({ summary: '국가 목록 조회' })
  @ApiQuery({ name: 'lang', required: false, enum: ['ko', 'en'] })
  getCountries(@Query('lang') lang?: string) {
    return this.countriesService.getCountries(lang);
  }
}
