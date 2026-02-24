/**
 * 페이지네이션 계산 헬퍼.
 *
 * page/limit 값을 받아 skip, take와 응답 빌더를 반환한다.
 *
 * 사용 예시:
 * ```typescript
 * const { skip, take, buildResponse } = buildPagination(query.page, query.limit);
 * const total = await qb.getCount();
 * const data = await qb.skip(skip).take(take).getMany();
 * return buildResponse(data, total);
 * ```
 */
export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface PaginatedResult<T> {
  data: T[];
  pagination: PaginationMeta;
}

export interface PaginationHelper<T> {
  skip: number;
  take: number;
  buildResponse: (data: T[], total: number) => PaginatedResult<T>;
}

export function buildPagination<T>(
  page: number = 1,
  limit: number = 20,
): PaginationHelper<T> {
  const skip = (page - 1) * limit;
  return {
    skip,
    take: limit,
    buildResponse: (data: T[], total: number): PaginatedResult<T> => ({
      data,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    }),
  };
}
