import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, MaxLength, IsISO8601 } from 'class-validator';

export class CreateAnnouncementDto {
  @ApiProperty({ description: '공지 제목', maxLength: 200 })
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  title: string;

  @ApiProperty({ description: '공지 내용' })
  @IsString()
  @IsNotEmpty()
  content: string;

  @ApiProperty({
    description: '공지 시작 일시 (ISO 8601)',
    example: '2026-01-01T00:00:00Z',
  })
  @IsISO8601()
  start_at: string;

  @ApiProperty({
    description: '공지 종료 일시 (ISO 8601)',
    example: '2026-12-31T23:59:59Z',
  })
  @IsISO8601()
  end_at: string;
}
