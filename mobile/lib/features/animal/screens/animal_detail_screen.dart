import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/enums/enums.dart';
import '../models/animal_model.dart';
import '../providers/animal_provider.dart';
import 'animal_edit_screen.dart';
import '../../measurement/widgets/measurement_tab.dart';
import '../../care_log/widgets/care_log_tab.dart';

class AnimalDetailScreen extends ConsumerWidget {
  final String animalId;

  const AnimalDetailScreen({super.key, required this.animalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(animalDetailProvider(animalId));
    final l10n = AppLocalizations.of(context)!;

    // _AnimalDetailView already returns its own Scaffold with SliverAppBar.
    // loading/error states use a minimal Scaffold wrapper.
    return detailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.errorMessage),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(animalDetailProvider(animalId)),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
      data: (animal) => _AnimalDetailView(
        animal: animal,
        animalId: animalId,
      ),
    );
  }
}

class _AnimalDetailView extends ConsumerWidget {
  final AnimalDetail animal;
  final String animalId;

  const _AnimalDetailView({required this.animal, required this.animalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                title: Text(animal.name),
                flexibleSpace: FlexibleSpaceBar(
                  background: _HeroSection(animal: animal),
                ),
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final result =
                            await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) =>
                                AnimalEditScreen(animal: animal),
                          ),
                        );
                        if (result == true) {
                          ref.invalidate(animalDetailProvider(animalId));
                          ref.read(animalListProvider.notifier).refresh();
                        }
                      } else if (value == 'delete') {
                        _confirmDelete(context, ref, l10n);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit),
                            const SizedBox(width: 8),
                            Text(l10n.editAnimal),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete,
                                color: Theme.of(context).colorScheme.error),
                            const SizedBox(width: 8),
                            Text(l10n.deleteAnimal,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  TabBar(
                    tabs: [
                      Tab(text: l10n.infoTab),
                      Tab(text: l10n.measurementTab),
                      Tab(text: l10n.logTab),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _InfoTab(animal: animal),
              MeasurementTab(animalId: animalId),
              CareLogTab(animalId: animalId),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteAnimalConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(animalListProvider.notifier).deleteAnimalById(animalId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.deletedMessage)),
          );
          Navigator.of(context).pop();
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

class _HeroSection extends StatelessWidget {
  final AnimalDetail animal;

  const _HeroSection({required this.animal});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 48,
              backgroundImage: animal.profileImageUrl != null
                  ? CachedNetworkImageProvider(animal.profileImageUrl!)
                  : null,
              child: animal.profileImageUrl == null
                  ? const Icon(Icons.pets, size: 40)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              animal.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              animal.species.displayName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (animal.morph != null)
              Text(
                animal.morph!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  final AnimalDetail animal;

  const _InfoTab({required this.animal});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final sexLabel = switch (Sex.fromValue(animal.sex)) {
      Sex.male => l10n.sexMale,
      Sex.female => l10n.sexFemale,
      Sex.unknown => l10n.sexUnknown,
    };

    final originLabel = switch (OriginType.fromValue(animal.originType)) {
      OriginType.cb => l10n.originTypeCb,
      OriginType.wc => l10n.originTypeWc,
      OriginType.ch => l10n.originTypeCh,
      OriginType.cf => l10n.originTypeCf,
      OriginType.unknown => l10n.originTypeUnknown,
    };

    final sourceLabel =
        switch (AcquisitionSource.fromValue(animal.acquisitionSource)) {
      AcquisitionSource.breeder => l10n.acquisitionSourceBreeder,
      AcquisitionSource.petShop => l10n.acquisitionSourcePetShop,
      AcquisitionSource.private_ => l10n.acquisitionSourcePrivate,
      AcquisitionSource.rescued => l10n.acquisitionSourceRescued,
      AcquisitionSource.bred => l10n.acquisitionSourceBred,
      AcquisitionSource.other => l10n.acquisitionSourceOther,
    };

    final statusLabel = switch (AnimalStatus.fromValue(animal.status)) {
      AnimalStatus.alive => l10n.statusAlive,
      AnimalStatus.deceased => l10n.statusDeceased,
      AnimalStatus.rehomed => l10n.statusRehomed,
    };

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          title: l10n.basicInfo,
          children: [
            _InfoRow(label: l10n.animalSex, value: sexLabel),
            _InfoRow(label: l10n.animalBirth, value: animal.birthDisplay),
            if (animal.morph != null)
              _InfoRow(label: l10n.animalMorph, value: animal.morph!),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: l10n.originInfo,
          children: [
            _InfoRow(label: l10n.originType, value: originLabel),
            if (animal.originCountry != null)
              _InfoRow(label: l10n.originCountry, value: animal.originCountry!),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: l10n.acquisitionInfo,
          children: [
            _InfoRow(label: l10n.acquisitionDate, value: animal.acquisitionDate),
            _InfoRow(label: l10n.acquisitionSource, value: sourceLabel),
            if (animal.acquisitionNote != null)
              _InfoRow(
                  label: l10n.acquisitionNote, value: animal.acquisitionNote!),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: l10n.parentInfo,
          children: [
            _InfoRow(
              label: l10n.fatherAnimal,
              value: animal.father?.name ?? '-',
            ),
            _InfoRow(
              label: l10n.motherAnimal,
              value: animal.mother?.name ?? '-',
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          title: l10n.currentStatus,
          children: [
            _InfoRow(label: l10n.status, value: statusLabel),
            if (animal.currentWeight != null)
              _InfoRow(
                label: l10n.weight,
                value: '${animal.currentWeight!.toStringAsFixed(1)}g',
              ),
            if (animal.currentLength != null)
              _InfoRow(
                label: l10n.length,
                value: '${animal.currentLength!.toStringAsFixed(1)}cm',
              ),
            if (animal.lastMeasuredAt != null)
              _InfoRow(
                label: '최근 측정일',
                value: animal.lastMeasuredAt!,
              ),
          ],
        ),
        if (animal.notes != null && animal.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionCard(
            title: l10n.notes,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(animal.notes!),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
