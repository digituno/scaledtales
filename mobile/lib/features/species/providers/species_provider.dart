import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/utils/dio_client.dart';
import '../models/species_models.dart';

// Classes
final classesProvider = FutureProvider<List<TaxonomyClass>>((ref) async {
  final response = await DioClient().dio.get(ApiConstants.speciesClasses);
  final data = response.data['data'] as List;
  return data.map((e) => TaxonomyClass.fromJson(e)).toList();
});

// Orders by class
final ordersProvider =
    FutureProvider.family<List<TaxonomyOrder>, String>((ref, classId) async {
  final response =
      await DioClient().dio.get(ApiConstants.speciesOrders(classId));
  final data = response.data['data'] as List;
  return data.map((e) => TaxonomyOrder.fromJson(e)).toList();
});

// Families by order
final familiesProvider =
    FutureProvider.family<List<TaxonomyFamily>, String>((ref, orderId) async {
  final response =
      await DioClient().dio.get(ApiConstants.speciesFamilies(orderId));
  final data = response.data['data'] as List;
  return data.map((e) => TaxonomyFamily.fromJson(e)).toList();
});

// Genera by family
final generaProvider =
    FutureProvider.family<List<TaxonomyGenus>, String>((ref, familyId) async {
  final response =
      await DioClient().dio.get(ApiConstants.speciesGenera(familyId));
  final data = response.data['data'] as List;
  return data.map((e) => TaxonomyGenus.fromJson(e)).toList();
});

// Species by genus
final speciesByGenusProvider = FutureProvider.family<List<SpeciesSummary>,
    String>((ref, genusId) async {
  final response =
      await DioClient().dio.get(ApiConstants.speciesSpecies(genusId));
  final data = response.data['data'] as List;
  return data.map((e) => SpeciesSummary.fromJson(e)).toList();
});

// Species detail
final speciesDetailProvider =
    FutureProvider.family<SpeciesDetail, String>((ref, id) async {
  final response = await DioClient().dio.get(ApiConstants.speciesDetail(id));
  return SpeciesDetail.fromJson(response.data['data']);
});

// Search
class SpeciesSearchNotifier extends StateNotifier<AsyncValue<List<SpeciesSummary>>> {
  SpeciesSearchNotifier() : super(const AsyncValue.data([]));

  Future<void> search(String query, {String? classCode}) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final params = <String, dynamic>{'q': query};
      if (classCode != null) params['class_code'] = classCode;

      final response = await DioClient().dio.get(
        ApiConstants.speciesSearch,
        queryParameters: params,
      );
      final data = response.data['data'] as List;
      final results = data.map((e) => SpeciesSummary.fromJson(e)).toList();
      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}

final speciesSearchProvider = StateNotifierProvider<SpeciesSearchNotifier,
    AsyncValue<List<SpeciesSummary>>>((ref) {
  return SpeciesSearchNotifier();
});
