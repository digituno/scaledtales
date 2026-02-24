import { IsOptional, IsEnum, IsInt, IsString, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { AnimalStatus } from '@common/enums';

export class QueryAnimalDto {
  @ApiPropertyOptional({ description: '상태 필터', enum: AnimalStatus })
  @IsOptional()
  @IsEnum(AnimalStatus)
  status?: AnimalStatus;

  @ApiPropertyOptional({ description: '종 ID 필터' })
  @IsOptional()
  @IsString()
  species_id?: string;

  @ApiPropertyOptional({ description: '페이지 번호', default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ description: '페이지 크기', default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;

  @ApiPropertyOptional({
    description: '정렬 기준',
    enum: ['name', 'created_at', 'acquisition_date'],
    default: 'created_at',
  })
  @IsOptional()
  @IsString()
  sort?: string = 'created_at';

  @ApiPropertyOptional({
    description: '정렬 순서',
    enum: ['asc', 'desc'],
    default: 'desc',
  })
  @IsOptional()
  @IsString()
  order?: 'asc' | 'desc' = 'desc';
}
