import { ForbiddenException, NotFoundException } from '@nestjs/common';
import { verifyAnimalOwnership } from './ownership.helper';
import { createMockRepository } from '@common/testing/mock-repository.helper';
import { Animal } from '@/animals/entities/animal.entity';

describe('verifyAnimalOwnership', () => {
  let animalRepo: ReturnType<typeof createMockRepository<Animal>>;

  beforeEach(() => {
    animalRepo = createMockRepository<Animal>();
  });

  it('동물 없으면 NotFoundException', async () => {
    animalRepo.findOne!.mockResolvedValue(null);

    await expect(
      verifyAnimalOwnership(animalRepo as any, 'animal1', 'user1'),
    ).rejects.toThrow(NotFoundException);
  });

  it('타인 소유 동물 → ForbiddenException', async () => {
    animalRepo.findOne!.mockResolvedValue({ id: 'animal1', user_id: 'other_user' });

    await expect(
      verifyAnimalOwnership(animalRepo as any, 'animal1', 'user1'),
    ).rejects.toThrow(ForbiddenException);
  });

  it('본인 소유 동물 → Animal 반환', async () => {
    const mockAnimal = { id: 'animal1', user_id: 'user1', name: '렉시' };
    animalRepo.findOne!.mockResolvedValue(mockAnimal);

    const result = await verifyAnimalOwnership(animalRepo as any, 'animal1', 'user1');

    expect(result).toEqual(mockAnimal);
    expect(animalRepo.findOne).toHaveBeenCalledWith({
      where: { id: 'animal1' },
    });
  });
});
