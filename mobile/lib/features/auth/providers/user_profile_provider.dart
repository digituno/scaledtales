import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/enums/enums.dart';
import '../../../core/utils/dio_client.dart';
import '../models/user_profile.dart';
import 'auth_provider.dart';

/// GET /auth/me 호출하여 UserProfile(role 포함)을 반환.
/// 인증되지 않은 상태에서는 null 반환.
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authState = ref.watch(authProvider);
  if (authState.status != AuthStatus.authenticated) return null;
  try {
    final response = await DioClient().dio.get(ApiConstants.authMe);
    final data = response.data['data'] as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  } on DioException {
    return null;
  }
});

/// UserProfile에서 role만 추출한 편의 Provider.
/// 로딩 중이거나 오류 시 안전하게 UserRole.user 반환.
final userRoleProvider = Provider<UserRole>((ref) {
  return ref.watch(userProfileProvider).when(
        data: (profile) => profile?.role ?? UserRole.user,
        loading: () => UserRole.user,
        error: (_, __) => UserRole.user,
      );
});
