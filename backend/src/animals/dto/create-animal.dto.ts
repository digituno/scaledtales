import {
  IsString,
  IsUUID,
  IsEnum,
  IsOptional,
  IsInt,
  IsNumber,
  IsDateString,
  MaxLength,
  Min,
  Max,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  Sex,
  OriginType,
  AcquisitionSource,
  AnimalStatus,
} from '@common/enums';

export class CreateAnimalDto {
  @ApiProperty({ description: '종 ID' })
  @IsUUID()
  species_id: string;

  @ApiProperty({ description: '이름', maxLength: 100 })
  @IsString()
  @MaxLength(100)
  name: string;

  @ApiPropertyOptional({ description: '모프', maxLength: 200 })
  @IsOptional()
  @IsString()
  @MaxLength(200)
  morph?: string;

  @ApiProperty({ description: '성별', enum: Sex })
  @IsEnum(Sex)
  sex: Sex;

  @ApiPropertyOptional({ description: '출생 연도' })
  @IsOptional()
  @IsInt()
  birth_year?: number;

  @ApiPropertyOptional({ description: '출생 월 (1-12)' })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(12)
  birth_month?: number;

  @ApiPropertyOptional({ description: '출생 일 (1-31)' })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(31)
  birth_date?: number;

  @ApiProperty({ description: '출신 유형', enum: OriginType })
  @IsEnum(OriginType)
  origin_type: OriginType;

  @ApiPropertyOptional({ description: '출신 국가 코드 (ISO 3166-1 alpha-2)' })
  @IsOptional()
  @IsString()
  @MaxLength(2)
  origin_country?: string;

  @ApiProperty({ description: '입양 날짜 (YYYY-MM-DD)' })
  @IsDateString()
  acquisition_date: string;

  @ApiProperty({ description: '입양 경로', enum: AcquisitionSource })
  @IsEnum(AcquisitionSource)
  acquisition_source: AcquisitionSource;

  @ApiPropertyOptional({ description: '입양 메모' })
  @IsOptional()
  @IsString()
  acquisition_note?: string;

  @ApiPropertyOptional({ description: '아버지 개체 ID' })
  @IsOptional()
  @IsUUID()
  father_id?: string;

  @ApiPropertyOptional({ description: '어머니 개체 ID' })
  @IsOptional()
  @IsUUID()
  mother_id?: string;

  @ApiPropertyOptional({ description: '현재 무게 (g)' })
  @IsOptional()
  @IsNumber()
  current_weight?: number;

  @ApiPropertyOptional({ description: '현재 길이 (cm)' })
  @IsOptional()
  @IsNumber()
  current_length?: number;

  @ApiPropertyOptional({ description: '상태', enum: AnimalStatus })
  @IsOptional()
  @IsEnum(AnimalStatus)
  status?: AnimalStatus;

  @ApiPropertyOptional({ description: '프로필 이미지 URL' })
  @IsOptional()
  @IsString()
  profile_image_url?: string;

  @ApiPropertyOptional({ description: '메모' })
  @IsOptional()
  @IsString()
  notes?: string;
}
