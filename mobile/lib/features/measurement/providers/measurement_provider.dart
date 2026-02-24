import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/utils/dio_client.dart';
import '../models/measurement_model.dart';

// Measurement list provider (per animal)
final measurementListProvider = AsyncNotifierProvider.family<
    MeasurementListNotifier, List<MeasurementLog>, String>(
  MeasurementListNotifier.new,
);

class MeasurementListNotifier
    extends FamilyAsyncNotifier<List<MeasurementLog>, String> {
  @override
  Future<List<MeasurementLog>> build(String arg) => fetchMeasurements(arg);

  Future<List<MeasurementLog>> fetchMeasurements(String animalId) async {
    final response = await DioClient().dio.get(
      ApiConstants.measurements(animalId),
      queryParameters: {'limit': 100},
    );
    final list = response.data['data'] as List;
    return list.map((e) => MeasurementLog.fromJson(e)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => fetchMeasurements(arg));
  }

  /// 측정 기록 생성. 성공 시 목록 자동 갱신.
  Future<MeasurementLog> create(Map<String, dynamic> data) async {
    final response = await DioClient().dio.post(
      ApiConstants.measurements(arg),
      data: data,
    );
    final log = MeasurementLog.fromJson(response.data['data']);
    state = await AsyncValue.guard(() => fetchMeasurements(arg));
    return log;
  }

  /// 측정 기록 수정. 성공 시 목록 자동 갱신.
  Future<MeasurementLog> updateById(
      String measurementId, Map<String, dynamic> data) async {
    final response = await DioClient().dio.patch(
      ApiConstants.measurementDetail(measurementId),
      data: data,
    );
    final log = MeasurementLog.fromJson(response.data['data']);
    state = await AsyncValue.guard(() => fetchMeasurements(arg));
    return log;
  }

  /// 측정 기록 삭제. 성공 시 목록 자동 갱신.
  Future<void> deleteMeasurementById(String measurementId) async {
    await DioClient().dio.delete(ApiConstants.measurementDetail(measurementId));
    state = await AsyncValue.guard(() => fetchMeasurements(arg));
  }
}
