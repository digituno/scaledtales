import 'package:flutter/material.dart';

import '../models/species_models.dart';

class SpeciesListTile extends StatelessWidget {
  final SpeciesSummary species;
  final VoidCallback? onTap;

  const SpeciesListTile({
    super.key,
    required this.species,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        backgroundColor: species.classCode == 'REPTILE'
            ? Colors.green.shade100
            : Colors.blue.shade100,
        child: Icon(
          species.classCode == 'REPTILE' ? Icons.pets : Icons.water_drop,
          color: species.classCode == 'REPTILE'
              ? Colors.green.shade700
              : Colors.blue.shade700,
          size: 20,
        ),
      ),
      title: Text(
        species.displayName,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            species.scientificName,
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
          ),
          if (species.commonNameEn != null)
            Text(
              species.commonNameEn!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (species.isWhitelist)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                '합법',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (species.isCites) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Text(
                'CITES',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }
}
