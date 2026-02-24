import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/enums/enums.dart';
import '../../../core/utils/enum_labels.dart';
import '../models/care_log_model.dart';

class CareLogCard extends StatelessWidget {
  final CareLog careLog;
  final bool showAnimalName;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CareLogCard({
    super.key,
    required this.careLog,
    this.showAnimalName = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final logType = LogType.fromValue(careLog.logType);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Log type icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _logTypeColor(logType).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _logTypeIcon(logType),
                  color: _logTypeColor(logType),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: log type label + date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          logTypeLabel(logType, l10n),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatDate(careLog.logDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    // Animal name (when showing all logs)
                    if (showAnimalName && careLog.animalName.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          careLog.animalName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),

                    const SizedBox(height: 4),

                    // Details summary
                    Text(
                      _buildSummary(careLog, l10n),
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Notes
                    if (careLog.notes != null && careLog.notes!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          careLog.notes!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // Image thumbnails
                    if (careLog.images != null && careLog.images!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SizedBox(
                          height: 48,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: careLog.images!.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 4),
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CachedNetworkImage(
                                  imageUrl: careLog.images![index].url,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    width: 48,
                                    height: 48,
                                    color: theme
                                        .colorScheme.surfaceContainerHighest,
                                    child: const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    width: 48,
                                    height: 48,
                                    color: theme
                                        .colorScheme.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 20,
                                      color: theme.colorScheme.outline,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Popup menu
              if (onEdit != null || onDelete != null)
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                    if (onDelete != null)
                      PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Icon/Color/Label Mappings ──

  static IconData _logTypeIcon(LogType type) {
    return switch (type) {
      LogType.feeding => Icons.restaurant,
      LogType.shedding => Icons.auto_awesome,
      LogType.defecation => Icons.water_drop,
      LogType.mating => Icons.favorite,
      LogType.eggLaying => Icons.egg,
      LogType.candling => Icons.flashlight_on,
      LogType.hatching => Icons.egg_alt,
    };
  }

  static Color _logTypeColor(LogType type) {
    return switch (type) {
      LogType.feeding => Colors.orange,
      LogType.shedding => Colors.teal,
      LogType.defecation => Colors.brown,
      LogType.mating => Colors.pink,
      LogType.eggLaying => Colors.amber,
      LogType.candling => Colors.indigo,
      LogType.hatching => Colors.green,
    };
  }


  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  // ── Summary Builder ──

  String _buildSummary(CareLog log, AppLocalizations l10n) {
    final logType = LogType.fromValue(log.logType);
    final details = log.details;

    return switch (logType) {
      LogType.feeding => _feedingSummary(details, l10n),
      LogType.shedding => _sheddingSummary(details, l10n),
      LogType.defecation => _defecationSummary(details, l10n),
      LogType.mating => _matingSummary(details, l10n),
      LogType.eggLaying => _eggLayingSummary(details, l10n),
      LogType.candling => _candlingSummary(details, l10n),
      LogType.hatching => _hatchingSummary(details, l10n),
    };
  }

  // ── FEEDING Summary ──

  String _feedingSummary(Map<String, dynamic> details, AppLocalizations l10n) {
    final parts = <String>[];

    if (details['food_type'] != null) {
      final foodType = FoodType.fromValue(details['food_type'] as String);
      parts.add(foodTypeLabel(foodType, l10n));
    }
    if (details['food_item'] != null) {
      parts.add(details['food_item'] as String);
    }
    if (details['quantity'] != null) {
      final qty = details['quantity'].toString();
      final unit = details['unit'] != null
          ? unitLabel(Unit.fromValue(details['unit'] as String), l10n)
          : '';
      parts.add('$qty$unit');
    }
    if (details['feeding_response'] != null) {
      final resp =
          FeedingResponse.fromValue(details['feeding_response'] as String);
      parts.add(feedingResponseLabel(resp, l10n));
    }

    return parts.join(' · ');
  }

  // ── SHEDDING Summary ──

  String _sheddingSummary(
      Map<String, dynamic> details, AppLocalizations l10n) {
    final parts = <String>[];

    if (details['shed_completion'] != null) {
      final sc =
          ShedCompletion.fromValue(details['shed_completion'] as String);
      parts.add(shedCompletionLabel(sc, l10n));
    }

    if (details['problem_areas'] != null) {
      final areas = (details['problem_areas'] as List).cast<String>();
      if (areas.isNotEmpty) {
        parts.add(areas.join(', '));
      }
    }

    if (details['assistance_needed'] == true) {
      parts.add(l10n.assistanceNeeded);
    }

    return parts.join(' · ');
  }

  // ── DEFECATION Summary ──

  String _defecationSummary(
      Map<String, dynamic> details, AppLocalizations l10n) {
    final parts = <String>[];

    final fecesPresent = details['feces_present'] as bool? ?? false;
    parts.add(
        '${l10n.fecesPresent}: ${fecesPresent ? l10n.yes : l10n.no}');

    if (fecesPresent && details['feces_consistency'] != null) {
      final fc = FecesConsistency.fromValue(
          details['feces_consistency'] as String);
      parts.add(fecesConsistencyLabel(fc, l10n));
    }

    final uratePresent = details['urate_present'] as bool? ?? false;
    parts.add(
        '${l10n.uratePresent}: ${uratePresent ? l10n.yes : l10n.no}');

    if (uratePresent && details['urate_condition'] != null) {
      final uc =
          UrateCondition.fromValue(details['urate_condition'] as String);
      parts.add(urateConditionLabel(uc, l10n));
    }

    return parts.join(' · ');
  }

  // ── MATING Summary ──

  String _matingSummary(Map<String, dynamic> details, AppLocalizations l10n) {
    final parts = <String>[];

    if (details['mating_success'] != null) {
      final ms =
          MatingSuccess.fromValue(details['mating_success'] as String);
      parts.add(matingSuccessLabel(ms, l10n));
    }

    if (details['partner_name'] != null) {
      parts.add(details['partner_name'] as String);
    }

    if (details['duration_minutes'] != null) {
      parts.add('${details['duration_minutes']}min');
    }

    return parts.join(' · ');
  }

  // ── EGG_LAYING Summary ──

  String _eggLayingSummary(
      Map<String, dynamic> details, AppLocalizations l10n) {
    final parts = <String>[];

    if (details['egg_count'] != null) {
      parts.add('${details['egg_count']}${l10n.eggCount}');
    }

    if (details['fertile_count'] != null) {
      parts.add('${l10n.fertileCount}: ${details['fertile_count']}');
    }

    if (details['infertile_count'] != null) {
      parts.add('${l10n.infertileCount}: ${details['infertile_count']}');
    }

    if (details['incubation_planned'] == true &&
        details['incubation_method'] != null) {
      final im = IncubationMethod.fromValue(
          details['incubation_method'] as String);
      parts.add(incubationMethodLabel(im, l10n));
    }

    return parts.join(' · ');
  }

  // ── CANDLING Summary ──

  String _candlingSummary(
      Map<String, dynamic> details, AppLocalizations l10n) {
    final parts = <String>[];

    if (details['day_after_laying'] != null) {
      parts.add('D${details['day_after_laying']}');
    }

    if (details['fertile_count'] != null) {
      parts.add('${l10n.fertileCount}: ${details['fertile_count']}');
    }

    if (details['total_viable'] != null) {
      parts.add('${l10n.totalViable}: ${details['total_viable']}');
    }

    return parts.join(' · ');
  }

  // ── HATCHING Summary ──

  String _hatchingSummary(
      Map<String, dynamic> details, AppLocalizations l10n) {
    final parts = <String>[];

    if (details['hatched_count'] != null) {
      parts.add('${l10n.hatchedCount}: ${details['hatched_count']}');
    }

    if (details['failed_count'] != null) {
      parts.add('${l10n.failedCount}: ${details['failed_count']}');
    }

    return parts.join(' · ');
  }

}
