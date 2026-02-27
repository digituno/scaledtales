import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/utils/dio_client.dart';
import '../models/announcement_model.dart';

final activeAnnouncementsProvider = FutureProvider<List<Announcement>>((ref) async {
  final response = await DioClient().dio.get(ApiConstants.announcementsActive);
  final list = response.data['data'] as List;
  return list
      .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
      .toList();
});
