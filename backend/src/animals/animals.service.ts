import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Animal } from './entities/animal.entity';
import { CreateAnimalDto } from './dto/create-animal.dto';
import { UpdateAnimalDto } from './dto/update-animal.dto';
import { QueryAnimalDto } from './dto/query-animal.dto';
import { buildPagination } from '@common/helpers';

@Injectable()
export class AnimalsService {
  constructor(
    @InjectRepository(Animal)
    private readonly animalRepository: Repository<Animal>,
  ) {}

  async create(userId: string, dto: CreateAnimalDto): Promise<Animal> {
    const animal = this.animalRepository.create({
      ...dto,
      user_id: userId,
    });
    const saved = await this.animalRepository.save(animal);
    return this.findOne(userId, saved.id);
  }

  async findAll(userId: string, query: QueryAnimalDto) {
    const status = query.status;
    const species_id = query.species_id;
    const sort = query.sort ?? 'created_at';
    const order = query.order ?? 'desc';

    const { skip, take, buildResponse } = buildPagination<Animal>(
      query.page ?? 1,
      query.limit ?? 20,
    );

    const qb = this.animalRepository
      .createQueryBuilder('animal')
      .leftJoinAndSelect('animal.species', 'species')
      .where('animal.user_id = :userId', { userId });

    if (status) {
      qb.andWhere('animal.status = :status', { status });
    }

    if (species_id) {
      qb.andWhere('animal.species_id = :species_id', { species_id });
    }

    const allowedSorts = ['name', 'created_at', 'acquisition_date'];
    const sortField = allowedSorts.includes(sort) ? sort : 'created_at';
    const sortOrder = order.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
    qb.orderBy(`animal.${sortField}`, sortOrder);

    const total = await qb.getCount();
    const data = await qb.skip(skip).take(take).getMany();

    return buildResponse(data, total);
  }

  async findOne(userId: string, id: string): Promise<Animal> {
    const animal = await this.animalRepository.findOne({
      where: { id },
      relations: ['species', 'father', 'mother'],
    });

    if (!animal) {
      throw new NotFoundException('개체를 찾을 수 없습니다');
    }

    if (animal.user_id !== userId) {
      throw new ForbiddenException('접근 권한이 없습니다');
    }

    return animal;
  }

  async update(
    userId: string,
    id: string,
    dto: UpdateAnimalDto,
  ): Promise<Animal> {
    const animal = await this.findOne(userId, id);
    Object.assign(animal, dto);
    await this.animalRepository.save(animal);
    return this.findOne(userId, id);
  }

  async remove(userId: string, id: string) {
    const animal = await this.findOne(userId, id);
    await this.animalRepository.remove(animal);
    return { id, deleted: true };
  }

  async findByUser(userId: string): Promise<Animal[]> {
    return this.animalRepository.find({
      where: { user_id: userId, status: 'ALIVE' },
      relations: ['species'],
      order: { name: 'ASC' },
    });
  }
}
