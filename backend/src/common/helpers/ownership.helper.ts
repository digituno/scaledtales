import { ForbiddenException, NotFoundException } from '@nestjs/common';
import { Repository } from 'typeorm';
import { Animal } from '@/animals/entities/animal.entity';

/**
 * 개체 소유권 검증 헬퍼.
 *
 * animalId에 해당하는 Animal을 조회하고, userId가 소유자인지 확인한다.
 * - 개체가 없으면 NotFoundException
 * - 소유자가 다르면 ForbiddenException
 *
 * @returns 검증된 Animal 엔티티
 */
export async function verifyAnimalOwnership(
  animalRepository: Repository<Animal>,
  animalId: string,
  userId: string,
): Promise<Animal> {
  const animal = await animalRepository.findOne({ where: { id: animalId } });
  if (!animal) {
    throw new NotFoundException('개체를 찾을 수 없습니다');
  }
  if (animal.user_id !== userId) {
    throw new ForbiddenException('접근 권한이 없습니다');
  }
  return animal;
}
