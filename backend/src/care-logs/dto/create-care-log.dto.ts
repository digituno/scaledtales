import {
  IsEnum,
  IsDateString,
  IsObject,
  IsOptional,
  IsString,
  IsArray,
  IsUUID,
  IsNumber,
  ValidateNested,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { LogType } from '@common/enums';
import { CareLogDetails } from '../types/care-log-details.types';

export class CareLogImageDto {
  @ApiProperty({ description: '이미지 URL' })
  @IsString()
  url: string;

  @ApiProperty({ description: '이미지 순서' })
  @IsNumber()
  order: number;

  @ApiPropertyOptional({ description: '이미지 설명' })
  @IsOptional()
  @IsString()
  caption?: string;
}

export class CreateCareLogDto {
  @ApiProperty({ description: '일지 유형', enum: LogType })
  @IsEnum(LogType)
  log_type: LogType;

  @ApiProperty({ description: '일지 날짜/시간 (ISO 8601)' })
  @IsDateString()
  log_date: string;

  @ApiProperty({
    description: '상세 정보 (JSONB) — LogType별 구조는 CareLogDetails 참조',
  })
  @IsObject()
  details: CareLogDetails;

  @ApiPropertyOptional({ description: '이미지 목록', type: [CareLogImageDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CareLogImageDto)
  images?: CareLogImageDto[];

  @ApiPropertyOptional({ description: '메모' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({ description: '연관 일지 ID (산란→검란→부화)' })
  @IsOptional()
  @IsUUID()
  parent_log_id?: string;
}
