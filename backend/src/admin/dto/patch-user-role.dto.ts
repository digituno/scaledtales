import { IsIn, IsNotEmpty } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class PatchUserRoleDto {
  @ApiProperty({
    description: '변경할 역할',
    enum: ['admin', 'seller', 'pro_breeder', 'user', 'suspended'],
  })
  @IsNotEmpty()
  @IsIn(['admin', 'seller', 'pro_breeder', 'user', 'suspended'])
  role: string;
}
