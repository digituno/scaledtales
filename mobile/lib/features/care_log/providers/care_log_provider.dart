import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/utils/dio_client.dart';
import '../models/care_log_model.dart';

// Care log list provider (per animal)
final careLogListProvider = AsyncNotifierProvider.family<
    CareLogListNotifier, List<CareLog>, String>(
  CareLogListNotifier.new,
);

class CareLogListNotifier extends FamilyAsyncNotifier<List<CareLog>, String> {
  @override
  Future<List<CareLog>> build(String arg) => fetchCareLogs(arg);

  Future<List<CareLog>> fetchCareLogs(String animalId) async {
    final response = await DioClient().dio.get(
      ApiConstants.careLogs(animalId),
      queryParameters: {'limit': 100},
    );
    final list = response.data['data'] as List;
    return list.map((e) => CareLog.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => fetchCareLogs(arg));
  }

  /// 케어 로그 생성. 성공 시 이 동물의 목록 갱신.
  Future<CareLog> create(Map<String, dynamic> data) async {
    final response = await DioClient().dio.post(
      ApiConstants.careLogs(arg),
      data: data,
    );
    final log = CareLog.fromJson(response.data['data'] as Map<String, dynamic>);
    state = await AsyncValue.guard(() => fetchCareLogs(arg));
    return log;
  }

  /// 케어 로그 수정.
  Future<CareLog> updateById(String logId, Map<String, dynamic> data) async {
    final response = await DioClient().dio.patch(
      ApiConstants.careLogDetail(logId),
      data: data,
    );
    final log = CareLog.fromJson(response.data['data'] as Map<String, dynamic>);
    state = await AsyncValue.guard(() => fetchCareLogs(arg));
    return log;
  }

  /// 케어 로그 삭제.
  Future<void> deleteCareLogById(String logId) async {
    await DioClient().dio.delete(ApiConstants.careLogDetail(logId));
    state = await AsyncValue.guard(() => fetchCareLogs(arg));
  }
}

// All care logs provider (for BottomNav Logs tab)
final allCareLogsProvider =
    AsyncNotifierProvider<AllCareLogsNotifier, List<CareLog>>(
  AllCareLogsNotifier.new,
);

class AllCareLogsNotifier extends AsyncNotifier<List<CareLog>> {
  @override
  Future<List<CareLog>> build() => fetchAllCareLogs();

  Future<List<CareLog>> fetchAllCareLogs() async {
    final response = await DioClient().dio.get(
      ApiConstants.allCareLogs,
      queryParameters: {'limit': 100},
    );
    final list = response.data['data'] as List;
    return list.map((e) => CareLog.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => fetchAllCareLogs());
  }

  /// 케어 로그 생성 (전체 목록 갱신).
  Future<CareLog> create(String animalId, Map<String, dynamic> data) async {
    final response = await DioClient().dio.post(
      ApiConstants.careLogs(animalId),
      data: data,
    );
    final log = CareLog.fromJson(response.data['data'] as Map<String, dynamic>);
    state = await AsyncValue.guard(() => fetchAllCareLogs());
    return log;
  }

  /// 케어 로그 수정 (전체 목록 갱신).
  Future<CareLog> updateById(String logId, Map<String, dynamic> data) async {
    final response = await DioClient().dio.patch(
      ApiConstants.careLogDetail(logId),
      data: data,
    );
    final log = CareLog.fromJson(response.data['data'] as Map<String, dynamic>);
    state = await AsyncValue.guard(() => fetchAllCareLogs());
    return log;
  }

  /// 케어 로그 삭제 (전체 목록 갱신).
  Future<void> deleteCareLogById(String logId) async {
    await DioClient().dio.delete(ApiConstants.careLogDetail(logId));
    state = await AsyncValue.guard(() => fetchAllCareLogs());
  }
}

// Filtered care logs provider (for parent log selection: MATING/EGG_LAYING)
final filteredCareLogsProvider = FutureProvider.family<List<CareLog>,
    ({String animalId, String logType})>((ref, params) async {
  final response = await DioClient().dio.get(
    ApiConstants.careLogs(params.animalId),
    queryParameters: {'log_type': params.logType, 'limit': 50},
  );
  final list = response.data['data'] as List;
  return list
      .map((e) => CareLog.fromJson(e as Map<String, dynamic>))
      .toList();
});

// Upload care log images (standalone utility)
Future<List<String>> uploadCareLogImages(List<String> filePaths) async {
  final formData = FormData.fromMap({
    'files': filePaths
        .map((path) => MultipartFile.fromFileSync(
              path,
              filename: path.split('/').last,
            ))
        .toList(),
  });
  final response = await DioClient().dio.post(
    ApiConstants.uploadCareLog,
    data: formData,
  );
  final urls = response.data['data']['urls'] as List;
  return urls.cast<String>();
}
