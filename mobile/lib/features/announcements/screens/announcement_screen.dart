import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/widgets/widgets.dart';

class AnnouncementScreen extends StatelessWidget {
  const AnnouncementScreen({super.key, this.onOpenDrawer});

  final VoidCallback? onOpenDrawer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: onOpenDrawer,
        ),
        title: Text(l10n.navAnnouncements),
      ),
      body: EmptyStateWidget(
        icon: Icons.campaign_outlined,
        title: l10n.navAnnouncements,
        subtitle: l10n.comingSoon,
      ),
    );
  }
}
