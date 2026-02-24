import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/enums.dart';
import '../../../core/utils/enum_labels.dart';
import '../../animal/providers/animal_provider.dart';
import '../models/care_log_model.dart';
import '../providers/care_log_provider.dart';
import '../widgets/feeding_details_form.dart';
import '../widgets/shedding_details_form.dart';
import '../widgets/defecation_details_form.dart';
import '../widgets/mating_details_form.dart';
import '../widgets/egg_laying_details_form.dart';
import '../widgets/candling_details_form.dart';
import '../widgets/hatching_details_form.dart';

class CareLogFormScreen extends ConsumerStatefulWidget {
  final String? animalId; // pre-selected animal (from animal detail tab)
  final CareLog? careLog; // null = create, non-null = edit

  const CareLogFormScreen({
    super.key,
    this.animalId,
    this.careLog,
  });

  @override
  ConsumerState<CareLogFormScreen> createState() => _CareLogFormScreenState();
}

class _CareLogFormScreenState extends ConsumerState<CareLogFormScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;
  final _detailsFormKey = GlobalKey<FormState>();

  // Step 1: Animal & Log Type
  String? _selectedAnimalId;
  String? _selectedAnimalName;
  LogType _logType = LogType.feeding;
  String? _parentLogId; // for CANDLING/HATCHING → EGG_LAYING parent

  // Step 2: Date & Time
  late DateTime _logDate;
  late TimeOfDay _logTime;

  // Step 3: Details
  Map<String, dynamic> _details = {};

  // Step 4: Photos & Memo
  final List<File> _imageFiles = [];
  late final TextEditingController _notesController;

  bool get _isEditing => widget.careLog != null;

  /// Whether current log type supports parent_log_id
  bool get _needsParentLog =>
      _logType == LogType.candling || _logType == LogType.hatching;

  @override
  void initState() {
    super.initState();
    final log = widget.careLog;

    if (log != null) {
      // Edit mode: populate from existing care log
      _selectedAnimalId = log.animalId;
      _selectedAnimalName = log.animalName;
      _logType = LogType.fromValue(log.logType);
      final dt = DateTime.tryParse(log.logDate) ?? DateTime.now();
      _logDate = dt;
      _logTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      _details = Map<String, dynamic>.from(log.details);
      _notesController = TextEditingController(text: log.notes ?? '');
      _parentLogId = log.parentLogId;
    } else {
      // Create mode
      _selectedAnimalId = widget.animalId;
      _logDate = DateTime.now();
      _logTime = TimeOfDay.now();
      _notesController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editCareLog : l10n.addCareLog),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        onStepTapped: (step) {
          if (step < _currentStep) {
            setState(() => _currentStep = step);
          }
        },
        controlsBuilder: (context, details) {
          final isLast = _currentStep == 3;
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                FilledButton(
                  onPressed: _isSubmitting ? null : details.onStepContinue,
                  child: _isSubmitting && isLast
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isLast ? l10n.save : l10n.next),
                ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: Text(l10n.previous),
                  ),
              ],
            ),
          );
        },
        steps: [
          // Step 1: Animal & Type
          Step(
            title: Text(l10n.stepAnimalType),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: _buildStep1(l10n),
          ),
          // Step 2: Date/Time
          Step(
            title: Text(l10n.stepDateTime),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: _buildStep2(l10n),
          ),
          // Step 3: Details
          Step(
            title: Text(l10n.stepDetails),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            content: _buildStep3(l10n),
          ),
          // Step 4: Photos & Memo
          Step(
            title: Text(l10n.stepPhotoMemo),
            isActive: _currentStep >= 3,
            state: StepState.indexed,
            content: _buildStep4(l10n),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Animal & Log Type ──
  Widget _buildStep1(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animal selector (skip if pre-selected and not editing)
        if (widget.animalId == null || _isEditing) ...[
          _AnimalDropdown(
            selectedAnimalId: _selectedAnimalId,
            onChanged: (id, name) {
              setState(() {
                _selectedAnimalId = id;
                _selectedAnimalName = name;
              });
            },
          ),
          const SizedBox(height: 16),
        ] else ...[
          // Show pre-selected animal name
          if (_selectedAnimalName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.selectAnimal,
                  prefixIcon: const Icon(Icons.pets),
                ),
                child: Text(_selectedAnimalName!),
              ),
            ),
        ],

        // Log Type selector
        DropdownButtonFormField<LogType>(
          value: _logType,
          decoration: InputDecoration(
            labelText: '${l10n.selectLogType} *',
            prefixIcon: const Icon(Icons.category),
          ),
          items: LogType.values
              .map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(logTypeLabel(t, l10n)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              setState(() {
                _logType = v;
                _details = {}; // reset details when type changes
                _parentLogId = null; // reset parent log
              });
            }
          },
        ),

        // Parent log selector (CANDLING/HATCHING only)
        if (_needsParentLog) ...[
          const SizedBox(height: 16),
          _buildParentLogSelector(l10n),
        ],
      ],
    );
  }

  // ── Parent Log Selector (for CANDLING/HATCHING) ──
  Widget _buildParentLogSelector(AppLocalizations l10n) {
    final animalId = _selectedAnimalId ?? widget.animalId;
    if (animalId == null) {
      return Text(l10n.selectAnimal,
          style: Theme.of(context).textTheme.bodySmall);
    }

    final logsAsync = ref.watch(filteredCareLogsProvider(
      (animalId: animalId, logType: 'EGG_LAYING'),
    ));

    return logsAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
      data: (logs) {
        if (logs.isEmpty) return const SizedBox.shrink();

        return DropdownButtonFormField<String>(
          value: _parentLogId,
          decoration: InputDecoration(
            labelText: l10n.selectParentLog,
            prefixIcon: const Icon(Icons.link),
          ),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(l10n.noneSelected),
            ),
            ...logs.map((log) {
              final date = DateTime.tryParse(log.logDate);
              final label = date != null
                  ? DateFormat('yyyy-MM-dd').format(date)
                  : log.logDate;
              final eggCount = log.details['egg_count'] ?? '';
              return DropdownMenuItem(
                value: log.id,
                child: Text('${l10n.logTypeEggLaying} $label ($eggCount)'),
              );
            }),
          ],
          onChanged: (id) {
            setState(() => _parentLogId = id);
          },
        );
      },
    );
  }

  // ── Step 2: Date & Time ──
  Widget _buildStep2(AppLocalizations l10n) {
    return Column(
      children: [
        // Date picker
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _logDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() => _logDate = date);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.logDate,
              prefixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(DateFormat('yyyy-MM-dd').format(_logDate)),
          ),
        ),
        const SizedBox(height: 16),

        // Time picker
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _logTime,
                  );
                  if (time != null) {
                    setState(() => _logTime = time);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.logTime,
                    prefixIcon: const Icon(Icons.access_time),
                  ),
                  child: Text(
                    '${_logTime.hour.toString().padLeft(2, '0')}:${_logTime.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () {
                final now = TimeOfDay.now();
                setState(() {
                  _logDate = DateTime.now();
                  _logTime = now;
                });
              },
              child: Text(l10n.nowButton),
            ),
          ],
        ),
      ],
    );
  }

  // ── Step 3: Type-specific Details ──
  Widget _buildStep3(AppLocalizations l10n) {
    return Form(
      key: _detailsFormKey,
      child: _buildDetailsForType(l10n),
    );
  }

  Widget _buildDetailsForType(AppLocalizations l10n) {
    final animalId = _selectedAnimalId ?? widget.animalId;

    return switch (_logType) {
      LogType.feeding => FeedingDetailsForm(
          initialDetails: _details.isNotEmpty ? _details : null,
          onChanged: (d) => _details = d,
        ),
      LogType.shedding => SheddingDetailsForm(
          initialDetails: _details.isNotEmpty ? _details : null,
          onChanged: (d) => _details = d,
        ),
      LogType.defecation => DefecationDetailsForm(
          initialDetails: _details.isNotEmpty ? _details : null,
          onChanged: (d) => _details = d,
        ),
      LogType.mating => MatingDetailsForm(
          initialDetails: _details.isNotEmpty ? _details : null,
          onChanged: (d) => _details = d,
          currentAnimalId: animalId,
        ),
      LogType.eggLaying => EggLayingDetailsForm(
          initialDetails: _details.isNotEmpty ? _details : null,
          onChanged: (d) => _details = d,
          animalId: animalId,
        ),
      LogType.candling => CandlingDetailsForm(
          initialDetails: _details.isNotEmpty ? _details : null,
          onChanged: (d) => _details = d,
        ),
      LogType.hatching => HatchingDetailsForm(
          initialDetails: _details.isNotEmpty ? _details : null,
          onChanged: (d) => _details = d,
        ),
    };
  }

  // ── Step 4: Photos & Memo ──
  Widget _buildStep4(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image picker
        Text(l10n.addPhotos, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._imageFiles.asMap().entries.map((entry) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      entry.value,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _imageFiles.removeAt(entry.key)),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }),
            if (_imageFiles.length < 3)
              InkWell(
                onTap: _pickImage,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add_a_photo,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Notes
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: l10n.notes,
            prefixIcon: const Icon(Icons.note_outlined),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() => _imageFiles.add(File(image.path)));
    }
  }

  // ── Navigation ──
  void _onStepContinue() {
    if (_currentStep == 0) {
      // Validate step 1: animal and type selected
      final animalId = _selectedAnimalId ?? widget.animalId;
      if (animalId == null) {
        _showError(AppLocalizations.of(context)!.selectAnimal);
        return;
      }
    }

    if (_currentStep == 2) {
      // Validate step 3: details form
      if (!_detailsFormKey.currentState!.validate()) return;
      if (!_validateDetailsForType()) return;
    }

    if (_currentStep == 3) {
      _submit();
      return;
    }

    setState(() => _currentStep += 1);
  }

  /// Type-specific required field validation
  bool _validateDetailsForType() {
    final l10n = AppLocalizations.of(context)!;

    switch (_logType) {
      case LogType.feeding:
        if (_details['food_item'] == null ||
            (_details['food_item'] as String).trim().isEmpty) {
          _showError('${l10n.foodItem}을 입력해주세요');
          return false;
        }
        return true;

      case LogType.shedding:
        if (_details['shed_completion'] == null) {
          _showError('${l10n.shedCompletion}을 선택해주세요');
          return false;
        }
        return true;

      case LogType.defecation:
        // feces_present and urate_present are always set by switch (default true)
        return true;

      case LogType.mating:
        if (_details['mating_success'] == null) {
          _showError('${l10n.matingSuccess}을 선택해주세요');
          return false;
        }
        return true;

      case LogType.eggLaying:
        if (_details['egg_count'] == null) {
          _showError('${l10n.eggCount}을 입력해주세요');
          return false;
        }
        return true;

      case LogType.candling:
        if (_details['day_after_laying'] == null ||
            _details['fertile_count'] == null ||
            _details['infertile_count'] == null ||
            _details['stopped_development'] == null) {
          _showError(l10n.requiredFieldsMissing);
          return false;
        }
        return true;

      case LogType.hatching:
        if (_details['hatched_count'] == null ||
            _details['failed_count'] == null) {
          _showError(l10n.requiredFieldsMissing);
          return false;
        }
        return true;
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ── Submit ──
  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final l10n = AppLocalizations.of(context)!;

    try {
      // Upload images first
      List<Map<String, dynamic>>? imageData;
      if (_imageFiles.isNotEmpty) {
        final urls =
            await uploadCareLogImages(_imageFiles.map((f) => f.path).toList());
        imageData = urls.asMap().entries.map((e) {
          return {
            'url': e.value,
            'order': e.key,
          };
        }).toList();
      }

      // Also include existing images in edit mode
      if (_isEditing &&
          widget.careLog!.images != null &&
          widget.careLog!.images!.isNotEmpty &&
          _imageFiles.isEmpty) {
        imageData =
            widget.careLog!.images!.map((img) => img.toJson()).toList();
      }

      // Build log date with time
      final logDateTime = DateTime(
        _logDate.year,
        _logDate.month,
        _logDate.day,
        _logTime.hour,
        _logTime.minute,
      );

      final data = <String, dynamic>{
        'log_type': _logType.value,
        'log_date': logDateTime.toIso8601String(),
        'details': _details,
      };

      if (imageData != null) {
        data['images'] = imageData;
      }

      if (_notesController.text.trim().isNotEmpty) {
        data['notes'] = _notesController.text.trim();
      }

      // Add parent_log_id if selected
      if (_parentLogId != null) {
        data['parent_log_id'] = _parentLogId;
      }

      final animalId = _selectedAnimalId ?? widget.animalId!;

      if (_isEditing) {
        await ref
            .read(careLogListProvider(animalId).notifier)
            .updateById(widget.careLog!.id, data);
        ref.invalidate(allCareLogsProvider);
      } else {
        await ref.read(careLogListProvider(animalId).notifier).create(data);
        ref.invalidate(allCareLogsProvider);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.savedMessage)),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithDetail(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

}

/// Dropdown widget that loads animals from provider
class _AnimalDropdown extends ConsumerWidget {
  final String? selectedAnimalId;
  final void Function(String id, String name) onChanged;

  const _AnimalDropdown({
    required this.selectedAnimalId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final animalsAsync = ref.watch(animalListProvider);

    return animalsAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => Text(l10n.errorMessage),
      data: (animals) {
        return DropdownButtonFormField<String>(
          value: selectedAnimalId,
          decoration: InputDecoration(
            labelText: '${l10n.selectAnimal} *',
            prefixIcon: const Icon(Icons.pets),
          ),
          items: animals
              .map((a) => DropdownMenuItem(
                    value: a.id,
                    child: Text(a.name),
                  ))
              .toList(),
          onChanged: (id) {
            if (id != null) {
              final animal = animals.firstWhere((a) => a.id == id);
              onChanged(id, animal.name);
            }
          },
          validator: (v) {
            if (v == null) return '${l10n.selectAnimal}을 선택해주세요';
            return null;
          },
        );
      },
    );
  }
}
