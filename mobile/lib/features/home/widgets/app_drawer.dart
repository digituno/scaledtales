import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../auth/providers/user_profile_provider.dart';
import '../../../core/enums/enums.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  final int currentIndex;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);

    final email = profileAsync.whenOrNull(data: (p) => p?.email) ?? '';
    final role = profileAsync.whenOrNull(data: (p) => p?.role);
    final roleLabel = role != null ? _getRoleLabel(role) : '';

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // 헤더: 사용자 정보
            UserAccountsDrawerHeader(
              accountName: Text(
                email,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: roleLabel.isNotEmpty
                  ? Text(roleLabel, style: const TextStyle(fontSize: 12))
                  : null,
              currentAccountPicture: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 32,
                ),
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
              margin: EdgeInsets.zero,
            ),

            // 메뉴 아이템들
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // 홈
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home,
                    label: l10n.navHome,
                    index: 0,
                    currentIndex: currentIndex,
                    onTap: onNavigate,
                  ),

                  const Divider(indent: 16, endIndent: 16),

                  // 공지사항
                  _DrawerItem(
                    icon: Icons.campaign_outlined,
                    selectedIcon: Icons.campaign,
                    label: l10n.navAnnouncements,
                    index: 1,
                    currentIndex: currentIndex,
                    onTap: onNavigate,
                  ),

                  const Divider(indent: 16, endIndent: 16),

                  // 개체
                  _DrawerItem(
                    icon: Icons.pets_outlined,
                    selectedIcon: Icons.pets,
                    label: l10n.navAnimals,
                    index: 2,
                    currentIndex: currentIndex,
                    onTap: onNavigate,
                  ),

                  // 일지
                  _DrawerItem(
                    icon: Icons.event_note_outlined,
                    selectedIcon: Icons.event_note,
                    label: l10n.navLogs,
                    index: 3,
                    currentIndex: currentIndex,
                    onTap: onNavigate,
                  ),

                  const Divider(indent: 16, endIndent: 16),

                  // 설정
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    label: l10n.navSettings,
                    index: 4,
                    currentIndex: currentIndex,
                    onTap: onNavigate,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleLabel(UserRole role) {
    return switch (role) {
      UserRole.admin => '관리자',
      UserRole.seller => '판매자',
      UserRole.proBreeder => '전문 브리더',
      UserRole.user => '일반 사용자',
      UserRole.suspended => '정지된 계정',
    };
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = index == currentIndex;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          selected ? selectedIcon : icon,
          color: selected ? theme.colorScheme.primary : null,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? theme.colorScheme.primary : null,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: selected,
        selectedTileColor:
            theme.colorScheme.primaryContainer.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: () => onTap(index),
      ),
    );
  }
}
