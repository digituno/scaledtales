import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { ForbiddenException, NotFoundException } from '@nestjs/common';
import { MeasurementsService } from './measurements.service';
import { MeasurementLog } from './entities/measurement-log.entity';
import { Animal } from '@/animals/entities/animal.entity';
import { createMockRepository } from '@common/testing/mock-repository.helper';

describe('MeasurementsService', () => {
  let service: MeasurementsService;
  let measurementRepo: ReturnType<typeof createMockRepository<MeasurementLog>>;
  let animalRepo: ReturnType<typeof createMockRepository<Animal>>;

  const mockAnimal = { id: 'animal1', user_id: 'user1' };
  const mockMeasurement = {
    id: 'meas1',
    animal_id: 'animal1',
    animal: mockAnimal,
    weight: 150,
    length: 30,
    measured_date: new Date('2024-01-01'),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        MeasurementsService,
        {
          provide: getRepositoryToken(MeasurementLog),
          useFactory: createMockRepository,
        },
        {
          provide: getRepositoryToken(Animal),
          useFactory: createMockRepository,
        },
      ],
    }).compile();

    service = module.get<MeasurementsService>(MeasurementsService);
    measurementRepo = module.get(getRepositoryToken(MeasurementLog));
    animalRepo = module.get(getRepositoryToken(Animal));
  });

  // ── create - 동물 소유권 검증 ──

  describe('create', () => {
    it('존재하지 않는 동물 → NotFoundException', async () => {
      animalRepo.findOne!.mockResolvedValue(null);
      await expect(
        service.create('user1', 'animal1', {
          weight: 150,
          measured_date: '2024-01-01',
        } as any),
      ).rejects.toThrow(NotFoundException);
    });

    it('타인 소유 동물 → ForbiddenException', async () => {
      animalRepo.findOne!.mockResolvedValue({
        id: 'animal1',
        user_id: 'other_user',
      });
      await expect(
        service.create('user1', 'animal1', {
          weight: 150,
          measured_date: '2024-01-01',
        } as any),
      ).rejects.toThrow(ForbiddenException);
    });

    it('본인 동물 → 측정 기록 생성 성공', async () => {
      animalRepo.findOne!.mockResolvedValue(mockAnimal);
      measurementRepo.create!.mockReturnValue(mockMeasurement);
      measurementRepo.save!.mockResolvedValue(mockMeasurement);

      const result = await service.create('user1', 'animal1', {
        weight: 150,
        measured_date: '2024-01-01',
      } as any);

      expect(result).toEqual(mockMeasurement);
      expect(measurementRepo.create).toHaveBeenCalledWith(
        expect.objectContaining({ animal_id: 'animal1' }),
      );
    });
  });

  // ── findAll - 날짜 범위 필터 ──

  describe('findAll', () => {
    it('동물 소유권 검증 통과 후 페이지네이션 결과 반환', async () => {
      animalRepo.findOne!.mockResolvedValue(mockAnimal);

      const mockQb = {
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        orderBy: jest.fn().mockReturnThis(),
        skip: jest.fn().mockReturnThis(),
        take: jest.fn().mockReturnThis(),
        getCount: jest.fn().mockResolvedValue(1),
        getMany: jest.fn().mockResolvedValue([mockMeasurement]),
      };
      measurementRepo.createQueryBuilder!.mockReturnValue(mockQb as any);

      const result = await service.findAll('user1', 'animal1', {
        page: 1,
        limit: 20,
      } as any);

      expect(result.data).toHaveLength(1);
      expect(result.pagination.total).toBe(1);
    });

    it('from_date 필터 → andWhere 호출 확인', async () => {
      animalRepo.findOne!.mockResolvedValue(mockAnimal);

      const mockQb = {
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        orderBy: jest.fn().mockReturnThis(),
        skip: jest.fn().mockReturnThis(),
        take: jest.fn().mockReturnThis(),
        getCount: jest.fn().mockResolvedValue(0),
        getMany: jest.fn().mockResolvedValue([]),
      };
      measurementRepo.createQueryBuilder!.mockReturnValue(mockQb as any);

      await service.findAll('user1', 'animal1', {
        page: 1,
        limit: 20,
        from_date: '2024-01-01',
      } as any);

      expect(mockQb.andWhere).toHaveBeenCalledWith(
        expect.stringContaining('from_date'),
        expect.any(Object),
      );
    });
  });

  // ── update ──

  describe('update', () => {
    it('존재하지 않는 측정 기록 → NotFoundException', async () => {
      measurementRepo.findOne!.mockResolvedValue(null);
      await expect(
        service.update('user1', 'meas1', { weight: 160 } as any),
      ).rejects.toThrow(NotFoundException);
    });

    it('타인 소유 측정 기록 → ForbiddenException', async () => {
      measurementRepo.findOne!.mockResolvedValue({
        ...mockMeasurement,
        animal: { user_id: 'other_user' },
      });
      await expect(
        service.update('user1', 'meas1', { weight: 160 } as any),
      ).rejects.toThrow(ForbiddenException);
    });

    it('본인 측정 기록 수정 성공', async () => {
      const updated = { ...mockMeasurement, weight: 160 };
      measurementRepo.findOne!.mockResolvedValue(mockMeasurement);
      measurementRepo.save!.mockResolvedValue(updated);

      const result = await service.update('user1', 'meas1', {
        weight: 160,
      } as any);
      expect(result.weight).toBe(160);
    });
  });

  // ── remove ──

  describe('remove', () => {
    it('존재하지 않는 측정 기록 → NotFoundException', async () => {
      measurementRepo.findOne!.mockResolvedValue(null);
      await expect(service.remove('user1', 'meas1')).rejects.toThrow(
        NotFoundException,
      );
    });

    it('타인 소유 측정 기록 삭제 → ForbiddenException', async () => {
      measurementRepo.findOne!.mockResolvedValue({
        ...mockMeasurement,
        animal: { user_id: 'other_user' },
      });
      await expect(service.remove('user1', 'meas1')).rejects.toThrow(
        ForbiddenException,
      );
    });

    it('본인 측정 기록 삭제 성공 → { id, deleted: true }', async () => {
      measurementRepo.findOne!.mockResolvedValue(mockMeasurement);
      measurementRepo.remove!.mockResolvedValue(mockMeasurement);
      const result = await service.remove('user1', 'meas1');
      expect(result).toEqual({ id: 'meas1', deleted: true });
    });
  });
});
