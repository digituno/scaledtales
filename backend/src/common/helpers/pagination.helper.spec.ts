import { buildPagination } from './pagination.helper';

describe('buildPagination', () => {
  // ── skip/take 계산 ──

  describe('skip/take 계산', () => {
    it('1페이지 → skip: 0', () => {
      const { skip, take } = buildPagination(1, 20);
      expect(skip).toBe(0);
      expect(take).toBe(20);
    });

    it('2페이지, limit 20 → skip: 20', () => {
      const { skip, take } = buildPagination(2, 20);
      expect(skip).toBe(20);
      expect(take).toBe(20);
    });

    it('3페이지, limit 10 → skip: 20', () => {
      const { skip, take } = buildPagination(3, 10);
      expect(skip).toBe(20);
      expect(take).toBe(10);
    });

    it('기본값 (page/limit 미전달) → skip: 0, take: 20', () => {
      const { skip, take } = buildPagination();
      expect(skip).toBe(0);
      expect(take).toBe(20);
    });
  });

  // ── buildResponse ──

  describe('buildResponse', () => {
    it('데이터와 total을 받아 paginated 응답 생성', () => {
      const { buildResponse } = buildPagination<{ id: string }>(1, 20);
      const data = [{ id: 'a' }, { id: 'b' }];
      const result = buildResponse(data, 2);

      expect(result).toEqual({
        data: [{ id: 'a' }, { id: 'b' }],
        pagination: {
          page: 1,
          limit: 20,
          total: 2,
          totalPages: 1,
        },
      });
    });

    it('totalPages는 Math.ceil(total/limit) — 35개, limit 10 → 4페이지', () => {
      const { buildResponse } = buildPagination(1, 10);
      const result = buildResponse([], 35);

      expect(result.pagination.totalPages).toBe(4);
    });

    it('totalPages — 30개, limit 10 → 3페이지 (나머지 없음)', () => {
      const { buildResponse } = buildPagination(1, 10);
      const result = buildResponse([], 30);

      expect(result.pagination.totalPages).toBe(3);
    });

    it('데이터 0개 → totalPages: 0', () => {
      const { buildResponse } = buildPagination(1, 20);
      const result = buildResponse([], 0);

      expect(result.pagination.totalPages).toBe(0);
      expect(result.data).toHaveLength(0);
    });

    it('page, limit이 응답에 그대로 반영', () => {
      const { buildResponse } = buildPagination(3, 5);
      const result = buildResponse([], 100);

      expect(result.pagination.page).toBe(3);
      expect(result.pagination.limit).toBe(5);
    });
  });
});
