import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kSeenAnnouncementsKey = 'seen_announcements';

final announcementSeenProvider =
    StateNotifierProvider<AnnouncementSeenNotifier, Set<String>>((ref) {
  return AnnouncementSeenNotifier();
});

class AnnouncementSeenNotifier extends StateNotifier<Set<String>> {
  AnnouncementSeenNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSeenAnnouncementsKey);
    if (raw != null) {
      final list = (jsonDecode(raw) as List).cast<String>();
      state = Set<String>.from(list);
    }
  }

  bool hasSeen(String id) => state.contains(id);

  Future<void> markAsSeen(String id) async {
    final updated = {...state, id};
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSeenAnnouncementsKey, jsonEncode(updated.toList()));
  }
}
