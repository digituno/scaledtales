import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, this.onOpenDrawer});

  final VoidCallback? onOpenDrawer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final currentTheme = ref.watch(themeModeProvider);

    // 현재 언어 표시 텍스트
    final localeLabel = currentLocale.languageCode == 'en'
        ? l10n.languageEnglish
        : l10n.languageKorean;

    // 현재 테마 표시 텍스트
    final themeLabel = switch (currentTheme) {
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
      ThemeMode.system => l10n.themeSystem,
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: onOpenDrawer,
        ),
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // 언어 설정
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(localeLabel,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 18),
              ],
            ),
            onTap: () => _showLanguageDialog(context, ref, l10n, currentLocale),
          ),

          // 테마 설정
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(l10n.theme),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(themeLabel,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 18),
              ],
            ),
            onTap: () => _showThemeDialog(context, ref, l10n, currentTheme),
          ),

          const Divider(),

          // 로그아웃
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
            onTap: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Locale currentLocale,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.languageSelectTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale>(
              value: const Locale('ko'),
              groupValue: currentLocale,
              title: Text(l10n.languageKorean),
              onChanged: (locale) {
                if (locale != null) {
                  ref.read(localeProvider.notifier).setLocale(locale);
                  Navigator.of(ctx).pop();
                }
              },
            ),
            RadioListTile<Locale>(
              value: const Locale('en'),
              groupValue: currentLocale,
              title: Text(l10n.languageEnglish),
              onChanged: (locale) {
                if (locale != null) {
                  ref.read(localeProvider.notifier).setLocale(locale);
                  Navigator.of(ctx).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeMode currentTheme,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.themeSelectTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              value: ThemeMode.system,
              groupValue: currentTheme,
              title: Text(l10n.themeSystem),
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(themeModeProvider.notifier).setTheme(mode);
                  Navigator.of(ctx).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.light,
              groupValue: currentTheme,
              title: Text(l10n.themeLight),
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(themeModeProvider.notifier).setTheme(mode);
                  Navigator.of(ctx).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: currentTheme,
              title: Text(l10n.themeDark),
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(themeModeProvider.notifier).setTheme(mode);
                  Navigator.of(ctx).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
