import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/enums.dart';
import '../../../core/utils/enum_labels.dart';
import '../providers/care_log_provider.dart';

class EggLayingDetailsForm extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialDetails;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final String? animalId;

  const EggLayingDetailsForm({
    super.key,
    this.initialDetails,
    required this.onChanged,
    this.animalId,
  });

  @override
  ConsumerState<EggLayingDetailsForm> createState() =>
      _EggLayingDetailsFormState();
}

class _EggLayingDetailsFormState extends ConsumerState<EggLayingDetailsForm> {
  late final TextEditingController _eggCountController;
  late final TextEditingController _fertileCountController;
  late final TextEditingController _infertileCountController;
  late final TextEditingController _clutchNumberController;
  late bool _incubationPlanned;
  IncubationMethod? _incubationMethod;
  late final TextEditingController _incubationTempController;
  late final TextEditingController _incubationHumidityController;
  DateTime? _expectedHatchDate;
  String? _matingLogId;

  @override
  void initState() {
    super.initState();
    final d = widget.initialDetails;

    _eggCountController = TextEditingController(
      text: d?['egg_count'] != null ? d!['egg_count'].toString() : '',
    );

    _fertileCountController = TextEditingController(
      text: d?['fertile_count'] != null ? d!['fertile_count'].toString() : '',
    );

    _infertileCountController = TextEditingController(
      text: d?['infertile_count'] != null
          ? d!['infertile_count'].toString()
          : '',
    );

    _clutchNumberController = TextEditingController(
      text: d?['clutch_number'] != null
          ? d!['clutch_number'].toString()
          : '',
    );

    _incubationPlanned = d?['incubation_planned'] as bool? ?? false;

    _incubationMethod = d != null && d['incubation_method'] != null
        ? IncubationMethod.fromValue(d['incubation_method'] as String)
        : null;

    _incubationTempController = TextEditingController(
      text: d?['incubation_temp'] != null
          ? d!['incubation_temp'].toString()
          : '',
    );

    _incubationHumidityController = TextEditingController(
      text: d?['incubation_humidity'] != null
          ? d!['incubation_humidity'].toString()
          : '',
    );

    if (d != null && d['expected_hatch_date'] != null) {
      _expectedHatchDate =
          DateTime.tryParse(d['expected_hatch_date'] as String);
    }

    _matingLogId = d?['mating_log_id'] as String?;
  }

  @override
  void dispose() {
    _eggCountController.dispose();
    _fertileCountController.dispose();
    _infertileCountController.dispose();
    _clutchNumberController.dispose();
    _incubationTempController.dispose();
    _incubationHumidityController.dispose();
    super.dispose();
  }

