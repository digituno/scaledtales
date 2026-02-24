import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/species_models.dart';
import '../providers/species_provider.dart';
import 'species_search_screen.dart';

class SpeciesSelectorScreen extends ConsumerStatefulWidget {
  const SpeciesSelectorScreen({super.key});

  @override
  ConsumerState<SpeciesSelectorScreen> createState() =>
      _SpeciesSelectorScreenState();
}

class _SpeciesSelectorScreenState
    extends ConsumerState<SpeciesSelectorScreen> {
  TaxonomyClass? _selectedClass;
  TaxonomyOrder? _selectedOrder;
  TaxonomyFamily? _selectedFamily;
  TaxonomyGenus? _selectedGenus;

  int get _currentStep {
    if (_selectedGenus != null) return 4;
    if (_selectedFamily != null) return 3;
    if (_selectedOrder != null) return 2;
    if (_selectedClass != null) return 1;
    return 0;
  }

  void _goBack() {
    setState(() {
      if (_selectedGenus != null) {
        _selectedGenus = null;
      } else if (_selectedFamily != null) {
        _selectedFamily = null;
      } else if (_selectedOrder != null) {
        _selectedOrder = null;
      } else if (_selectedClass != null) {
        _selectedClass = null;
      } else {
        Navigator.of(context).pop();
      }
    });
  }

  void _onSpeciesSelected(SpeciesSummary species) {
    Navigator.of(context).pop(species);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentStep > 0 ? _goBack : () => Navigator.pop(context),
        ),
        title: Text(_getTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final result = await Navigator.of(context).push<SpeciesSummary>(
                MaterialPageRoute(
                  builder: (_) =>
                      const SpeciesSearchScreen(selectionMode: true),
                ),
              );
              if (result != null && context.mounted) {
                Navigator.of(context).pop(result);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Breadcrumb
          if (_currentStep > 0) _buildBreadcrumb(),
          // Content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  String _getTitle() {
    final l10n = AppLocalizations.of(context)!;
    switch (_currentStep) {
      case 0:
        return l10n.selectClass;
      case 1:
        return l10n.selectOrder;
      case 2:
        return l10n.selectFamily;
      case 3:
        return l10n.selectGenus;
      case 4:
        return l10n.selectSpecies;
      default:
        return l10n.selectSpecies;
    }
  }

  Widget _buildBreadcrumb() {
    final items = <String>[];
    if (_selectedClass != null) items.add(_selectedClass!.nameKr);
    if (_selectedOrder != null) items.add(_selectedOrder!.nameKr);
    if (_selectedFamily != null) items.add(_selectedFamily!.nameKr);
    if (_selectedGenus != null) items.add(_selectedGenus!.nameKr);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(
        items.join(' > '),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedGenus != null) {
      return _buildSpeciesList();
    } else if (_selectedFamily != null) {
      return _buildGeneraList();
    } else if (_selectedOrder != null) {
      return _buildFamiliesList();
    } else if (_selectedClass != null) {
      return _buildOrdersList();
    } else {
      return _buildClassesList();
    }
  }

  Widget _buildClassesList() {
    final classesAsync = ref.watch(classesProvider);
    return classesAsync.when(
      data: (classes) => ListView.separated(
        itemCount: classes.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final cls = classes[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: cls.code == 'REPTILE'
                  ? Colors.green.shade100
                  : Colors.blue.shade100,
              child: Icon(
                cls.code == 'REPTILE' ? Icons.pets : Icons.water_drop,
                color: cls.code == 'REPTILE'
                    ? Colors.green.shade700
                    : Colors.blue.shade700,
              ),
            ),
            title: Text(cls.nameKr),
            subtitle: Text(cls.nameEn),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() => _selectedClass = cls),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.errorWithDetail(e.toString()))),
    );
  }

  Widget _buildOrdersList() {
    final ordersAsync = ref.watch(ordersProvider(_selectedClass!.id));
    return ordersAsync.when(
      data: (orders) => ListView.separated(
        itemCount: orders.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final order = orders[index];
          return ListTile(
            title: Text(order.nameKr),
            subtitle: Text(order.nameEn),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() => _selectedOrder = order),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.errorWithDetail(e.toString()))),
    );
  }

  Widget _buildFamiliesList() {
    final familiesAsync = ref.watch(familiesProvider(_selectedOrder!.id));
    return familiesAsync.when(
      data: (families) => ListView.separated(
        itemCount: families.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final family = families[index];
          return ListTile(
            title: Text(family.nameKr),
            subtitle: Text(family.nameEn),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() => _selectedFamily = family),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.errorWithDetail(e.toString()))),
    );
  }

  Widget _buildGeneraList() {
    final generaAsync = ref.watch(generaProvider(_selectedFamily!.id));
    return generaAsync.when(
      data: (genera) => ListView.separated(
        itemCount: genera.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final genus = genera[index];
          return ListTile(
            title: Text(genus.nameKr),
            subtitle: Text(genus.nameEn),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() => _selectedGenus = genus),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.errorWithDetail(e.toString()))),
    );
  }

  Widget _buildSpeciesList() {
    final speciesAsync =
        ref.watch(speciesByGenusProvider(_selectedGenus!.id));
    return speciesAsync.when(
      data: (speciesList) => ListView.separated(
        itemCount: speciesList.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final species = speciesList[index];
          return ListTile(
            title: Text(species.displayName),
            subtitle: Text(
              species.scientificName,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (species.isWhitelist)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(Icons.check_circle_outline),
              ],
            ),
            onTap: () => _onSpeciesSelected(species),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.errorWithDetail(e.toString()))),
    );
  }
}
