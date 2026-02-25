import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/enums/enums.dart';
import '../../../core/utils/enum_labels.dart';

class SheddingDetailsForm extends StatefulWidget {
  final Map<String, dynamic>? initialDetails;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const SheddingDetailsForm({
    super.key,
    this.initialDetails,
    required this.onChanged,
  });

  @override
  State<SheddingDetailsForm> createState() => _SheddingDetailsFormState();
}

class _SheddingDetailsFormState extends State<SheddingDetailsForm> {
  late ShedCompletion _shedCompletion;
  late final TextEditingController _problemAreasController;
  late bool _assistanceNeeded;
  late final TextEditingController _assistanceMethodController;
  late final TextEditingController _humidityController;

  @override
  void initState() {
    super.initState();
    final d = widget.initialDetails;

    _shedCompletion = d != null && d['shed_completion'] != null
        ? ShedCompletion.fromValue(d['shed_completion'] as String)
        : ShedCompletion.complete;

    _problemAreasController = TextEditingController(
      text: d != null && d['problem_areas'] != null
          ? (d['problem_areas'] as List).cast<String>().join(', ')
          : '',
    );

    _assistanceNeeded =
        d != null && d['assistance_needed'] == true;

    _assistanceMethodController = TextEditingController(
      text: d?['assistance_method'] as String? ?? '',
    );

    _humidityController = TextEditingController(
      text: d?['humidity_level'] != null
          ? d!['humidity_level'].toString()
          : '',
    );

    // 초기 기본값을 부모에게 emit (사용자가 아무것도 건드리지 않아도 _details에 반영)
    WidgetsBinding.instance.addPostFrameCallback((_) => _emitChange());
  }

  @override
  void dispose() {
    _problemAreasController.dispose();
    _assistanceMethodController.dispose();
    _humidityController.dispose();
    super.dispose();
  }

  void _emitChange() {
    final details = <String, dynamic>{
      'shed_completion': _shedCompletion.value,
    };

    if (_problemAreasController.text.trim().isNotEmpty) {
      details['problem_areas'] = _problemAreasController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    details['assistance_needed'] = _assistanceNeeded;

    if (_assistanceNeeded &&
        _assistanceMethodController.text.trim().isNotEmpty) {
      details['assistance_method'] = _assistanceMethodController.text.trim();
    }

    if (_humidityController.text.isNotEmpty) {
      details['humidity_level'] =
          double.tryParse(_humidityController.text) ??
              int.tryParse(_humidityController.text);
    }

    widget.onChanged(details);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shed Completion dropdown
        DropdownButtonFormField<ShedCompletion>(
          value: _shedCompletion,
          decoration: InputDecoration(
            labelText: '${l10n.shedCompletion} *',
            prefixIcon: const Icon(Icons.auto_awesome),
          ),
          items: ShedCompletion.values
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(shedCompletionLabel(s, l10n)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              setState(() => _shedCompletion = v);
              _emitChange();
            }
          },
        ),
        const SizedBox(height: 16),

        // Problem Areas text field
        TextFormField(
          controller: _problemAreasController,
          decoration: InputDecoration(
            labelText: l10n.problemAreas,
            hintText: l10n.problemAreasHint,
            prefixIcon: const Icon(Icons.warning_amber),
          ),
          onChanged: (_) => _emitChange(),
        ),
        const SizedBox(height: 16),

        // Assistance Needed switch
        SwitchListTile(
          title: Text(l10n.assistanceNeeded),
          value: _assistanceNeeded,
          onChanged: (v) {
            setState(() => _assistanceNeeded = v);
            _emitChange();
          },
          contentPadding: EdgeInsets.zero,
        ),

        // Assistance Method (conditional)
        if (_assistanceNeeded) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _assistanceMethodController,
            decoration: InputDecoration(
              labelText: l10n.assistanceMethod,
              hintText: l10n.assistanceMethodHint,
              prefixIcon: const Icon(Icons.medical_services),
            ),
            onChanged: (_) => _emitChange(),
          ),
          const SizedBox(height: 16),
        ],

        // Humidity Level
        TextFormField(
          controller: _humidityController,
          decoration: InputDecoration(
            labelText: l10n.humidityLevel,
            prefixIcon: const Icon(Icons.water),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => _emitChange(),
        ),
      ],
    );
  }

}
