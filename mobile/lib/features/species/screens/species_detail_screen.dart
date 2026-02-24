import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/species_provider.dart';

class SpeciesDetailScreen extends ConsumerWidget {
  final String speciesId;

  const SpeciesDetailScreen({super.key, required this.speciesId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(speciesDetailProvider(speciesId));
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.speciesDetail)),
      body: detailAsync.when(
        data: (detail) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor:
                          detail.taxonomyClass.code == 'REPTILE'
                              ? Colors.green.shade100
                              : Colors.blue.shade100,
                      child: Icon(
                        detail.taxonomyClass.code == 'REPTILE'
                            ? Icons.pets
                            : Icons.water_drop,
                        size: 36,
                        color: detail.taxonomyClass.code == 'REPTILE'
                            ? Colors.green.shade700
                            : Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      detail.displayName,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail.scientificName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (detail.commonNameEn != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        detail.commonNameEn!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (detail.isWhitelist)
                          _buildBadge('백색목록', Colors.green),
                        if (detail.isCites) ...[
                          const SizedBox(width: 8),
                          _buildBadge(
                            'CITES ${detail.citesLevel ?? ''}',
                            Colors.orange,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Taxonomy
              Text(
                l10n.taxonomy,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildTaxonomyRow('강 (Class)', detail.taxonomyClass.nameKr,
                  detail.taxonomyClass.nameEn),
              _buildTaxonomyRow(
                  '목 (Order)', detail.order.nameKr, detail.order.nameEn),
              _buildTaxonomyRow(
                  '과 (Family)', detail.family.nameKr, detail.family.nameEn),
              _buildTaxonomyRow(
                  '속 (Genus)', detail.genus.nameKr, detail.genus.nameEn),
              _buildTaxonomyRow(l10n.speciesLabel, detail.speciesKr,
                  detail.speciesEn),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorWithDetail(e.toString()))),
      ),
    );
  }

  Widget _buildBadge(String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTaxonomyRow(String label, String nameKr, String nameEn) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nameKr,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(nameEn,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
