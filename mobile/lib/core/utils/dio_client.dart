import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/api_constants.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(_AuthInterceptor());
  }
}

class _AuthInterceptor extends QueuedInterceptor {
  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    var session = Supabase.instance.client.auth.currentSession;

    if (session != null && session.isExpired && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final response =
            await Supabase.instance.client.auth.refreshSession();
        session = response.session;
      } catch (_) {
        // On refresh failure, try with existing session
      } finally {
        _isRefreshing = false;
      }
    }

    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      Supabase.instance.client.auth.signOut();
    }
    handler.next(err);
  }
}
