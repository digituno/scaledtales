import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CareLog } from './entities/care-log.entity';
import { Animal } from '@/animals/entities/animal.entity';
import { CreateCareLogDto } from './dto/create-care-log.dto';
import { UpdateCareLogDto } from './dto/update-care-log.dto';
import { QueryCareLogDto } from './dto/query-care-log.dto';
import {
  LogType,
  FoodType,
  Unit,
  FeedingResponse,
  FeedingMethod,
  ShedCompletion,
  FecesConsistency,
  UrateCondition,
  MatingSuccess,
  IncubationMethod,
} from '@common/enums';
import { verifyAnimalOwnership, buildPagination } from '@common/helpers';
import {
  CareLogDetails,
  FeedingDetails,
  SheddingDetails,
  DefecationDetails,
  MatingDetails,
  EggLayingDetails,
  CandlingDetails,
  HatchingDetails,
} from './types/care-log-details.types';

@Injectable()
export class CareLogsService {
  constructor(
    @InjectRepository(CareLog)
    private readonly careLogRepository: Repository<CareLog>,
    @InjectRepository(Animal)
    private readonly animalRepository: Repository<Animal>,
  ) {}

  // ── Details Validation Dispatcher ──

  private validateDetails(logType: LogType, details: CareLogDetails): void {
    switch (logType) {
      case LogType.FEEDING:
        this.validateFeedingDetails(details as FeedingDetails);
        break;
      case LogType.SHEDDING:
        this.validateSheddingDetails(details as SheddingDetails);
        break;
      case LogType.DEFECATION:
        this.validateDefecationDetails(details as DefecationDetails);
        break;
      case LogType.MATING:
        this.validateMatingDetails(details as MatingDetails);
        break;
      case LogType.EGG_LAYING:
        this.validateEggLayingDetails(details as EggLayingDetails);
        break;
      case LogType.CANDLING:
        this.validateCandlingDetails(details as CandlingDetails);
        break;
      case LogType.HATCHING:
        this.validateHatchingDetails(details as HatchingDetails);
        break;
    }
  }

  // ── FEEDING ──

  private validateFeedingDetails(details: FeedingDetails): void {
    if (
      !details.food_type ||
      !(Object.values(FoodType) as string[]).includes(
        details.food_type as string,
      )
    ) {
      throw new BadRequestException(
        'food_type은 필수이며 유효한 값이어야 합니다',
      );
    }
    if (!details.food_item || typeof details.food_item !== 'string') {
      throw new BadRequestException('food_item은 필수이며 문자열이어야 합니다');
    }
    if (
      details.unit !== undefined &&
      !(Object.values(Unit) as string[]).includes(details.unit as string)
    ) {
      throw new BadRequestException('unit은 유효한 값이어야 합니다');
    }
    if (
      details.feeding_response !== undefined &&
      !(Object.values(FeedingResponse) as string[]).includes(
        details.feeding_response as string,
      )
    ) {
      throw new BadRequestException(
        'feeding_response는 유효한 값이어야 합니다',
      );
    }
    if (
      details.feeding_method !== undefined &&
      !(Object.values(FeedingMethod) as string[]).includes(
        details.feeding_method as string,
      )
    ) {
      throw new BadRequestException('feeding_method는 유효한 값이어야 합니다');
    }
  }

  // ── SHEDDING ──

  private validateSheddingDetails(details: SheddingDetails): void {
    if (
      !details.shed_completion ||
      !(Object.values(ShedCompletion) as string[]).includes(
        details.shed_completion as string,
      )
    ) {
      throw new BadRequestException(
        'shed_completion은 필수이며 유효한 값이어야 합니다',
      );
    }
    if (
      details.problem_areas !== undefined &&
      !Array.isArray(details.problem_areas)
    ) {
      throw new BadRequestException('problem_areas는 배열이어야 합니다');
    }
    if (
      details.assistance_needed !== undefined &&
      typeof details.assistance_needed !== 'boolean'
    ) {
      throw new BadRequestException('assistance_needed는 boolean이어야 합니다');
    }
    if (
      details.assistance_method !== undefined &&
      typeof details.assistance_method !== 'string'
    ) {
      throw new BadRequestException('assistance_method는 문자열이어야 합니다');
    }
    if (
      details.humidity_level !== undefined &&
      typeof details.humidity_level !== 'number'
    ) {
      throw new BadRequestException('humidity_level은 숫자여야 합니다');
    }
  }

