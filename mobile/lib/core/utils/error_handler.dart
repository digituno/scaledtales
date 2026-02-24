import 'package:dio/dio.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// DioException 또는 일반 예외를 사용자 친화적인 메시지로 변환합니다.
String getErrorMessage(Object error, AppLocalizations l10n) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return l10n.networkErrorMessage;
      case DioExceptionType.badResponse:
        // 서버에서 내려준 error.message 우선 사용
        final serverMsg =
            error.response?.data?['error']?['message'] as String?;
        if (serverMsg != null && serverMsg.isNotEmpty) return serverMsg;
        return l10n.errorMessage;
      default:
        return l10n.networkErrorMessage;
    }
  }
  return l10n.errorMessage;
}
