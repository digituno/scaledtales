import { IsString, IsUUID, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateTaxonomyFamilyDto {
  @ApiProperty({ description: '목(Order) ID' })
  @IsUUID()
  orderId: string;

  @ApiProperty({ description: '한국명', example: '비단뱀과' })
  @IsString()
  @MaxLength(100)
  name_kr: string;

  @ApiProperty({ description: '영명', example: 'Pythonidae' })
  @IsString()
  @MaxLength(100)
  name_en: string;
}