  // ── DEFECATION ──

  private validateDefecationDetails(details: DefecationDetails): void {
    if (typeof details.feces_present !== 'boolean') {
      throw new BadRequestException(
        'feces_present는 필수이며 boolean이어야 합니다',
      );
    }
    if (typeof details.urate_present !== 'boolean') {
      throw new BadRequestException(
        'urate_present는 필수이며 boolean이어야 합니다',
      );
    }
    if (
      details.feces_consistency !== undefined &&
      !(Object.values(FecesConsistency) as string[]).includes(
        details.feces_consistency as string,
      )
    ) {
      throw new BadRequestException(
        'feces_consistency는 유효한 값이어야 합니다',
      );
    }
    if (
      details.feces_color !== undefined &&
      typeof details.feces_color !== 'string'
    ) {
      throw new BadRequestException('feces_color는 문자열이어야 합니다');
    }
    if (
      details.urate_condition !== undefined &&
      !(Object.values(UrateCondition) as string[]).includes(
        details.urate_condition as string,
      )
    ) {
      throw new BadRequestException('urate_condition은 유효한 값이어야 합니다');
    }
    if (
      details.abnormalities !== undefined &&
      typeof details.abnormalities !== 'string'
    ) {
      throw new BadRequestException('abnormalities는 문자열이어야 합니다');
    }
  }

  // ── MATING ──

  private validateMatingDetails(details: MatingDetails): void {
    if (
      !details.mating_success ||
      !(Object.values(MatingSuccess) as string[]).includes(
        details.mating_success as string,
      )
    ) {
      throw new BadRequestException(
        'mating_success는 필수이며 유효한 값이어야 합니다',
      );
    }
    if (
      details.partner_name !== undefined &&
      typeof details.partner_name !== 'string'
    ) {
      throw new BadRequestException('partner_name은 문자열이어야 합니다');
    }
    if (
      details.duration_minutes !== undefined &&
      typeof details.duration_minutes !== 'number'
    ) {
      throw new BadRequestException('duration_minutes는 숫자여야 합니다');
    }
    if (
      details.behavior_notes !== undefined &&
      typeof details.behavior_notes !== 'string'
    ) {
      throw new BadRequestException('behavior_notes는 문자열이어야 합니다');
    }
    if (details.expected_laying_date !== undefined) {
      const date = new Date(details.expected_laying_date);
      if (isNaN(date.getTime())) {
        throw new BadRequestException(
          'expected_laying_date는 유효한 날짜여야 합니다',
        );
      }
    }
  }

  // ── EGG_LAYING ──

  private validateEggLayingDetails(details: EggLayingDetails): void {
    if (
      details.egg_count === undefined ||
      typeof details.egg_count !== 'number'
    ) {
      throw new BadRequestException('egg_count는 필수이며 숫자여야 합니다');
    }
    if (typeof details.incubation_planned !== 'boolean') {
      throw new BadRequestException(
        'incubation_planned는 필수이며 boolean이어야 합니다',
      );
    }
    if (
      details.fertile_count !== undefined &&
      typeof details.fertile_count !== 'number'
    ) {
      throw new BadRequestException('fertile_count는 숫자여야 합니다');
    }
    if (
      details.infertile_count !== undefined &&
      typeof details.infertile_count !== 'number'
    ) {
      throw new BadRequestException('infertile_count는 숫자여야 합니다');
    }
    if (
      details.clutch_number !== undefined &&
      typeof details.clutch_number !== 'number'
    ) {
      throw new BadRequestException('clutch_number는 숫자여야 합니다');
    }
    if (
      details.incubation_method !== undefined &&
      !(Object.values(IncubationMethod) as string[]).includes(
        details.incubation_method as string,
      )
    ) {
      throw new BadRequestException(
        'incubation_method는 유효한 값이어야 합니다',
      );
    }
    if (
      details.incubation_temp !== undefined &&
      typeof details.incubation_temp !== 'number'
    ) {
      throw new BadRequestException('incubation_temp는 숫자여야 합니다');
    }
    if (
      details.incubation_humidity !== undefined &&
      typeof details.incubation_humidity !== 'number'
    ) {
      throw new BadRequestException('incubation_humidity는 숫자여야 합니다');
    }
    if (details.expected_hatch_date !== undefined) {
      const date = new Date(details.expected_hatch_date);
      if (isNaN(date.getTime())) {
        throw new BadRequestException(
          'expected_hatch_date는 유효한 날짜여야 합니다',
        );
      }
    }
  }

