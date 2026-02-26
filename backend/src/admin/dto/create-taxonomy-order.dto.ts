import { IsString, IsUUID, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateTaxonomyOrderDto {
  @ApiProperty({ description: '강(Class) ID' })
  @IsUUID()
  classId: string;

  @ApiProperty({ description: '한국명', example: '유린목' })
  @IsString()
  @MaxLength(100)
  name_kr: string;

  @ApiProperty({ description: '영명', example: 'Squamata' })
  @IsString()
  @MaxLength(100)
  name_en: string;
}
