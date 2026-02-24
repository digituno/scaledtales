import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CareLog } from './entities/care-log.entity';
import { Animal } from '@/animals/entities/animal.entity';
import { CareLogsController } from './care-logs.controller';
import { CareLogsService } from './care-logs.service';

@Module({
  imports: [TypeOrmModule.forFeature([CareLog, Animal])],
  controllers: [CareLogsController],
  providers: [CareLogsService],
  exports: [CareLogsService],
})
export class CareLogsModule {}
