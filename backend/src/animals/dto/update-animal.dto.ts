import { PartialType } from '@nestjs/swagger';
import { IsOptional, IsDateString } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { CreateAnimalDto } from './create-animal.dto';

export class UpdateAnimalDto extends PartialType(CreateAnimalDto) {
  @ApiPropertyOptional({ description: '사망일 (상태가 DECEASED일 때)' })
  @IsOptional()
  @IsDateString()
  deceased_date?: string;
}
