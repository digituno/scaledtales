import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/enums/enums.dart';
import '../../../core/widgets/widgets.dart';
import '../models/care_log_model.dart';
import '../providers/care_log_provider.dart';
import '../screens/care_log_form_screen.dart';
import 'care_log_card.dart';

class CareLogTab extends ConsumerStatefulWidget {
  final String animalId;

  const CareLogTab({super.key, required this.animalId});

  @override
  ConsumerState<CareLogTab> createState() => _CareLogTabState();
}

class _CareLogTabState extends ConsumerState<CareLogTab> {
  LogType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final careLogsAsync = ref.watch(careLogListProvider(widget.animalId));

    return AsyncValueWidget(
      value: careLogsAsync,
      onRetry: () => ref.invalidate(careLogListProvider(widget.animalId)),
      data: (careLogs) {
        if (careLogs.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.event_note,
            title: l10n.emptyLogs,
            subtitle: l10n.emptyLogsAction,
            action: FilledButton.icon(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.addCareLog),
            ),
          );
        }
        return _buildContent(context, l10n, careLogs);
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    List<CareLog> careLogs,
  ) {
    final filtered = _selectedType != null
        ? careLogs.where((c) => c.logType == _selectedType!.value).toList()
        : careLogs;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Add button
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.addCareLog),
          ),
        ),
        const SizedBox(height: 12),

        // Log type filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _typeChip(l10n.allTypes, null),
              const SizedBox(width: 8),
              _typeChip(l10n.logTypeFeeding, LogType.feeding),
              const SizedBox(width: 8),
              _typeChip(l10n.logTypeShedding, LogType.shedding),
              const SizedBox(width: 8),
              _typeChip(l10n.logTypeDefecation, LogType.defecation),
              const SizedBox(width: 8),
              _typeChip(l10n.logTypeMating, LogType.mating),
              const SizedBox(width: 8),
              _typeChip(l10n.logTypeEggLaying, LogType.eggLaying),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Care log list
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                l10n.emptyLogs,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          )
        else
          ...filtered.map(
            (careLog) => CareLogCard(
              careLog: careLog,
              onEdit: () => _openForm(context, careLog: careLog),
              onDelete: () => _confirmDelete(context, l10n, careLog),
            ),
          ),
      ],
    );
  }

  Widget _typeChip(String label, LogType? type) {
    final selected = _selectedType == type;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedType = type),
    );
  }

  Future<void> _openForm(BuildContext context, {CareLog? careLog}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CareLogFormScreen(
          animalId: widget.animalId,
          careLog: careLog,
        ),
      ),
    );
    if (result == true) {
      ref.invalidate(careLogListProvider(widget.animalId));
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
    CareLog careLog,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteCareLogConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(careLogListProvider(widget.animalId).notifier).deleteCareLogById(careLog.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.deletedMessage)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorWithDetail(e.toString()))),
          );
        }
      }
    }
  }
}
