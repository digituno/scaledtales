import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import {
  BadRequestException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { CareLogsService } from './care-logs.service';
import { CareLog } from './entities/care-log.entity';
import { Animal } from '@/animals/entities/animal.entity';
import { createMockRepository } from '@common/testing/mock-repository.helper';
import { LogType } from '@common/enums';

describe('CareLogsService', () => {
  let service: CareLogsService;
  let careLogRepo: ReturnType<typeof createMockRepository<CareLog>>;
  let animalRepo: ReturnType<typeof createMockRepository<Animal>>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CareLogsService,
        {
          provide: getRepositoryToken(CareLog),
          useFactory: createMockRepository,
        },
        {
          provide: getRepositoryToken(Animal),
          useFactory: createMockRepository,
        },
      ],
    }).compile();

    service = module.get<CareLogsService>(CareLogsService);
    careLogRepo = module.get(getRepositoryToken(CareLog));
    animalRepo = module.get(getRepositoryToken(Animal));
  });

  // ── findOne ──

  describe('findOne', () => {
    it('존재하지 않는 일지 → NotFoundException', async () => {
      careLogRepo.findOne!.mockResolvedValue(null);
      await expect(service.findOne('user1', 'log1')).rejects.toThrow(
        NotFoundException,
      );
    });

    it('다른 사용자의 일지 → ForbiddenException', async () => {
      careLogRepo.findOne!.mockResolvedValue({
        id: 'log1',
        user_id: 'other_user',
      });
      await expect(service.findOne('user1', 'log1')).rejects.toThrow(
        ForbiddenException,
      );
    });

    it('본인 일지 → CareLog 반환', async () => {
      const mockLog = {
        id: 'log1',
        user_id: 'user1',
        log_type: 'FEEDING',
        animal: { id: 'animal1' },
      };
      careLogRepo.findOne!.mockResolvedValue(mockLog);
      const result = await service.findOne('user1', 'log1');
      expect(result).toEqual(mockLog);
    });
  });

  // ── create - FEEDING 검증 ──

  describe('create - FEEDING 검증', () => {
    beforeEach(() => {
      animalRepo.findOne!.mockResolvedValue({
        id: 'animal1',
        user_id: 'user1',
      });
      careLogRepo.create!.mockImplementation((dto) => dto);
      careLogRepo.save!.mockImplementation((entity) =>
        Promise.resolve({ ...entity, id: 'new-id' }),
      );
    });

    it('food_type 없으면 BadRequestException', async () => {
      await expect(
        service.create('user1', 'animal1', {
          log_type: LogType.FEEDING,
          log_date: '2024-01-01T00:00:00Z',
          details: { food_item: '밀웜' } as any,
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('food_item 없으면 BadRequestException', async () => {
      await expect(
        service.create('user1', 'animal1', {
          log_type: LogType.FEEDING,
          log_date: '2024-01-01T00:00:00Z',
          details: { food_type: 'LIVE_INSECT' } as any,
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('유효한 FEEDING details → 생성 성공', async () => {
      const result = await service.create('user1', 'animal1', {
        log_type: LogType.FEEDING,
        log_date: '2024-01-01T00:00:00Z',
        details: { food_type: 'LIVE_INSECT', food_item: '밀웜' } as any,
      });
      expect(result.id).toBe('new-id');
    });
  });

  // ── create - 동물 소유권 검증 ──

  describe('create - 동물 소유권 검증', () => {
    it('존재하지 않는 동물 → NotFoundException', async () => {
      animalRepo.findOne!.mockResolvedValue(null);
      await expect(
        service.create('user1', 'animal1', {
          log_type: LogType.FEEDING,
          log_date: '2024-01-01T00:00:00Z',
          details: { food_type: 'LIVE_INSECT', food_item: '밀웜' } as any,
        }),
      ).rejects.toThrow(NotFoundException);
    });

    it('타인 소유 동물 → ForbiddenException', async () => {
      animalRepo.findOne!.mockResolvedValue({
        id: 'animal1',
        user_id: 'other_user',
      });
      await expect(
        service.create('user1', 'animal1', {
          log_type: LogType.FEEDING,
          log_date: '2024-01-01T00:00:00Z',
          details: { food_type: 'LIVE_INSECT', food_item: '밀웜' } as any,
        }),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  // ── remove ──

  describe('remove', () => {
    it('존재하지 않는 일지 → NotFoundException', async () => {
      careLogRepo.findOne!.mockResolvedValue(null);
      await expect(service.remove('user1', 'log1')).rejects.toThrow(
        NotFoundException,
      );
    });

    it('권한 없는 삭제 → ForbiddenException', async () => {
      careLogRepo.findOne!.mockResolvedValue({
        id: 'log1',
        user_id: 'other_user',
      });
      await expect(service.remove('user1', 'log1')).rejects.toThrow(
        ForbiddenException,
      );
    });

    it('본인 일지 삭제 성공 → { id, deleted: true }', async () => {
      const mockLog = { id: 'log1', user_id: 'user1' };
      careLogRepo.findOne!.mockResolvedValue(mockLog);
      careLogRepo.remove!.mockResolvedValue(mockLog);
      const result = await service.remove('user1', 'log1');
      expect(result).toEqual({ id: 'log1', deleted: true });
    });
  });

  // ── create - SHEDDING 검증 ──

  describe('create - SHEDDING 검증', () => {
    beforeEach(() => {
      animalRepo.findOne!.mockResolvedValue({
        id: 'animal1',
        user_id: 'user1',
      });
      careLogRepo.create!.mockImplementation((dto) => dto);
      careLogRepo.save!.mockImplementation((entity) =>
        Promise.resolve({ ...entity, id: 'new-id' }),
      );
    });

    it('shed_completion 없으면 BadRequestException', async () => {
      await expect(
        service.create('user1', 'animal1', {
          log_type: LogType.SHEDDING,
          log_date: '2024-01-01T00:00:00Z',
          details: {} as any,
        }),
      ).rejects.toThrow(BadRequestException);
    });

    it('유효한 SHEDDING details → 생성 성공', async () => {
      const result = await service.create('user1', 'animal1', {
        log_type: LogType.SHEDDING,
        log_date: '2024-01-01T00:00:00Z',
        details: { shed_completion: 'COMPLETE' } as any,
      });
      expect(result.id).toBe('new-id');
    });
  });
});
