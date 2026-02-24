import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MeasurementLog } from './entities/measurement-log.entity';
import { Animal } from '@/animals/entities/animal.entity';
import { MeasurementsController } from './measurements.controller';
import { MeasurementsService } from './measurements.service';

@Module({
  imports: [TypeOrmModule.forFeature([MeasurementLog, Animal])],
  controllers: [MeasurementsController],
  providers: [MeasurementsService],
  exports: [MeasurementsService],
})
export class MeasurementsModule {}
