import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../animal/providers/animal_provider.dart';
import '../../animal/screens/animal_create_screen.dart';
import '../../animal/screens/animal_list_screen.dart';
import '../../care_log/models/care_log_model.dart';
import '../../care_log/providers/care_log_provider.dart';
import '../../care_log/screens/care_log_form_screen.dart';
import '../../care_log/widgets/care_log_card.dart';
import '../../species/screens/species_search_screen.dart';
import '../../species/screens/species_selector_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final animalsAsync = ref.watch(animalListProvider);
    final careLogsAsync = ref.watch(allCareLogsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: animalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildEmptyState(context, l10n),
        data: (animals) {
          if (animals.isEmpty) {
            return _buildEmptyState(context, l10n);
          }
          return _buildDashboard(context, ref, l10n, animals, careLogsAsync);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.emptyAnimals,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(l10n.emptyAnimalsAction),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SpeciesSearchScreen(),
                ),
              );
            },
            icon: const Icon(Icons.search),
            label: Text(l10n.speciesSearch),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SpeciesSelectorScreen(),
                ),
              );
            },
            icon: const Icon(Icons.account_tree),
            label: Text(l10n.speciesBrowse),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    List<dynamic> animals,
    AsyncValue<List<CareLog>> careLogsAsync,
  ) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(animalListProvider);
        ref.invalidate(allCareLogsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 요약 카드 (개체 수)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.pets,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.totalAnimals,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${animals.length}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AnimalListScreen(),
                      ),
                    ),
                    child: Text(l10n.viewAll),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 빠른 액션
          Text(
            l10n.quickActions,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AnimalCreateScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addAnimal),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CareLogFormScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.edit_note),
                  label: Text(l10n.addCareLog),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 최근 일지 섹션
          Text(
            l10n.recentLogs,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          careLogsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                l10n.emptyLogs,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            data: (careLogs) {
              if (careLogs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      l10n.emptyLogs,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }
              // 최근 3건만 표시
              final recent = careLogs.take(3).toList();
              return Column(
                children: recent
                    .map<Widget>((log) => CareLogCard(
                          careLog: log,
                          showAnimalName: true,
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
