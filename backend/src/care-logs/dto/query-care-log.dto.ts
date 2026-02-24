import {
  IsDateString,
  IsInt,
  IsOptional,
  IsString,
  Min,
  Max,
} from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class QueryCareLogDto {
  @ApiPropertyOptional({
    description: '일지 유형 필터 (콤마 구분, 예: FEEDING,SHEDDING)',
  })
  @IsOptional()
  @IsString()
  log_type?: string;

  @ApiPropertyOptional({ description: '시작 날짜 (ISO 8601)' })
  @IsOptional()
  @IsDateString()
  from_date?: string;

  @ApiPropertyOptional({ description: '종료 날짜 (ISO 8601)' })
  @IsOptional()
  @IsDateString()
  to_date?: string;

  @ApiPropertyOptional({ description: '페이지 번호', default: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number;

  @ApiPropertyOptional({ description: '페이지 크기', default: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;

  @ApiPropertyOptional({
    description: '정렬 기준',
    enum: ['log_date', 'created_at'],
    default: 'log_date',
  })
  @IsOptional()
  @IsString()
  sort?: string;

  @ApiPropertyOptional({
    description: '정렬 순서',
    enum: ['asc', 'desc'],
    default: 'desc',
  })
  @IsOptional()
  @IsString()
  order?: 'asc' | 'desc';
}
