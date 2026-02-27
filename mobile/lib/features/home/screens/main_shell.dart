import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../announcements/models/announcement_model.dart';
import '../../announcements/providers/announcement_provider.dart';
import '../../announcements/providers/announcement_seen_provider.dart';
import '../../announcements/screens/announcement_screen.dart';
import '../../animal/screens/animal_list_screen.dart';
import '../../care_log/screens/care_log_list_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../widgets/app_drawer.dart';
import 'home_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAnnouncementPopups();
    });
  }

  void _openDrawer() => _scaffoldKey.currentState?.openDrawer();

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
    _scaffoldKey.currentState?.closeDrawer();
  }

  Future<void> _showAnnouncementPopups() async {
    if (!mounted) return;

    // 활성 공지사항 로드
    final asyncAnnouncements =
        await ref.read(activeAnnouncementsProvider.future).catchError((_) => <Announcement>[]);

    if (!mounted) return;

    final seenNotifier = ref.read(announcementSeenProvider.notifier);
    final seenIds = ref.read(announcementSeenProvider);

    // 미확인 공지 필터링
    final unseen = asyncAnnouncements.where((a) => !seenIds.contains(a.id)).toList();

    for (final announcement in unseen) {
      if (!mounted) break;
      await _showSinglePopup(announcement, seenNotifier);
    }
  }

  Future<void> _showSinglePopup(
    Announcement announcement,
    AnnouncementSeenNotifier seenNotifier,
  ) async {
    bool dontShowAgain = false;
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(
                announcement.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(announcement.content),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          setDialogState(() => dontShowAgain = !dontShowAgain);
                        },
                        child: Row(
                          children: [
                            Checkbox(
                              value: dontShowAgain,
                              onChanged: (v) {
                                setDialogState(() => dontShowAgain = v ?? false);
                              },
                            ),
                            Text(
                              l10n.dontShowAgain,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (dontShowAgain) {
                      await seenNotifier.markAsSeen(announcement.id);
                    }
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  },
                  child: Text(l10n.confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        currentIndex: _currentIndex,
        onNavigate: _navigateTo,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onOpenDrawer: _openDrawer),
          AnnouncementScreen(onOpenDrawer: _openDrawer),
          AnimalListScreen(onOpenDrawer: _openDrawer),
          CareLogListScreen(onOpenDrawer: _openDrawer),
          SettingsScreen(onOpenDrawer: _openDrawer),
        ],
      ),
    );
  }
}
