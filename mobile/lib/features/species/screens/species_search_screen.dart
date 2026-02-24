import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../models/species_models.dart';
import '../providers/species_provider.dart';
import '../widgets/species_list_tile.dart';
import 'species_detail_screen.dart';

class SpeciesSearchScreen extends ConsumerStatefulWidget {
  final bool selectionMode;

  const SpeciesSearchScreen({
    super.key,
    this.selectionMode = false,
  });

  @override
  ConsumerState<SpeciesSearchScreen> createState() =>
      _SpeciesSearchScreenState();
}

class _SpeciesSearchScreenState extends ConsumerState<SpeciesSearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(speciesSearchProvider.notifier).search(query);
    });
  }

  void _onSpeciesTap(SpeciesSummary species) {
    if (widget.selectionMode) {
      Navigator.of(context).pop(species);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SpeciesDetailScreen(speciesId: species.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(speciesSearchProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectionMode ? l10n.speciesSelect : l10n.speciesSearch),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(speciesSearchProvider.notifier).clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: searchState.when(
              data: (results) {
                if (_searchController.text.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          l10n.searchPlaceholder,
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }
                if (results.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noSearchResults,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return SpeciesListTile(
                      species: results[index],
                      onTap: () => _onSpeciesTap(results[index]),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(l10n.errorWithDetail(e.toString())),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
