import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { ForbiddenException, NotFoundException } from '@nestjs/common';
import { AnimalsService } from './animals.service';
import { Animal } from './entities/animal.entity';
import { createMockRepository } from '@common/testing/mock-repository.helper';

describe('AnimalsService', () => {
  let service: AnimalsService;
  let animalRepo: ReturnType<typeof createMockRepository<Animal>>;

  const mockAnimal = {
    id: 'animal1',
    user_id: 'user1',
    name: '렉시',
    species: { id: 'species1' },
    father: null,
    mother: null,
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AnimalsService,
        {
          provide: getRepositoryToken(Animal),
          useFactory: createMockRepository,
        },
      ],
    }).compile();

    service = module.get<AnimalsService>(AnimalsService);
    animalRepo = module.get(getRepositoryToken(Animal));
  });

  // ── findOne ──

  describe('findOne', () => {
    it('존재하지 않는 개체 → NotFoundException', async () => {
      animalRepo.findOne!.mockResolvedValue(null);
      await expect(service.findOne('user1', 'animal1')).rejects.toThrow(
        NotFoundException,
      );
    });

    it('타인 소유 개체 → ForbiddenException', async () => {
      animalRepo.findOne!.mockResolvedValue({
        ...mockAnimal,
        user_id: 'other_user',
      });
      await expect(service.findOne('user1', 'animal1')).rejects.toThrow(
        ForbiddenException,
      );
    });

    it('본인 개체 → Animal 반환', async () => {
      animalRepo.findOne!.mockResolvedValue(mockAnimal);
      const result = await service.findOne('user1', 'animal1');
      expect(result).toEqual(mockAnimal);
      expect(result.id).toBe('animal1');
    });
  });

  // ── create ──

  describe('create', () => {
    it('정상 생성 → 저장 후 findOne 결과 반환', async () => {
      const saved = { id: 'new-animal', user_id: 'user1' };
      animalRepo.create!.mockReturnValue(saved);
      animalRepo.save!.mockResolvedValue(saved);
      // findOne은 save 이후 관계 포함 재조회
      animalRepo.findOne!.mockResolvedValue({
        ...saved,
        species: null,
        father: null,
        mother: null,
      });

      const result = await service.create('user1', {
        name: '도도',
        species_id: 'species1',
      } as any);

      expect(animalRepo.create).toHaveBeenCalledWith(
        expect.objectContaining({ user_id: 'user1' }),
      );
      expect(result.id).toBe('new-animal');
    });
  });

  // ── remove ──

  describe('remove', () => {
    it('존재하지 않는 개체 → NotFoundException', async () => {
      animalRepo.findOne!.mockResolvedValue(null);
      await expect(service.remove('user1', 'animal1')).rejects.toThrow(
        NotFoundException,
      );
    });

    it('타인 소유 개체 → ForbiddenException', async () => {
      animalRepo.findOne!.mockResolvedValue({
        ...mockAnimal,
        user_id: 'other_user',
      });
      await expect(service.remove('user1', 'animal1')).rejects.toThrow(
        ForbiddenException,
      );
    });

    it('본인 개체 삭제 성공 → { id, deleted: true }', async () => {
      animalRepo.findOne!.mockResolvedValue(mockAnimal);
      animalRepo.remove!.mockResolvedValue(mockAnimal);
      const result = await service.remove('user1', 'animal1');
      expect(result).toEqual({ id: 'animal1', deleted: true });
    });
  });

  // ── update ──

  describe('update', () => {
    it('존재하지 않는 개체 수정 → NotFoundException', async () => {
      animalRepo.findOne!.mockResolvedValue(null);
      await expect(
        service.update('user1', 'animal1', { name: '새이름' } as any),
      ).rejects.toThrow(NotFoundException);
    });

    it('타인 소유 개체 수정 → ForbiddenException', async () => {
      animalRepo.findOne!.mockResolvedValue({
        ...mockAnimal,
        user_id: 'other_user',
      });
      await expect(
        service.update('user1', 'animal1', { name: '새이름' } as any),
      ).rejects.toThrow(ForbiddenException);
    });
  });
});
