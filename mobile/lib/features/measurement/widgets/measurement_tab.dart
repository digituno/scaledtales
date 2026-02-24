import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/widgets/widgets.dart';
import '../models/measurement_model.dart';
import '../providers/measurement_provider.dart';
import '../screens/measurement_form_screen.dart';
import 'growth_chart.dart';

enum ChartPeriod { month1, month3, month6, year1, all }

class MeasurementTab extends ConsumerStatefulWidget {
  final String animalId;

  const MeasurementTab({super.key, required this.animalId});

  @override
  ConsumerState<MeasurementTab> createState() => _MeasurementTabState();
}

class _MeasurementTabState extends ConsumerState<MeasurementTab> {
  ChartPeriod _period = ChartPeriod.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final measurementsAsync =
        ref.watch(measurementListProvider(widget.animalId));

    return AsyncValueWidget(
      value: measurementsAsync,
      onRetry: () => ref.invalidate(measurementListProvider(widget.animalId)),
      data: (measurements) {
        if (measurements.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.straighten,
            title: l10n.emptyMeasurements,
            subtitle: l10n.emptyMeasurementsAction,
            action: FilledButton.icon(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.addMeasurement),
            ),
          );
        }
        return _buildContent(context, l10n, measurements);
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    List<MeasurementLog> measurements,
  ) {
    final filtered = _filterByPeriod(measurements);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Add button
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add),
            label: Text(l10n.addMeasurement),
          ),
        ),
        const SizedBox(height: 12),

        // Period filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _periodChip(l10n.period1Month, ChartPeriod.month1),
              const SizedBox(width: 8),
              _periodChip(l10n.period3Months, ChartPeriod.month3),
              const SizedBox(width: 8),
              _periodChip(l10n.period6Months, ChartPeriod.month6),
              const SizedBox(width: 8),
              _periodChip(l10n.period1Year, ChartPeriod.year1),
              const SizedBox(width: 8),
              _periodChip(l10n.periodAll, ChartPeriod.all),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Weight chart
        GrowthChart(
          measurements: filtered,
          title: l10n.weight,
          unit: 'g',
          getValue: (m) => m.weight,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),

        // Length chart
        GrowthChart(
          measurements: filtered,
          title: l10n.length,
          unit: 'cm',
          getValue: (m) => m.length,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        const SizedBox(height: 16),

        // History list
        Text(
          l10n.measurementHistory,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...measurements.map((m) => _buildHistoryCard(context, l10n, m)),
      ],
    );
  }

  Widget _periodChip(String label, ChartPeriod period) {
    final selected = _period == period;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _period = period),
    );
  }

  List<MeasurementLog> _filterByPeriod(List<MeasurementLog> measurements) {
    if (_period == ChartPeriod.all) return measurements;

    final now = DateTime.now();
    final cutoff = switch (_period) {
      ChartPeriod.month1 => DateTime(now.year, now.month - 1, now.day),
      ChartPeriod.month3 => DateTime(now.year, now.month - 3, now.day),
      ChartPeriod.month6 => DateTime(now.year, now.month - 6, now.day),
      ChartPeriod.year1 => DateTime(now.year - 1, now.month, now.day),
      ChartPeriod.all => now,
    };

    return measurements
        .where((m) => DateTime.parse(m.measuredDate).isAfter(cutoff))
        .toList();
  }

  Widget _buildHistoryCard(
    BuildContext context,
    AppLocalizations l10n,
    MeasurementLog m,
  ) {
    return Card(
      child: ListTile(
        title: Text(m.measuredDate),
        subtitle: Text([
          if (m.weight != null) '${l10n.weight}: ${m.weight!.toStringAsFixed(1)}g',
          if (m.length != null) '${l10n.length}: ${m.length!.toStringAsFixed(1)}cm',
          if (m.notes != null && m.notes!.isNotEmpty) m.notes!,
        ].join('  ')),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'edit') {
              final result = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => MeasurementFormScreen(
                    animalId: widget.animalId,
                    measurement: m,
                  ),
                ),
              );
              if (result == true) {
                ref.invalidate(measurementListProvider(widget.animalId));
              }
            } else if (value == 'delete') {
              _confirmDelete(context, l10n, m);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
            PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
    MeasurementLog m,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage),
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
        await ref.read(measurementListProvider(widget.animalId).notifier).deleteMeasurementById(m.id);
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

  Future<void> _openForm(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => MeasurementFormScreen(animalId: widget.animalId),
      ),
    );
    if (result == true) {
      ref.invalidate(measurementListProvider(widget.animalId));
    }
  }
}
