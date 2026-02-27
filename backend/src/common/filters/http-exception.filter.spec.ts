import { HttpException, HttpStatus } from '@nestjs/common';
import { GlobalExceptionFilter } from './http-exception.filter';

describe('GlobalExceptionFilter', () => {
  let filter: GlobalExceptionFilter;
  let mockResponse: { status: jest.Mock; json: jest.Mock };
  let mockHost: any;

  beforeEach(() => {
    filter = new GlobalExceptionFilter();

    mockResponse = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    };

    mockHost = {
      switchToHttp: jest.fn().mockReturnValue({
        getResponse: () => mockResponse,
        getRequest: () => ({ url: '/test', method: 'GET' }),
      }),
    };
  });

  // ── HttpException → 표준 오류 응답 변환 ──

  describe('HttpException 처리', () => {
    it('400 BadRequestException → INVALID_INPUT + 기본 한국어 메시지', () => {
      filter.catch(
        new HttpException('잘못된 요청입니다', HttpStatus.BAD_REQUEST),
        mockHost,
      );

      expect(mockResponse.status).toHaveBeenCalledWith(400);
      expect(mockResponse.json).toHaveBeenCalledWith({
        success: false,
        error: {
          code: 'INVALID_INPUT',
          message: '잘못된 요청입니다',
        },
      });
    });

    it('401 UnauthorizedException → UNAUTHORIZED + 기본 메시지', () => {
      filter.catch(
        new HttpException('Unauthorized', HttpStatus.UNAUTHORIZED),
        mockHost,
      );

      expect(mockResponse.status).toHaveBeenCalledWith(401);
      expect(mockResponse.json).toHaveBeenCalledWith(
        expect.objectContaining({
          success: false,
          error: expect.objectContaining({ code: 'UNAUTHORIZED' }),
        }),
      );
    });

    it('403 ForbiddenException → FORBIDDEN', () => {
      filter.catch(
        new HttpException('Forbidden', HttpStatus.FORBIDDEN),
        mockHost,
      );

      expect(mockResponse.status).toHaveBeenCalledWith(403);
      expect(mockResponse.json).toHaveBeenCalledWith(
        expect.objectContaining({
          error: expect.objectContaining({ code: 'FORBIDDEN' }),
        }),
      );
    });

    it('404 NotFoundException → NOT_FOUND', () => {
      filter.catch(
        new HttpException('Not Found', HttpStatus.NOT_FOUND),
        mockHost,
      );

      expect(mockResponse.status).toHaveBeenCalledWith(404);
      expect(mockResponse.json).toHaveBeenCalledWith(
        expect.objectContaining({
          error: expect.objectContaining({ code: 'NOT_FOUND' }),
        }),
      );
    });

    it('409 ConflictException → DUPLICATE', () => {
      filter.catch(
        new HttpException('Conflict', HttpStatus.CONFLICT),
        mockHost,
      );

      expect(mockResponse.status).toHaveBeenCalledWith(409);
      expect(mockResponse.json).toHaveBeenCalledWith(
        expect.objectContaining({
          error: expect.objectContaining({ code: 'DUPLICATE' }),
        }),
      );
    });

    it('422 UnprocessableEntityException → VALIDATION_ERROR', () => {
      filter.catch(
        new HttpException('Unprocessable', HttpStatus.UNPROCESSABLE_ENTITY),
        mockHost,
      );

      expect(mockResponse.status).toHaveBeenCalledWith(422);
      expect(mockResponse.json).toHaveBeenCalledWith(
        expect.objectContaining({
          error: expect.objectContaining({ code: 'VALIDATION_ERROR' }),
        }),
      );
    });
  });

  // ── 커스텀 메시지 우선 처리 ──

  describe('커스텀 메시지 처리', () => {
    it('서비스에서 직접 던진 문자열 메시지 → 우선 사용', () => {
      filter.catch(
        new HttpException('개체를 찾을 수 없습니다', HttpStatus.NOT_FOUND),
        mockHost,
      );

      const jsonArg = mockResponse.json.mock.calls[0][0];
      expect(jsonArg.error.message).toBe('개체를 찾을 수 없습니다');
    });

    it('object 응답의 message 문자열 → 우선 사용', () => {
      filter.catch(
        new HttpException(
          { statusCode: 404, message: '일지를 찾을 수 없습니다' },
          HttpStatus.NOT_FOUND,
        ),
        mockHost,
      );

      const jsonArg = mockResponse.json.mock.calls[0][0];
      expect(jsonArg.error.message).toBe('일지를 찾을 수 없습니다');
    });
  });

  // ── class-validator 배열 오류 처리 ──

  describe('class-validator 배열 오류 처리', () => {
    it('message가 배열이면 details에 담고 기본 메시지 유지', () => {
      filter.catch(
        new HttpException(
          {
            statusCode: 400,
            message: [
              'food_type은 필수입니다',
              'food_item은 문자열이어야 합니다',
            ],
            error: 'Bad Request',
          },
          HttpStatus.BAD_REQUEST,
        ),
        mockHost,
      );

      const jsonArg = mockResponse.json.mock.calls[0][0];
      expect(jsonArg.error.message).toBe('잘못된 요청입니다');
      expect(jsonArg.error.details).toEqual([
        'food_type은 필수입니다',
        'food_item은 문자열이어야 합니다',
      ]);
    });
  });

  // ── 알 수 없는 예외 처리 ──

  describe('알 수 없는 예외 처리', () => {
    it('일반 Error → 500 / SERVER_ERROR', () => {
      filter.catch(new Error('Unexpected DB error'), mockHost);

      expect(mockResponse.status).toHaveBeenCalledWith(500);
      expect(mockResponse.json).toHaveBeenCalledWith({
        success: false,
        error: {
          code: 'SERVER_ERROR',
          message: '서버 오류가 발생했습니다',
        },
      });
    });

    it('null/undefined 예외 → 500 / SERVER_ERROR', () => {
      filter.catch(null, mockHost);

      expect(mockResponse.status).toHaveBeenCalledWith(500);
      expect(mockResponse.json).toHaveBeenCalledWith(
        expect.objectContaining({
          success: false,
          error: expect.objectContaining({ code: 'SERVER_ERROR' }),
        }),
      );
    });
  });
});
