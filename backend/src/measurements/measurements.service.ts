import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MeasurementLog } from './entities/measurement-log.entity';
import { Animal } from '@/animals/entities/animal.entity';
import { CreateMeasurementDto } from './dto/create-measurement.dto';
import { UpdateMeasurementDto } from './dto/update-measurement.dto';
import { QueryMeasurementDto } from './dto/query-measurement.dto';
import { verifyAnimalOwnership, buildPagination } from '@common/helpers';

@Injectable()
export class MeasurementsService {
  constructor(
    @InjectRepository(MeasurementLog)
    private readonly measurementRepository: Repository<MeasurementLog>,
    @InjectRepository(Animal)
    private readonly animalRepository: Repository<Animal>,
  ) {}

  async create(
    userId: string,
    animalId: string,
    dto: CreateMeasurementDto,
  ): Promise<MeasurementLog> {
    await verifyAnimalOwnership(this.animalRepository, animalId, userId);

    const measurement = this.measurementRepository.create({
      ...dto,
      animal_id: animalId,
    });
    return this.measurementRepository.save(measurement);
  }

  async findAll(userId: string, animalId: string, query: QueryMeasurementDto) {
    await verifyAnimalOwnership(this.animalRepository, animalId, userId);

    const { skip, take, buildResponse } = buildPagination<MeasurementLog>(
      query.page ?? 1,
      query.limit ?? 20,
    );

    const qb = this.measurementRepository
      .createQueryBuilder('m')
      .where('m.animal_id = :animalId', { animalId });

    if (query.from_date) {
      qb.andWhere('m.measured_date >= :from_date', {
        from_date: query.from_date,
      });
    }

    if (query.to_date) {
      qb.andWhere('m.measured_date <= :to_date', {
        to_date: query.to_date,
      });
    }

    qb.orderBy('m.measured_date', 'DESC');

    const total = await qb.getCount();
    const data = await qb.skip(skip).take(take).getMany();

    return buildResponse(data, total);
  }

  async update(
    userId: string,
    measurementId: string,
    dto: UpdateMeasurementDto,
  ): Promise<MeasurementLog> {
    const measurement = await this.measurementRepository.findOne({
      where: { id: measurementId },
      relations: ['animal'],
    });

    if (!measurement) {
      throw new NotFoundException('측정 기록을 찾을 수 없습니다');
    }

    if (measurement.animal.user_id !== userId) {
      throw new ForbiddenException('접근 권한이 없습니다');
    }

    Object.assign(measurement, dto);
    return this.measurementRepository.save(measurement);
  }

  async remove(userId: string, measurementId: string) {
    const measurement = await this.measurementRepository.findOne({
      where: { id: measurementId },
      relations: ['animal'],
    });

    if (!measurement) {
      throw new NotFoundException('측정 기록을 찾을 수 없습니다');
    }

    if (measurement.animal.user_id !== userId) {
      throw new ForbiddenException('접근 권한이 없습니다');
    }

    await this.measurementRepository.remove(measurement);
    return { id: measurementId, deleted: true };
  }
}
