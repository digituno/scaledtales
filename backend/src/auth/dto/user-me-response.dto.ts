import { ApiProperty } from '@nestjs/swagger';

export class UserMeResponseDto {
  @ApiProperty({ description: '사용자 UUID' })
  id: string;

  @ApiProperty({ description: '이메일 주소' })
  email: string;

  @ApiProperty({
    description: '사용자 역할',
    enum: ['admin', 'seller', 'pro_breeder', 'user', 'suspended'],
    example: 'user',
  })
  role: string;

  @ApiProperty({ description: '가입일시 (ISO 8601)' })
  created_at: string;
}
