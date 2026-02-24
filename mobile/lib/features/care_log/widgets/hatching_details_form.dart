import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HatchingDetailsForm extends StatefulWidget {
  final Map<String, dynamic>? initialDetails;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const HatchingDetailsForm({
    super.key,
    this.initialDetails,
    required this.onChanged,
  });

  @override
  State<HatchingDetailsForm> createState() => _HatchingDetailsFormState();
}

class _HatchingDetailsFormState extends State<HatchingDetailsForm> {
  late final TextEditingController _hatchedCountController;
  late final TextEditingController _failedCountController;
  late final TextEditingController _hatchNotesController;

  @override
  void initState() {
    super.initState();
    final d = widget.initialDetails;

    _hatchedCountController = TextEditingController(
      text: d?['hatched_count'] != null
          ? d!['hatched_count'].toString()
          : '',
    );

    _failedCountController = TextEditingController(
      text: d?['failed_count'] != null
          ? d!['failed_count'].toString()
          : '',
    );

    _hatchNotesController = TextEditingController(
      text: d?['hatch_notes'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _hatchedCountController.dispose();
    _failedCountController.dispose();
    _hatchNotesController.dispose();
    super.dispose();
  }

  void _emitChange() {
    final details = <String, dynamic>{};

    if (_hatchedCountController.text.isNotEmpty) {
      details['hatched_count'] = int.tryParse(_hatchedCountController.text);
    }

    if (_failedCountController.text.isNotEmpty) {
      details['failed_count'] = int.tryParse(_failedCountController.text);
    }

    if (_hatchNotesController.text.trim().isNotEmpty) {
      details['hatch_notes'] = _hatchNotesController.text.trim();
    }

    widget.onChanged(details);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hatched Count / Failed Count row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _hatchedCountController,
                decoration: InputDecoration(
                  labelText: '${l10n.hatchedCount} *',
                  prefixIcon: const Icon(Icons.egg_alt),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.requiredField;
                  }
                  return null;
                },
                onChanged: (_) => _emitChange(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _failedCountController,
                decoration: InputDecoration(
                  labelText: '${l10n.failedCount} *',
                  prefixIcon: const Icon(Icons.cancel),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.requiredField;
                  }
                  return null;
                },
                onChanged: (_) => _emitChange(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Hatch Notes
        TextFormField(
          controller: _hatchNotesController,
          decoration: InputDecoration(
            labelText: l10n.hatchNotes,
            prefixIcon: const Icon(Icons.note),
          ),
          maxLines: 3,
          onChanged: (_) => _emitChange(),
        ),
      ],
    );
  }
}
