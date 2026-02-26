import { IsString, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateTaxonomyClassDto {
  @ApiProperty({ description: '한국명', example: '파충류' })
  @IsString()
  @MaxLength(100)
  name_kr: string;

  @ApiProperty({ description: '영명', example: 'Reptilia' })
  @IsString()
  @MaxLength(100)
  name_en: string;

  @ApiProperty({ description: '고유 코드 (대문자 영문)', example: 'REPTILIA' })
  @IsString()
  @MaxLength(20)
  code: string;
}
