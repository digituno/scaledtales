import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { Response } from 'express';

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let code = 'SERVER_ERROR';
    const defaultMessages: Record<number, string> = {
      [HttpStatus.BAD_REQUEST]: '잘못된 요청입니다',
      [HttpStatus.UNAUTHORIZED]: '인증이 필요합니다',
      [HttpStatus.FORBIDDEN]: '접근 권한이 없습니다',
      [HttpStatus.NOT_FOUND]: '요청한 리소스를 찾을 수 없습니다',
      [HttpStatus.CONFLICT]: '이미 존재하는 데이터입니다',
      [HttpStatus.UNPROCESSABLE_ENTITY]: '처리할 수 없는 요청입니다',
      [HttpStatus.INTERNAL_SERVER_ERROR]: '서버 오류가 발생했습니다',
    };
    let message = '서버 오류가 발생했습니다';
    let details: any = undefined;

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exceptionResponse = exception.getResponse();
      // 상태코드에 맞는 한국어 기본 메시지 설정
      message = defaultMessages[status] ?? '서버 오류가 발생했습니다';

      if (typeof exceptionResponse === 'object' && exceptionResponse !== null) {
        const res = exceptionResponse as any;
        // 서비스에서 직접 던진 메시지가 있으면 우선 사용
        if (res.message && typeof res.message === 'string') {
          message = res.message;
        } else if (Array.isArray(res.message)) {
          // class-validator 검증 오류 배열은 기본 메시지 유지
          details = res.message;
        }
        if (res.details) details = res.details;
      } else if (typeof exceptionResponse === 'string') {
        message = exceptionResponse;
      }

      switch (status) {
        case HttpStatus.BAD_REQUEST:
          code = 'INVALID_INPUT';
          break;
        case HttpStatus.UNAUTHORIZED:
          code = 'UNAUTHORIZED';
          break;
        case HttpStatus.FORBIDDEN:
          code = 'FORBIDDEN';
          break;
        case HttpStatus.NOT_FOUND:
          code = 'NOT_FOUND';
          break;
        case HttpStatus.UNPROCESSABLE_ENTITY:
          code = 'VALIDATION_ERROR';
          break;
        case HttpStatus.CONFLICT:
          code = 'DUPLICATE';
          break;
        default:
          code = 'SERVER_ERROR';
      }
    }

    response.status(status).json({
      success: false,
      error: {
        code,
        message,
        ...(details ? { details } : {}),
      },
    });
  }
}
