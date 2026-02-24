import { of, lastValueFrom } from 'rxjs';
import { ExecutionContext } from '@nestjs/common';
import { ResponseInterceptor } from './response.interceptor';

describe('ResponseInterceptor', () => {
  let interceptor: ResponseInterceptor<any>;
  const mockContext = {} as ExecutionContext;

  beforeEach(() => {
    interceptor = new ResponseInterceptor();
  });

  const makeCallHandler = (data: any) => ({
    handle: jest.fn().mockReturnValue(of(data)),
  });

  // ── 단순 데이터 래핑 ──

  describe('단순 데이터 응답', () => {
    it('객체 데이터 → { success: true, data: {...} }', async () => {
      const mockData = { id: 'animal1', name: '렉시' };
      const result = await lastValueFrom(
        interceptor.intercept(mockContext, makeCallHandler(mockData)),
      );

      expect(result).toEqual({ success: true, data: mockData });
    });

    it('배열 데이터 → { success: true, data: [...] }', async () => {
      const mockData = [{ id: 'animal1' }, { id: 'animal2' }];
      const result = await lastValueFrom(
        interceptor.intercept(mockContext, makeCallHandler(mockData)),
      );

      expect(result).toEqual({ success: true, data: mockData });
    });

    it('null 데이터 → { success: true, data: null }', async () => {
      const result = await lastValueFrom(
        interceptor.intercept(mockContext, makeCallHandler(null)),
      );

      expect(result).toEqual({ success: true, data: null });
    });

    it('문자열 데이터 → { success: true, data: "..." }', async () => {
      const result = await lastValueFrom(
        interceptor.intercept(mockContext, makeCallHandler('ok')),
      );

      expect(result).toEqual({ success: true, data: 'ok' });
    });
  });

  // ── 페이지네이션 포함 응답 ──

  describe('페이지네이션 포함 응답', () => {
    it('pagination 필드 있으면 data/pagination 분리', async () => {
      const mockData = {
        data: [{ id: 'log1' }, { id: 'log2' }],
        pagination: {
          page: 1,
          limit: 20,
          total: 2,
          totalPages: 1,
        },
      };

      const result = await lastValueFrom(
        interceptor.intercept(mockContext, makeCallHandler(mockData)),
      );

      expect(result).toEqual({
        success: true,
        data: mockData.data,
        pagination: mockData.pagination,
      });
    });

    it('pagination의 totalPages 값 그대로 전달', async () => {
      const mockData = {
        data: [],
        pagination: { page: 2, limit: 10, total: 35, totalPages: 4 },
      };

      const result = await lastValueFrom(
        interceptor.intercept(mockContext, makeCallHandler(mockData)),
      );

      expect((result as any).pagination.totalPages).toBe(4);
    });

    it('pagination 없는 객체는 그대로 data로 포장', async () => {
      // pagination이 없는 일반 객체 (CareLog 상세 등)
      const mockData = { data: [1, 2, 3] }; // data 필드가 있지만 pagination 없음
      const result = await lastValueFrom(
        interceptor.intercept(mockContext, makeCallHandler(mockData)),
      );

      // pagination이 없으면 전체 객체가 data로 감싸임
      expect(result).toEqual({ success: true, data: mockData });
      expect((result as any).pagination).toBeUndefined();
    });
  });
});
