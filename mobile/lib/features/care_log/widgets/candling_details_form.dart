import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CandlingDetailsForm extends StatefulWidget {
  final Map<String, dynamic>? initialDetails;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const CandlingDetailsForm({
    super.key,
    this.initialDetails,
    required this.onChanged,
  });

  @override
  State<CandlingDetailsForm> createState() => _CandlingDetailsFormState();
}

class _CandlingDetailsFormState extends State<CandlingDetailsForm> {
  late final TextEditingController _dayAfterLayingController;
  late final TextEditingController _fertileCountController;
  late final TextEditingController _infertileCountController;
  late final TextEditingController _stoppedDevelopmentController;

  int get _totalViable {
    final fertile = int.tryParse(_fertileCountController.text) ?? 0;
    final stopped = int.tryParse(_stoppedDevelopmentController.text) ?? 0;
    return fertile - stopped;
  }

  @override
  void initState() {
    super.initState();
    final d = widget.initialDetails;

    _dayAfterLayingController = TextEditingController(
      text: d?['day_after_laying'] != null
          ? d!['day_after_laying'].toString()
          : '',
    );

    _fertileCountController = TextEditingController(
      text: d?['fertile_count'] != null
          ? d!['fertile_count'].toString()
          : '',
    );

    _infertileCountController = TextEditingController(
      text: d?['infertile_count'] != null
          ? d!['infertile_count'].toString()
          : '',
    );

    _stoppedDevelopmentController = TextEditingController(
      text: d?['stopped_development'] != null
          ? d!['stopped_development'].toString()
          : '',
    );

    // 초기 기본값을 부모에게 emit (사용자가 아무것도 건드리지 않아도 _details에 반영)
    WidgetsBinding.instance.addPostFrameCallback((_) => _emitChange());
  }

  @override
  void dispose() {
    _dayAfterLayingController.dispose();
    _fertileCountController.dispose();
    _infertileCountController.dispose();
    _stoppedDevelopmentController.dispose();
    super.dispose();
  }

  void _emitChange() {
    final details = <String, dynamic>{};

    if (_dayAfterLayingController.text.isNotEmpty) {
      details['day_after_laying'] =
          int.tryParse(_dayAfterLayingController.text);
    }

    if (_fertileCountController.text.isNotEmpty) {
      details['fertile_count'] = int.tryParse(_fertileCountController.text);
    }

    if (_infertileCountController.text.isNotEmpty) {
      details['infertile_count'] =
          int.tryParse(_infertileCountController.text);
    }

    if (_stoppedDevelopmentController.text.isNotEmpty) {
      details['stopped_development'] =
          int.tryParse(_stoppedDevelopmentController.text);
    }

    details['total_viable'] = _totalViable;

    widget.onChanged(details);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day After Laying
        TextFormField(
          controller: _dayAfterLayingController,
          decoration: InputDecoration(
            labelText: '${l10n.dayAfterLaying} *',
            prefixIcon: const Icon(Icons.calendar_today),
          ),
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return '${l10n.dayAfterLaying}을 입력해주세요';
            }
            return null;
          },
          onChanged: (_) {
            setState(() {}); // rebuild to update total_viable
            _emitChange();
          },
        ),
        const SizedBox(height: 16),

        // Fertile / Infertile Count row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _fertileCountController,
                decoration: InputDecoration(
                  labelText: '${l10n.fertileCount} *',
                  prefixIcon: const Icon(Icons.check_circle),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.requiredField;
                  }
                  return null;
                },
                onChanged: (_) {
                  setState(() {});
                  _emitChange();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _infertileCountController,
                decoration: InputDecoration(
                  labelText: '${l10n.infertileCount} *',
                  prefixIcon: const Icon(Icons.cancel),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return l10n.requiredField;
                  }
                  return null;
                },
                onChanged: (_) {
                  setState(() {});
                  _emitChange();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Stopped Development
        TextFormField(
          controller: _stoppedDevelopmentController,
          decoration: InputDecoration(
            labelText: '${l10n.stoppedDevelopment} *',
            prefixIcon: const Icon(Icons.pause_circle),
          ),
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return '${l10n.stoppedDevelopment}을 입력해주세요';
            }
            return null;
          },
          onChanged: (_) {
            setState(() {});
            _emitChange();
          },
        ),
        const SizedBox(height: 16),

        // Total Viable (auto-calculated, read-only)
        InputDecorator(
          decoration: InputDecoration(
            labelText: '${l10n.totalViable} (${l10n.fertileCount} - ${l10n.stoppedDevelopment})',
            prefixIcon: const Icon(Icons.egg_alt),
          ),
          child: Text(
            '$_totalViable',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _totalViable >= 0
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
          ),
        ),
      ],
    );
  }
}
