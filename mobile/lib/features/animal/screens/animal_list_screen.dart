import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/enums/enums.dart';
import '../../../core/widgets/widgets.dart';
import '../models/animal_model.dart';
import '../providers/animal_provider.dart';
import 'animal_create_screen.dart';
import 'animal_detail_screen.dart';

class AnimalListScreen extends ConsumerWidget {
  const AnimalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final animalsAsync = ref.watch(animalListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myAnimals)),
      body: AsyncValueWidget(
        value: animalsAsync,
        onRetry: () => ref.read(animalListProvider.notifier).refresh(),
        data: (animals) {
          if (animals.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.pets,
              title: l10n.emptyAnimals,
              subtitle: l10n.emptyAnimalsAction,
              action: FilledButton.icon(
                onPressed: () => _navigateToCreate(context, ref),
                icon: const Icon(Icons.add),
                label: Text(l10n.addAnimal),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(animalListProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: animals.length,
              itemBuilder: (context, index) {
                return _AnimalCard(
                  animal: animals[index],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AnimalDetailScreen(animalId: animals[index].id),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'animalListFab',
        onPressed: () => _navigateToCreate(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToCreate(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AnimalCreateScreen()),
    );
    if (result == true) {
      ref.read(animalListProvider.notifier).refresh();
    }
  }
}

class _AnimalCard extends StatelessWidget {
  final AnimalSummary animal;
  final VoidCallback onTap;

  const _AnimalCard({required this.animal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sex = Sex.fromValue(animal.sex);
    final sexLabel = switch (sex) {
      Sex.male => l10n.sexMale,
      Sex.female => l10n.sexFemale,
      Sex.unknown => l10n.sexUnknown,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Profile image
              CircleAvatar(
                radius: 30,
                backgroundImage: animal.profileImageUrl != null
                    ? CachedNetworkImageProvider(animal.profileImageUrl!)
                    : null,
                child: animal.profileImageUrl == null
                    ? const Icon(Icons.pets, size: 28)
                    : null,
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            animal.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _SexBadge(sex: sex, label: sexLabel),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      animal.species.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (animal.currentWeight != null)
                          Text(
                            '${animal.currentWeight!.toStringAsFixed(1)}g',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        if (animal.currentWeight != null &&
                            animal.morph != null)
                          const Text(' · '),
                        if (animal.morph != null)
                          Expanded(
                            child: Text(
                              animal.morph!,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _SexBadge extends StatelessWidget {
  final Sex sex;
  final String label;

  const _SexBadge({required this.sex, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = switch (sex) {
      Sex.male => Colors.blue,
      Sex.female => Colors.pink,
      Sex.unknown => Colors.grey,
    };
    final icon = switch (sex) {
      Sex.male => Icons.male,
      Sex.female => Icons.female,
      Sex.unknown => Icons.question_mark,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}
