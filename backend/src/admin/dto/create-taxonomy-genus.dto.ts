import { IsString, IsUUID, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateTaxonomyGenusDto {
  @ApiProperty({ description: '과(Family) ID' })
  @IsUUID()
  familyId: string;

  @ApiProperty({ description: '한국명', example: '비단뱀속' })
  @IsString()
  @MaxLength(100)
  name_kr: string;

  @ApiProperty({ description: '영명', example: 'Python' })
  @IsString()
  @MaxLength(100)
  name_en: string;
}
