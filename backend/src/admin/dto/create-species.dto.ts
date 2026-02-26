import {
  IsString,
  IsUUID,
  IsBoolean,
  IsOptional,
  IsIn,
  MaxLength,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateSpeciesDto {
  @ApiProperty({ description: '속(Genus) ID' })
  @IsUUID()
  genusId: string;

  @ApiProperty({ description: '한국명' })
  @IsString()
  @MaxLength(100)
  species_kr: string;

  @ApiProperty({ description: '영명' })
  @IsString()
  @MaxLength(100)
  species_en: string;

  @ApiProperty({ description: '학명 (전체)' })
  @IsString()
  @MaxLength(200)
  scientific_name: string;

  @ApiPropertyOptional({ description: '일반명 (한국어)' })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  common_name_kr?: string;

  @ApiPropertyOptional({ description: '일반명 (영어)' })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  common_name_en?: string;

  @ApiProperty({ description: 'CITES 등재 여부' })
  @IsBoolean()
  is_cites: boolean;

  @ApiPropertyOptional({
    description: 'CITES 부속서 등급',
    enum: ['APPENDIX_I', 'APPENDIX_II', 'APPENDIX_III'],
  })
  @IsOptional()
  @IsIn(['APPENDIX_I', 'APPENDIX_II', 'APPENDIX_III'])
  cites_level?: string;

  @ApiProperty({ description: '백색목록 여부' })
  @IsBoolean()
  is_whitelist: boolean;
}
