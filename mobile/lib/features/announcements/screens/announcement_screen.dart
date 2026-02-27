import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/widgets.dart';
import '../models/announcement_model.dart';
import '../providers/announcement_provider.dart';

class AnnouncementScreen extends ConsumerWidget {
  const AnnouncementScreen({super.key, this.onOpenDrawer});

  final VoidCallback? onOpenDrawer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncAnnouncements = ref.watch(activeAnnouncementsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: onOpenDrawer,
        ),
        title: Text(l10n.navAnnouncements),
      ),
      body: AsyncValueWidget<List<Announcement>>(
        value: asyncAnnouncements,
        onRetry: () => ref.invalidate(activeAnnouncementsProvider),
        data: (announcements) {
          if (announcements.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.campaign_outlined,
              title: l10n.navAnnouncements,
              subtitle: l10n.noAnnouncements,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(activeAnnouncementsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: announcements.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _AnnouncementCard(announcement: announcements[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({required this.announcement});

  final Announcement announcement;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');
    final period =
        '${dateFormat.format(announcement.startAt)} ~ ${dateFormat.format(announcement.endAt)}';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.campaign_outlined, size: 18, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    announcement.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              announcement.content,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Text(
              period,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
