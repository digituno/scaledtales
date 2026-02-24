import { IsDateString, IsNumber, IsOptional, IsString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateMeasurementDto {
  @ApiProperty({ description: '측정 날짜 (YYYY-MM-DD)' })
  @IsDateString()
  measured_date: string;

  @ApiPropertyOptional({ description: '무게 (g)' })
  @IsOptional()
  @IsNumber()
  weight?: number;

  @ApiPropertyOptional({ description: '길이 (cm)' })
  @IsOptional()
  @IsNumber()
  length?: number;

  @ApiPropertyOptional({ description: '메모' })
  @IsOptional()
  @IsString()
  notes?: string;
}