  void _emitChange() {
    final details = <String, dynamic>{
      'incubation_planned': _incubationPlanned,
    };

    if (_eggCountController.text.isNotEmpty) {
      details['egg_count'] = int.tryParse(_eggCountController.text);
    }

    if (_fertileCountController.text.isNotEmpty) {
      details['fertile_count'] = int.tryParse(_fertileCountController.text);
    }

    if (_infertileCountController.text.isNotEmpty) {
      details['infertile_count'] =
          int.tryParse(_infertileCountController.text);
    }

    if (_clutchNumberController.text.isNotEmpty) {
      details['clutch_number'] = int.tryParse(_clutchNumberController.text);
    }

    if (_incubationPlanned) {
      if (_incubationMethod != null) {
        details['incubation_method'] = _incubationMethod!.value;
      }
      if (_incubationTempController.text.isNotEmpty) {
        details['incubation_temp'] =
            double.tryParse(_incubationTempController.text);
      }
      if (_incubationHumidityController.text.isNotEmpty) {
        details['incubation_humidity'] =
            double.tryParse(_incubationHumidityController.text);
      }
      if (_expectedHatchDate != null) {
        details['expected_hatch_date'] =
            _expectedHatchDate!.toIso8601String().split('T').first;
      }
    }

    if (_matingLogId != null) {
      details['mating_log_id'] = _matingLogId;
    }

    widget.onChanged(details);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Egg Count (required)
        TextFormField(
          controller: _eggCountController,
          decoration: InputDecoration(
            labelText: '${l10n.eggCount} *',
            prefixIcon: const Icon(Icons.egg),
          ),
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return '${l10n.eggCount}을 입력해주세요';
            }
            return null;
          },
          onChanged: (_) => _emitChange(),
        ),
        const SizedBox(height: 16),

        // Fertile / Infertile Count row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _fertileCountController,
                decoration: InputDecoration(
                  labelText: l10n.fertileCount,
                  prefixIcon: const Icon(Icons.check_circle),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _emitChange(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _infertileCountController,
                decoration: InputDecoration(
                  labelText: l10n.infertileCount,
                  prefixIcon: const Icon(Icons.cancel),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _emitChange(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Clutch Number
        TextFormField(
          controller: _clutchNumberController,
          decoration: InputDecoration(
            labelText: l10n.clutchNumber,
            prefixIcon: const Icon(Icons.tag),
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => _emitChange(),
        ),
        const SizedBox(height: 16),

        // Incubation Planned switch
        SwitchListTile(
          title: Text('${l10n.incubationPlanned} *'),
          value: _incubationPlanned,
          onChanged: (v) {
            setState(() => _incubationPlanned = v);
            _emitChange();
          },
          contentPadding: EdgeInsets.zero,
        ),

        // Incubation details (conditional)
        if (_incubationPlanned) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<IncubationMethod>(
            value: _incubationMethod,
            decoration: InputDecoration(
              labelText: l10n.incubationMethod,
              prefixIcon: const Icon(Icons.thermostat),
            ),
            items: IncubationMethod.values
                .where((m) => m != IncubationMethod.none)
                .map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(incubationMethodLabel(m, l10n)),
                    ))
                .toList(),
            onChanged: (v) {
              setState(() => _incubationMethod = v);
              _emitChange();
            },
          ),
          const SizedBox(height: 16),

          // Temp / Humidity row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _incubationTempController,
                  decoration: InputDecoration(
                    labelText: l10n.incubationTemp,
                    prefixIcon: const Icon(Icons.thermostat),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _emitChange(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _incubationHumidityController,
                  decoration: InputDecoration(
                    labelText: l10n.incubationHumidity,
                    prefixIcon: const Icon(Icons.water),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => _emitChange(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Expected Hatch Date
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _expectedHatchDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _expectedHatchDate = date);
                _emitChange();
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.expectedHatchDate,
                prefixIcon: const Icon(Icons.calendar_today),
                suffixIcon: _expectedHatchDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _expectedHatchDate = null);
                          _emitChange();
                        },
                      )
                    : null,
              ),
              child: Text(
                _expectedHatchDate != null
                    ? DateFormat('yyyy-MM-dd').format(_expectedHatchDate!)
                    : '',
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Mating Log selector
        if (widget.animalId != null) _buildMatingLogSelector(l10n),
      ],
    );
  }

  Widget _buildMatingLogSelector(AppLocalizations l10n) {
    final logsAsync = ref.watch(filteredCareLogsProvider(
      (animalId: widget.animalId!, logType: 'MATING'),
    ));

    return logsAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const SizedBox.shrink(),
      data: (logs) {
        if (logs.isEmpty) return const SizedBox.shrink();

        return DropdownButtonFormField<String>(
          value: _matingLogId,
          decoration: InputDecoration(
            labelText: l10n.selectMatingLog,
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
              return DropdownMenuItem(
                value: log.id,
                child: Text('${l10n.logTypeMating} - $label'),
              );
            }),
          ],
          onChanged: (id) {
            setState(() => _matingLogId = id);
            _emitChange();
          },
        );
      },
    );
  }

}
