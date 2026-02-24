import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, IsIn, IsInt, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';

export class SearchSpeciesDto {
  @ApiPropertyOptional({ description: '검색어' })
  @IsString()
  q: string;

  @ApiPropertyOptional({ enum: ['ko', 'en'], default: 'ko' })
  @IsOptional()
  @IsIn(['ko', 'en'])
  lang?: string = 'ko';

  @ApiPropertyOptional({ enum: ['REPTILE', 'AMPHIBIAN'] })
  @IsOptional()
  @IsIn(['REPTILE', 'AMPHIBIAN'])
  class_code?: string;

  @ApiPropertyOptional({ default: 20, maximum: 100 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;
}
