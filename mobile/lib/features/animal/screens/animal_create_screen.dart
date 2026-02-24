import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/enums.dart';
import '../../species/models/species_models.dart';
import '../../species/screens/species_search_screen.dart';
import '../providers/animal_provider.dart';
import '../models/animal_model.dart';

class AnimalCreateScreen extends ConsumerStatefulWidget {
  const AnimalCreateScreen({super.key});

  @override
  ConsumerState<AnimalCreateScreen> createState() => _AnimalCreateScreenState();
}

class _AnimalCreateScreenState extends ConsumerState<AnimalCreateScreen> {
  int _currentStep = 0;
  final _formKeys = List.generate(5, (_) => GlobalKey<FormState>());
  bool _isSubmitting = false;

  // Step 1: Species
  SpeciesSummary? _selectedSpecies;

  // Step 2: Basic Info
  final _nameController = TextEditingController();
  final _morphController = TextEditingController();
  Sex _sex = Sex.unknown;
  int? _birthYear;
  int? _birthMonth;
  int? _birthDay;

  // Step 3: Origin/Acquisition
  OriginType _originType = OriginType.unknown;
  DateTime _acquisitionDate = DateTime.now();
  AcquisitionSource _acquisitionSource = AcquisitionSource.other;
  final _acquisitionNoteController = TextEditingController();

  // Step 4: Parent
  AnimalSummary? _father;
  AnimalSummary? _mother;

  // Step 5: Photo & Notes
  File? _profileImage;
  final _weightController = TextEditingController();
  final _lengthController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _morphController.dispose();
    _acquisitionNoteController.dispose();
    _weightController.dispose();
    _lengthController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addAnimal)),
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
                      : Text(isLastStep ? l10n.done : l10n.next),
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
          _buildPhotoNoteStep(l10n),
        ],
      ),
    );
  }

  // Step 1: Species Selection
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
            if (_selectedSpecies != null) ...[
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.pets)),
                  title: Text(_selectedSpecies!.displayName),
                  subtitle: Text(
                    _selectedSpecies!.scientificName,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedSpecies = null),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.of(context).push<SpeciesSummary>(
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
              label: Text(_selectedSpecies == null
                  ? l10n.speciesSearch
                  : l10n.searchOtherSpecies),
            ),
          ],
        ),
      ),
    );
  }

  // Step 2: Basic Info
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
                    decoration: InputDecoration(labelText: l10n.animalBirthYear),
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

  // Step 3: Origin/Acquisition
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

  // Step 4: Parent Info
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
                final maleAnimals =
                    animals.where((a) => a.sex == 'MALE').toList();
                final femaleAnimals =
                    animals.where((a) => a.sex == 'FEMALE').toList();

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

  // Step 5: Photo & Notes
  Step _buildPhotoNoteStep(AppLocalizations l10n) {
    return Step(
      title: Text(l10n.stepPhotoNote),
      isActive: _currentStep >= 4,
      state: StepState.indexed,
      content: Form(
        key: _formKeys[4],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    image: _profileImage != null
                        ? DecorationImage(
                            image: FileImage(_profileImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _profileImage == null
                      ? const Icon(Icons.add_a_photo, size: 40)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: l10n.currentWeight,
                      prefixIcon: const Icon(Icons.scale_outlined),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lengthController,
                    decoration: InputDecoration(
                      labelText: l10n.currentLength,
                      prefixIcon: const Icon(Icons.straighten_outlined),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
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
      // Upload profile image if selected
      String? profileUrl;
      if (_profileImage != null) {
        profileUrl = await uploadProfileImage(_profileImage!);
      }

      // Build request body
      final data = <String, dynamic>{
        'species_id': _selectedSpecies!.id,
        'name': _nameController.text.trim(),
        'sex': _sex.value,
        'origin_type': _originType.value,
        'acquisition_date':
            DateFormat('yyyy-MM-dd').format(_acquisitionDate),
        'acquisition_source': _acquisitionSource.value,
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
      if (_father != null) data['father_id'] = _father!.id;
      if (_mother != null) data['mother_id'] = _mother!.id;
      if (profileUrl != null) data['profile_image_url'] = profileUrl;
      if (_weightController.text.isNotEmpty) {
        data['current_weight'] = double.parse(_weightController.text);
      }
      if (_lengthController.text.isNotEmpty) {
        data['current_length'] = double.parse(_lengthController.text);
      }
      if (_notesController.text.isNotEmpty) {
        data['notes'] = _notesController.text.trim();
      }

      await ref.read(animalListProvider.notifier).create(data);

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
