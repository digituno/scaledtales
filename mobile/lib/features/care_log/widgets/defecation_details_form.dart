import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/enums/enums.dart';
import '../../../core/utils/enum_labels.dart';

class DefecationDetailsForm extends StatefulWidget {
  final Map<String, dynamic>? initialDetails;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const DefecationDetailsForm({
    super.key,
    this.initialDetails,
    required this.onChanged,
  });

  @override
  State<DefecationDetailsForm> createState() => _DefecationDetailsFormState();
}

class _DefecationDetailsFormState extends State<DefecationDetailsForm> {
  late bool _fecesPresent;
  FecesConsistency? _fecesConsistency;
  late final TextEditingController _fecesColorController;
  late bool _uratePresent;
  UrateCondition? _urateCondition;
  late final TextEditingController _abnormalitiesController;

  @override
  void initState() {
    super.initState();
    final d = widget.initialDetails;

    _fecesPresent = d?['feces_present'] as bool? ?? true;

    _fecesConsistency = d != null && d['feces_consistency'] != null
        ? FecesConsistency.fromValue(d['feces_consistency'] as String)
        : null;

    _fecesColorController = TextEditingController(
      text: d?['feces_color'] as String? ?? '',
    );

    _uratePresent = d?['urate_present'] as bool? ?? true;

    _urateCondition = d != null && d['urate_condition'] != null
        ? UrateCondition.fromValue(d['urate_condition'] as String)
        : null;

    _abnormalitiesController = TextEditingController(
      text: d?['abnormalities'] as String? ?? '',
    );

    // 초기 기본값을 부모에게 emit (사용자가 아무것도 건드리지 않아도 _details에 반영)
    WidgetsBinding.instance.addPostFrameCallback((_) => _emitChange());
  }

  @override
  void dispose() {
    _fecesColorController.dispose();
    _abnormalitiesController.dispose();
    super.dispose();
  }

  void _emitChange() {
    final details = <String, dynamic>{
      'feces_present': _fecesPresent,
      'urate_present': _uratePresent,
    };

    if (_fecesPresent && _fecesConsistency != null) {
      details['feces_consistency'] = _fecesConsistency!.value;
    }

    if (_fecesPresent && _fecesColorController.text.trim().isNotEmpty) {
      details['feces_color'] = _fecesColorController.text.trim();
    }

    if (_uratePresent && _urateCondition != null) {
      details['urate_condition'] = _urateCondition!.value;
    }

    if (_abnormalitiesController.text.trim().isNotEmpty) {
      details['abnormalities'] = _abnormalitiesController.text.trim();
    }

    widget.onChanged(details);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Feces Present switch
        SwitchListTile(
          title: Text('${l10n.fecesPresent} *'),
          value: _fecesPresent,
          onChanged: (v) {
            setState(() => _fecesPresent = v);
            _emitChange();
          },
          contentPadding: EdgeInsets.zero,
        ),

        // Feces details (conditional)
        if (_fecesPresent) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<FecesConsistency>(
            value: _fecesConsistency,
            decoration: InputDecoration(
              labelText: l10n.fecesConsistency,
              prefixIcon: const Icon(Icons.circle),
            ),
            items: FecesConsistency.values
                .map((fc) => DropdownMenuItem(
                      value: fc,
                      child: Text(fecesConsistencyLabel(fc, l10n)),
                    ))
                .toList(),
            onChanged: (v) {
              setState(() => _fecesConsistency = v);
              _emitChange();
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _fecesColorController,
            decoration: InputDecoration(
              labelText: l10n.fecesColor,
              hintText: l10n.fecesColorHint,
              prefixIcon: const Icon(Icons.palette),
            ),
            onChanged: (_) => _emitChange(),
          ),
          const SizedBox(height: 16),
        ],

        // Urate Present switch
        SwitchListTile(
          title: Text('${l10n.uratePresent} *'),
          value: _uratePresent,
          onChanged: (v) {
            setState(() => _uratePresent = v);
            _emitChange();
          },
          contentPadding: EdgeInsets.zero,
        ),

        // Urate details (conditional)
        if (_uratePresent) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<UrateCondition>(
            value: _urateCondition,
            decoration: InputDecoration(
              labelText: l10n.urateCondition,
              prefixIcon: const Icon(Icons.water_drop),
            ),
            items: UrateCondition.values
                .map((uc) => DropdownMenuItem(
                      value: uc,
                      child: Text(urateConditionLabel(uc, l10n)),
                    ))
                .toList(),
            onChanged: (v) {
              setState(() => _urateCondition = v);
              _emitChange();
            },
          ),
          const SizedBox(height: 16),
        ],

        // Abnormalities
        TextFormField(
          controller: _abnormalitiesController,
          decoration: InputDecoration(
            labelText: l10n.abnormalities,
            hintText: l10n.abnormalitiesHint,
            prefixIcon: const Icon(Icons.report_problem),
          ),
          maxLines: 2,
          onChanged: (_) => _emitChange(),
        ),
      ],
    );
  }

}
