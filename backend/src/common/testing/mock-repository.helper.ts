import { ObjectLiteral, Repository } from 'typeorm';

/**
 * TypeORM Repository의 Mock 팩토리.
 * 단위 테스트에서 DB 없이 서비스를 테스트할 수 있게 한다.
 *
 * 사용법:
 *   providers: [
 *     { provide: getRepositoryToken(Animal), useFactory: createMockRepository },
 *   ]
 */
export const createMockRepository = <T extends ObjectLiteral>(): Partial<
  Record<keyof Repository<T>, jest.Mock>
> => ({
  findOne: jest.fn(),
  find: jest.fn(),
  create: jest.fn(),
  save: jest.fn(),
  remove: jest.fn(),
  delete: jest.fn(),
  createQueryBuilder: jest.fn().mockReturnValue({
    where: jest.fn().mockReturnThis(),
    andWhere: jest.fn().mockReturnThis(),
    leftJoinAndSelect: jest.fn().mockReturnThis(),
    orderBy: jest.fn().mockReturnThis(),
    skip: jest.fn().mockReturnThis(),
    take: jest.fn().mockReturnThis(),
    getCount: jest.fn().mockResolvedValue(0),
    getMany: jest.fn().mockResolvedValue([]),
    getOne: jest.fn().mockResolvedValue(null),
    getRawMany: jest.fn().mockResolvedValue([]),
  }),
});