  // ── CANDLING ──

  private validateCandlingDetails(details: CandlingDetails): void {
    if (
      details.day_after_laying === undefined ||
      typeof details.day_after_laying !== 'number'
    ) {
      throw new BadRequestException(
        'day_after_laying은 필수이며 숫자여야 합니다',
      );
    }
    if (
      details.fertile_count === undefined ||
      typeof details.fertile_count !== 'number'
    ) {
      throw new BadRequestException('fertile_count는 필수이며 숫자여야 합니다');
    }
    if (
      details.infertile_count === undefined ||
      typeof details.infertile_count !== 'number'
    ) {
      throw new BadRequestException(
        'infertile_count는 필수이며 숫자여야 합니다',
      );
    }
    if (
      details.stopped_development === undefined ||
      typeof details.stopped_development !== 'number'
    ) {
      throw new BadRequestException(
        'stopped_development는 필수이며 숫자여야 합니다',
      );
    }
    if (
      details.total_viable === undefined ||
      typeof details.total_viable !== 'number'
    ) {
      throw new BadRequestException('total_viable은 필수이며 숫자여야 합니다');
    }
  }

  // ── HATCHING ──

  private validateHatchingDetails(details: HatchingDetails): void {
    if (
      details.hatched_count === undefined ||
      typeof details.hatched_count !== 'number'
    ) {
      throw new BadRequestException('hatched_count는 필수이며 숫자여야 합니다');
    }
    if (
      details.failed_count === undefined ||
      typeof details.failed_count !== 'number'
    ) {
      throw new BadRequestException('failed_count는 필수이며 숫자여야 합니다');
    }
    if (
      details.offspring_ids !== undefined &&
      !Array.isArray(details.offspring_ids)
    ) {
      throw new BadRequestException('offspring_ids는 배열이어야 합니다');
    }
    if (
      details.hatch_notes !== undefined &&
      typeof details.hatch_notes !== 'string'
    ) {
      throw new BadRequestException('hatch_notes는 문자열이어야 합니다');
    }
  }

  // ── Parent Log Chain Validation ──

  private async validateParentLogChain(
    userId: string,
    logType: string,
    parentLogId: string,
  ): Promise<void> {
    const parentLog = await this.careLogRepository.findOne({
      where: { id: parentLogId },
    });

    if (!parentLog) {
      throw new NotFoundException('부모 일지를 찾을 수 없습니다');
    }

    if (parentLog.user_id !== userId) {
      throw new ForbiddenException('부모 일지에 대한 접근 권한이 없습니다');
    }

    const type = logType as LogType;
    const parentType = parentLog.log_type as LogType;

    if (type === LogType.CANDLING || type === LogType.HATCHING) {
      if (parentType !== LogType.EGG_LAYING) {
        throw new BadRequestException(
          `${type} 일지의 부모는 EGG_LAYING이어야 합니다`,
        );
      }
    } else {
      throw new BadRequestException(
        `${type} 타입에는 parent_log_id를 지정할 수 없습니다`,
      );
    }
  }

  // ── CRUD Operations ──

  async create(
    userId: string,
    animalId: string,
    dto: CreateCareLogDto,
  ): Promise<CareLog> {
    await verifyAnimalOwnership(this.animalRepository, animalId, userId);
    this.validateDetails(dto.log_type, dto.details);

    if (dto.parent_log_id) {
      await this.validateParentLogChain(
        userId,
        dto.log_type,
        dto.parent_log_id,
      );
    }

    const careLog = this.careLogRepository.create({
      ...dto,
      animal_id: animalId,
      user_id: userId,
    });
    return this.careLogRepository.save(careLog);
  }

