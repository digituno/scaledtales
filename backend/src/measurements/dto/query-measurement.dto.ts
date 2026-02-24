import { IsDateString, IsInt, IsOptional, Min } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

export class QueryMeasurementDto {
  @ApiPropertyOptional({ description: '시작 날짜 (YYYY-MM-DD)' })
  @IsOptional()
  @IsDateString()
  from_date?: string;

  @ApiPropertyOptional({ description: '종료 날짜 (YYYY-MM-DD)' })
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
  limit?: number;
}
