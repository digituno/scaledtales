import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/enums/enums.dart';
import '../../../core/widgets/widgets.dart';
import '../models/care_log_model.dart';
import '../providers/care_log_provider.dart';
import '../widgets/care_log_card.dart';
import '../../auth/providers/user_profile_provider.dart';
import 'care_log_form_screen.dart';

class CareLogListScreen extends ConsumerStatefulWidget {
  const CareLogListScreen({super.key, this.onOpenDrawer});

  final VoidCallback? onOpenDrawer;

  @override
  ConsumerState<CareLogListScreen> createState() => _CareLogListScreenState();
}

class _CareLogListScreenState extends ConsumerState<CareLogListScreen> {
  LogType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final careLogsAsync = ref.watch(allCareLogsProvider);
    final canWrite = ref.watch(userRoleProvider).canWrite;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: widget.onOpenDrawer,
        ),
        title: Text(l10n.careLogs),
      ),
      floatingActionButton: canWrite
          ? FloatingActionButton(
              heroTag: 'careLogListFab',
              onPressed: () => _openForm(context),
              child: const Icon(Icons.add),
            )
          : null,
      body: AsyncValueWidget(
        value: careLogsAsync,
        onRetry: () => ref.invalidate(allCareLogsProvider),
        data: (careLogs) {
          if (careLogs.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.event_note,
              title: l10n.emptyLogs,
              subtitle: l10n.emptyLogsAction,
              action: canWrite
                  ? FilledButton.icon(
                      onPressed: () => _openForm(context),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addCareLog),
                    )
                  : null,
            );
          }
          return _buildContent(context, l10n, careLogs, canWrite);
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    List<CareLog> careLogs,
    bool canWrite,
  ) {
    final filtered = _selectedType != null
        ? careLogs.where((c) => c.logType == _selectedType!.value).toList()
        : careLogs;

    return Column(
      children: [
        // Filter chips
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SingleChildScrollView(
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
        ),

        // Log list
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    l10n.emptyLogs,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => ref.invalidate(allCareLogsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final careLog = filtered[index];
                      return CareLogCard(
                        careLog: careLog,
                        showAnimalName: true,
                        onEdit: canWrite
                            ? () => _openForm(context, careLog: careLog)
                            : null,
                        onDelete: canWrite
                            ? () => _confirmDelete(context, l10n, careLog)
                            : null,
                      );
                    },
                  ),
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
        builder: (_) => CareLogFormScreen(careLog: careLog),
      ),
    );
    if (result == true) {
      ref.invalidate(allCareLogsProvider);
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
        await ref.read(allCareLogsProvider.notifier).deleteCareLogById(careLog.id);
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
