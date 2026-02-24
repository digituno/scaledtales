import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/enums.dart';
import '../../species/models/species_models.dart';
import '../../species/screens/species_search_screen.dart';
import '../models/animal_model.dart';
import '../providers/animal_provider.dart';

class AnimalEditScreen extends ConsumerStatefulWidget {
  final AnimalDetail animal;

  const AnimalEditScreen({super.key, required this.animal});

  @override
  ConsumerState<AnimalEditScreen> createState() => _AnimalEditScreenState();
}

class _AnimalEditScreenState extends ConsumerState<AnimalEditScreen> {
  int _currentStep = 0;
  final _formKeys = List.generate(5, (_) => GlobalKey<FormState>());
  bool _isSubmitting = false;

  // Step 1: Species
  late SpeciesSummary? _selectedSpecies;

  // Step 2: Basic Info
  late final TextEditingController _nameController;
  late final TextEditingController _morphController;
  late Sex _sex;
  int? _birthYear;
  int? _birthMonth;
  int? _birthDay;

  // Step 3: Origin/Acquisition
  late OriginType _originType;
  late DateTime _acquisitionDate;
  late AcquisitionSource _acquisitionSource;
  late final TextEditingController _acquisitionNoteController;

  // Step 4: Parent
  AnimalSummary? _father;
  AnimalSummary? _mother;

  // Step 5: Photo & Notes
  File? _profileImage;
  late AnimalStatus _status;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final a = widget.animal;

    _selectedSpecies = SpeciesSummary(
      id: a.species.id,
      scientificName: a.species.scientificName,
      commonNameKr: a.species.commonNameKr,
      commonNameEn: a.species.commonNameEn,
      speciesKr: a.species.commonNameKr ?? a.species.scientificName,
    );

    _nameController = TextEditingController(text: a.name);
    _morphController = TextEditingController(text: a.morph ?? '');
    _sex = Sex.fromValue(a.sex);
    _birthYear = a.birthYear;
    _birthMonth = a.birthMonth;
    _birthDay = a.birthDate;

    _originType = OriginType.fromValue(a.originType);
    _acquisitionDate = DateTime.parse(a.acquisitionDate);
    _acquisitionSource = AcquisitionSource.fromValue(a.acquisitionSource);
    _acquisitionNoteController =
        TextEditingController(text: a.acquisitionNote ?? '');

