import { Controller, Get, Query, Res } from '@nestjs/common';
import { ApiExcludeController } from '@nestjs/swagger';
import { Response } from 'express';

@ApiExcludeController()
@Controller('auth')
export class AuthCallbackController {
  @Get('confirm')
  handleEmailConfirm(@Query('code') code: string, @Res() res: Response) {
    const html = `
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>ScaledTales - 이메일 확인 완료</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      margin: 0;
      background: #f5f5f5;
      color: #333;
    }
    .card {
      background: white;
      border-radius: 16px;
      padding: 48px;
      text-align: center;
      box-shadow: 0 2px 12px rgba(0,0,0,0.1);
      max-width: 400px;
    }
    .icon { font-size: 64px; margin-bottom: 16px; }
    h1 { font-size: 24px; margin: 0 0 12px; }
    p { color: #666; line-height: 1.6; }
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">✅</div>
    <h1>이메일 확인 완료!</h1>
    <p>이메일이 성공적으로 인증되었습니다.<br>앱으로 돌아가서 로그인해주세요.</p>
  </div>
</body>
</html>`;
    res.type('html').send(html);
  }
}
