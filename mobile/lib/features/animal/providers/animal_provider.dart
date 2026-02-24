import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/utils/dio_client.dart';
import '../models/animal_model.dart';

// Animal list provider
final animalListProvider =
    AsyncNotifierProvider<AnimalListNotifier, List<AnimalSummary>>(
  AnimalListNotifier.new,
);

class AnimalListNotifier extends AsyncNotifier<List<AnimalSummary>> {
  @override
  Future<List<AnimalSummary>> build() => fetchAnimals();

  Future<List<AnimalSummary>> fetchAnimals({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    queryParams['limit'] = 100;

    final response = await DioClient().dio.get(
      ApiConstants.animals,
      queryParameters: queryParams,
    );
    final list = response.data['data'] as List;
    return list.map((e) => AnimalSummary.fromJson(e)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => fetchAnimals());
  }

  /// 동물 등록. 성공 시 목록 자동 갱신.
  Future<AnimalDetail> create(Map<String, dynamic> data) async {
    final response =
        await DioClient().dio.post(ApiConstants.animals, data: data);
    final animal = AnimalDetail.fromJson(response.data['data']);
    state = await AsyncValue.guard(() => fetchAnimals());
    return animal;
  }

  /// 동물 수정. 성공 시 목록 자동 갱신.
  Future<AnimalDetail> updateById(String id, Map<String, dynamic> data) async {
    final response = await DioClient().dio.patch(
      ApiConstants.animalDetail(id),
      data: data,
    );
    final animal = AnimalDetail.fromJson(response.data['data']);
    state = await AsyncValue.guard(() => fetchAnimals());
    return animal;
  }

  /// 동물 삭제. 성공 시 목록 자동 갱신.
  Future<void> deleteAnimalById(String id) async {
    await DioClient().dio.delete(ApiConstants.animalDetail(id));
    state = await AsyncValue.guard(() => fetchAnimals());
  }
}

// Animal detail provider
final animalDetailProvider =
    FutureProvider.family<AnimalDetail, String>((ref, id) async {
  final response = await DioClient().dio.get(ApiConstants.animalDetail(id));
  return AnimalDetail.fromJson(response.data['data']);
});

// Upload profile image (standalone utility)
Future<String> uploadProfileImage(File file) async {
  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(
      file.path,
      filename: file.path.split('/').last,
    ),
  });

  final response = await DioClient().dio.post(
    ApiConstants.uploadProfile,
    data: formData,
    options: Options(contentType: 'multipart/form-data'),
  );

  return response.data['data']['url'] as String;
}

// User's animals for parent selection (alive only)
final userAnimalsProvider = FutureProvider<List<AnimalSummary>>((ref) async {
  final response = await DioClient().dio.get(
    ApiConstants.animals,
    queryParameters: {'status': 'ALIVE', 'limit': 100},
  );
  final list = response.data['data'] as List;
  return list.map((e) => AnimalSummary.fromJson(e)).toList();
});
