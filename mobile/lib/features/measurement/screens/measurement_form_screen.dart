import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../models/measurement_model.dart';
import '../providers/measurement_provider.dart';

class MeasurementFormScreen extends ConsumerStatefulWidget {
  final String animalId;
  final MeasurementLog? measurement; // null = create, non-null = edit

  const MeasurementFormScreen({
    super.key,
    required this.animalId,
    this.measurement,
  });

  @override
  ConsumerState<MeasurementFormScreen> createState() =>
      _MeasurementFormScreenState();
}

class _MeasurementFormScreenState
    extends ConsumerState<MeasurementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  late DateTime _measuredDate;
  late final TextEditingController _weightController;
  late final TextEditingController _lengthController;
  late final TextEditingController _notesController;

  bool get _isEditing => widget.measurement != null;

  @override
  void initState() {
    super.initState();
    final m = widget.measurement;
    _measuredDate =
        m != null ? DateTime.parse(m.measuredDate) : DateTime.now();
    _weightController =
        TextEditingController(text: m?.weight?.toString() ?? '');
    _lengthController =
        TextEditingController(text: m?.length?.toString() ?? '');
    _notesController = TextEditingController(text: m?.notes ?? '');
  }

  @override
  void dispose() {
    _weightController.dispose();
    _lengthController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editMeasurement : l10n.addMeasurement),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _measuredDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) setState(() => _measuredDate = date);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '${l10n.measuredDate} *',
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('yyyy-MM-dd').format(_measuredDate)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: l10n.weightG,
                prefixIcon: const Icon(Icons.scale_outlined),
                suffixText: 'g',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                  return '올바른 숫자를 입력해주세요';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lengthController,
              decoration: InputDecoration(
                labelText: l10n.lengthCm,
                prefixIcon: const Icon(Icons.straighten_outlined),
                suffixText: 'cm',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                  return '올바른 숫자를 입력해주세요';
                }
                return null;
              },
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
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_weightController.text.isEmpty && _lengthController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('무게 또는 길이를 입력해주세요')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final data = <String, dynamic>{
        'measured_date': DateFormat('yyyy-MM-dd').format(_measuredDate),
      };
      if (_weightController.text.isNotEmpty) {
        data['weight'] = double.parse(_weightController.text);
      }
      if (_lengthController.text.isNotEmpty) {
        data['length'] = double.parse(_lengthController.text);
      }
      if (_notesController.text.isNotEmpty) {
        data['notes'] = _notesController.text.trim();
      }

      if (_isEditing) {
        await ref
            .read(measurementListProvider(widget.animalId).notifier)
            .updateById(widget.measurement!.id, data);
      } else {
        await ref
            .read(measurementListProvider(widget.animalId).notifier)
            .create(data);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.savedMessage)),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  AppLocalizations.of(context)!.errorWithDetail(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