    _status = AnimalStatus.fromValue(a.status);
    _notesController = TextEditingController(text: a.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _morphController.dispose();
    _acquisitionNoteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editAnimal)),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        onStepTapped: (step) {
          if (step < _currentStep) setState(() => _currentStep = step);
        },
        controlsBuilder: (context, details) {
          final isLastStep = _currentStep == 4;
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: Text(l10n.previous),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: _isSubmitting ? null : details.onStepContinue,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isLastStep ? l10n.save : l10n.next),
                ),
              ],
            ),
          );
        },
        steps: [
          _buildSpeciesStep(l10n),
          _buildBasicInfoStep(l10n),
          _buildOriginStep(l10n),
          _buildParentStep(l10n),
          _buildStatusNoteStep(l10n),
        ],
      ),
    );
  }

  Step _buildSpeciesStep(AppLocalizations l10n) {
    return Step(
      title: Text(l10n.stepSpecies),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedSpecies != null)
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.pets)),
                  title: Text(_selectedSpecies!.displayName),
                  subtitle: Text(
                    _selectedSpecies!.scientificName,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final result =
                    await Navigator.of(context).push<SpeciesSummary>(
                  MaterialPageRoute(
                    builder: (_) =>
                        const SpeciesSearchScreen(selectionMode: true),
                  ),
                );
                if (result != null) {
                  setState(() => _selectedSpecies = result);
                }
              },
              icon: const Icon(Icons.search),
              label: Text(l10n.searchOtherSpecies),
            ),
          ],
        ),
      ),
    );
  }

  Step _buildBasicInfoStep(AppLocalizations l10n) {
    return Step(
      title: Text(l10n.stepBasicInfo),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '${l10n.animalName} *',
                prefixIcon: const Icon(Icons.badge_outlined),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? '이름을 입력해주세요' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _morphController,
              decoration: InputDecoration(
                labelText: l10n.animalMorph,
                prefixIcon: const Icon(Icons.palette_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Text('${l10n.animalSex} *',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<Sex>(
              segments: [
                ButtonSegment(value: Sex.male, label: Text(l10n.sexMale)),
                ButtonSegment(value: Sex.female, label: Text(l10n.sexFemale)),
                ButtonSegment(value: Sex.unknown, label: Text(l10n.sexUnknown)),
              ],
              selected: {_sex},
              onSelectionChanged: (v) => setState(() => _sex = v.first),
            ),
            const SizedBox(height: 16),
            Text(l10n.animalBirth,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _birthYear,
                    decoration:
                        InputDecoration(labelText: l10n.animalBirthYear),
                    items: List.generate(30, (i) => DateTime.now().year - i)
                        .map((y) =>
                            DropdownMenuItem(value: y, child: Text('$y')))
                        .toList(),
                    onChanged: (v) => setState(() => _birthYear = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _birthMonth,
                    decoration:
                        InputDecoration(labelText: l10n.animalBirthMonth),
                    items: List.generate(12, (i) => i + 1)
                        .map((m) =>
                            DropdownMenuItem(value: m, child: Text('$m')))
                        .toList(),
                    onChanged: (v) => setState(() => _birthMonth = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _birthDay,
                    decoration: InputDecoration(labelText: l10n.animalBirthDay),
                    items: List.generate(31, (i) => i + 1)
                        .map((d) =>
                            DropdownMenuItem(value: d, child: Text('$d')))
                        .toList(),
                    onChanged: (v) => setState(() => _birthDay = v),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Step _buildOriginStep(AppLocalizations l10n) {
    return Step(
      title: Text(l10n.stepOriginInfo),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<OriginType>(
              value: _originType,
              decoration: InputDecoration(
                labelText: '${l10n.originType} *',
                prefixIcon: const Icon(Icons.egg_outlined),
              ),
              items: OriginType.values
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(_originTypeLabel(l10n, e)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _originType = v!),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _acquisitionDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _acquisitionDate = date);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '${l10n.acquisitionDate} *',
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('yyyy-MM-dd').format(_acquisitionDate)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AcquisitionSource>(
              value: _acquisitionSource,
              decoration: InputDecoration(
                labelText: '${l10n.acquisitionSource} *',
                prefixIcon: const Icon(Icons.store_outlined),
              ),
              items: AcquisitionSource.values
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(_acquisitionSourceLabel(l10n, e)),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _acquisitionSource = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _acquisitionNoteController,
              decoration: InputDecoration(
                labelText: l10n.acquisitionNote,
                prefixIcon: const Icon(Icons.note_outlined),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Step _buildParentStep(AppLocalizations l10n) {
    final userAnimals = ref.watch(userAnimalsProvider);

    return Step(
      title: Text(l10n.stepParentInfo),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      content: Form(
        key: _formKeys[3],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            userAnimals.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Text(l10n.errorMessage),
              data: (animals) {
                // Exclude self from parent options
                final filtered =
                    animals.where((a) => a.id != widget.animal.id).toList();
                final maleAnimals =
                    filtered.where((a) => a.sex == 'MALE').toList();
                final femaleAnimals =
                    filtered.where((a) => a.sex == 'FEMALE').toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String?>(
                      value: _father?.id,
                      decoration: InputDecoration(
                        labelText: l10n.fatherAnimal,
                        prefixIcon: const Icon(Icons.male),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(l10n.noneSelected),
                        ),
                        ...maleAnimals.map((a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(a.name),
                            )),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _father = v == null
                              ? null
                              : maleAnimals.firstWhere((a) => a.id == v);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      value: _mother?.id,
                      decoration: InputDecoration(
                        labelText: l10n.motherAnimal,
                        prefixIcon: const Icon(Icons.female),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(l10n.noneSelected),
                        ),
                        ...femaleAnimals.map((a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(a.name),
                            )),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _mother = v == null
                              ? null
                              : femaleAnimals.firstWhere((a) => a.id == v);
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Step _buildStatusNoteStep(AppLocalizations l10n) {
    return Step(
      title: Text(l10n.stepPhotoNote),
      isActive: _currentStep >= 4,
      state: StepState.indexed,
      content: Form(
        key: _formKeys[4],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.status, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<AnimalStatus>(
              segments: [
                ButtonSegment(
                    value: AnimalStatus.alive, label: Text(l10n.statusAlive)),
                ButtonSegment(
                    value: AnimalStatus.deceased,
                    label: Text(l10n.statusDeceased)),
                ButtonSegment(
                    value: AnimalStatus.rehomed,
                    label: Text(l10n.statusRehomed)),
              ],
              selected: {_status},
              onSelectionChanged: (v) => setState(() => _status = v.first),
            ),
            const SizedBox(height: 16),
            Text(l10n.profilePhoto,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    image: _profileImage != null
                        ? DecorationImage(
                            image: FileImage(_profileImage!),
                            fit: BoxFit.cover,
                          )
                        : widget.animal.profileImageUrl != null
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(
                                    widget.animal.profileImageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child: (_profileImage == null &&
                          widget.animal.profileImageUrl == null)
                      ? const Icon(Icons.add_a_photo, size: 40)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.notes,
                prefixIcon: const Icon(Icons.note_outlined),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(l10n.selectFromGallery),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(l10n.takePhoto),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;
    final xFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (xFile != null) {
      setState(() => _profileImage = File(xFile.path));
    }
  }

  void _onStepContinue() {
    final l10n = AppLocalizations.of(context)!;
    if (_currentStep == 0 && _selectedSpecies == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.selectSpeciesRequired)),
      );
      return;
    }

    if (_currentStep == 1) {
      if (!_formKeys[1].currentState!.validate()) return;
    }

    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    try {
      String? profileUrl;
      if (_profileImage != null) {
        profileUrl = await uploadProfileImage(_profileImage!);
      }

      final data = <String, dynamic>{
        'species_id': _selectedSpecies!.id,
        'name': _nameController.text.trim(),
        'sex': _sex.value,
        'origin_type': _originType.value,
        'acquisition_date':
            DateFormat('yyyy-MM-dd').format(_acquisitionDate),
        'acquisition_source': _acquisitionSource.value,
        'status': _status.value,
      };

      if (_morphController.text.isNotEmpty) {
        data['morph'] = _morphController.text.trim();
      }
      if (_birthYear != null) data['birth_year'] = _birthYear;
      if (_birthMonth != null) data['birth_month'] = _birthMonth;
      if (_birthDay != null) data['birth_date'] = _birthDay;
      if (_acquisitionNoteController.text.isNotEmpty) {
        data['acquisition_note'] = _acquisitionNoteController.text.trim();
      }
      data['father_id'] = _father?.id;
      data['mother_id'] = _mother?.id;
      if (profileUrl != null) data['profile_image_url'] = profileUrl;
      if (_notesController.text.isNotEmpty) {
        data['notes'] = _notesController.text.trim();
      }

      await ref.read(animalListProvider.notifier).updateById(widget.animal.id, data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.savedMessage)),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorWithDetail(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _originTypeLabel(AppLocalizations l10n, OriginType type) {
    return switch (type) {
      OriginType.cb => l10n.originTypeCb,
      OriginType.wc => l10n.originTypeWc,
      OriginType.ch => l10n.originTypeCh,
      OriginType.cf => l10n.originTypeCf,
      OriginType.unknown => l10n.originTypeUnknown,
    };
  }

  String _acquisitionSourceLabel(
      AppLocalizations l10n, AcquisitionSource source) {
    return switch (source) {
      AcquisitionSource.breeder => l10n.acquisitionSourceBreeder,
      AcquisitionSource.petShop => l10n.acquisitionSourcePetShop,
      AcquisitionSource.private_ => l10n.acquisitionSourcePrivate,
      AcquisitionSource.rescued => l10n.acquisitionSourceRescued,
      AcquisitionSource.bred => l10n.acquisitionSourceBred,
      AcquisitionSource.other => l10n.acquisitionSourceOther,
    };
  }
}