  async findAll(userId: string, animalId: string, query: QueryCareLogDto) {
    await verifyAnimalOwnership(this.animalRepository, animalId, userId);

    const { skip, take, buildResponse } = buildPagination<CareLog>(
      query.page ?? 1,
      query.limit ?? 20,
    );

    const qb = this.careLogRepository
      .createQueryBuilder('cl')
      .where('cl.animal_id = :animalId', { animalId });

    if (query.log_type) {
      const types = query.log_type.split(',').map((t) => t.trim());
      qb.andWhere('cl.log_type IN (:...types)', { types });
    }

    if (query.from_date) {
      qb.andWhere('cl.log_date >= :from_date', {
        from_date: query.from_date,
      });
    }

    if (query.to_date) {
      qb.andWhere('cl.log_date <= :to_date', { to_date: query.to_date });
    }

    const sortField =
      query.sort === 'created_at' ? 'cl.created_at' : 'cl.log_date';
    const sortOrder =
      query.order?.toUpperCase() === 'ASC' ? 'ASC' : ('DESC' as const);
    qb.orderBy(sortField, sortOrder);

    const total = await qb.getCount();
    const data = await qb.skip(skip).take(take).getMany();

    return buildResponse(data, total);
  }

  async findAllForUser(userId: string, query: QueryCareLogDto) {
    const { skip, take, buildResponse } = buildPagination<CareLog>(
      query.page ?? 1,
      query.limit ?? 20,
    );

    const qb = this.careLogRepository
      .createQueryBuilder('cl')
      .leftJoinAndSelect('cl.animal', 'animal')
      .where('cl.user_id = :userId', { userId });

    if (query.log_type) {
      const types = query.log_type.split(',').map((t) => t.trim());
      qb.andWhere('cl.log_type IN (:...types)', { types });
    }

    if (query.from_date) {
      qb.andWhere('cl.log_date >= :from_date', {
        from_date: query.from_date,
      });
    }

    if (query.to_date) {
      qb.andWhere('cl.log_date <= :to_date', { to_date: query.to_date });
    }

    const sortField =
      query.sort === 'created_at' ? 'cl.created_at' : 'cl.log_date';
    const sortOrder =
      query.order?.toUpperCase() === 'ASC' ? 'ASC' : ('DESC' as const);
    qb.orderBy(sortField, sortOrder);

    const total = await qb.getCount();
    const data = await qb.skip(skip).take(take).getMany();

    return buildResponse(data, total);
  }

  async findOne(userId: string, logId: string): Promise<CareLog> {
    const careLog = await this.careLogRepository.findOne({
      where: { id: logId },
      relations: ['animal'],
    });

    if (!careLog) {
      throw new NotFoundException('일지를 찾을 수 없습니다');
    }

    if (careLog.user_id !== userId) {
      throw new ForbiddenException('접근 권한이 없습니다');
    }

    return careLog;
  }

  async update(
    userId: string,
    logId: string,
    dto: UpdateCareLogDto,
  ): Promise<CareLog> {
    const careLog = await this.careLogRepository.findOne({
      where: { id: logId },
    });

    if (!careLog) {
      throw new NotFoundException('일지를 찾을 수 없습니다');
    }

    if (careLog.user_id !== userId) {
      throw new ForbiddenException('접근 권한이 없습니다');
    }

    if (dto.details) {
      const logType = (dto.log_type ?? careLog.log_type) as LogType;
      this.validateDetails(logType, dto.details);
    }

    Object.assign(careLog, dto);
    return this.careLogRepository.save(careLog);
  }

  async remove(userId: string, logId: string) {
    const careLog = await this.careLogRepository.findOne({
      where: { id: logId },
    });

    if (!careLog) {
      throw new NotFoundException('일지를 찾을 수 없습니다');
    }

    if (careLog.user_id !== userId) {
      throw new ForbiddenException('접근 권한이 없습니다');
    }

    await this.careLogRepository.remove(careLog);
    return { id: logId, deleted: true };
  }
}
