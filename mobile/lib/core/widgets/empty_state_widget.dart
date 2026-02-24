import 'package:flutter/material.dart';

/// 빈 상태 공통 UI 위젯.
///
/// icon, title, subtitle, action 버튼을 파라미터로 받아 일관된 레이아웃을 제공한다.
///
/// 사용 예시:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.pets,
///   title: l10n.emptyAnimals,
///   subtitle: l10n.emptyAnimalsAction,
///   action: FilledButton.icon(
///     onPressed: () => ...,
///     icon: const Icon(Icons.add),
///     label: Text(l10n.addAnimal),
///   ),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.titleMedium),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: 24),
            action!,
          ],
        ],
      ),
    );
  }
}
