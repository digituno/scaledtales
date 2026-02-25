import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/enums.dart';
import '../../../core/utils/enum_labels.dart';
import '../../animal/providers/animal_provider.dart';

class MatingDetailsForm extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialDetails;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final String? currentAnimalId;

  const MatingDetailsForm({
    super.key,
    this.initialDetails,
    required this.onChanged,
    this.currentAnimalId,
  });

  @override
  ConsumerState<MatingDetailsForm> createState() => _MatingDetailsFormState();
}

class _MatingDetailsFormState extends ConsumerState<MatingDetailsForm> {
  late MatingSuccess _matingSuccess;
  String? _partnerId;
  late final TextEditingController _partnerNameController;
  late final TextEditingController _durationController;
  late final TextEditingController _behaviorNotesController;
  DateTime? _expectedLayingDate;

  @override
  void initState() {
    super.initState();
    final d = widget.initialDetails;

    _matingSuccess = d != null && d['mating_success'] != null
        ? MatingSuccess.fromValue(d['mating_success'] as String)
        : MatingSuccess.attempted;

    _partnerId = d?['partner_id'] as String?;

    _partnerNameController = TextEditingController(
      text: d?['partner_name'] as String? ?? '',
    );

    _durationController = TextEditingController(
      text: d?['duration_minutes'] != null
          ? d!['duration_minutes'].toString()
          : '',
    );

    _behaviorNotesController = TextEditingController(
      text: d?['behavior_notes'] as String? ?? '',
    );

    if (d != null && d['expected_laying_date'] != null) {
      _expectedLayingDate =
          DateTime.tryParse(d['expected_laying_date'] as String);
    }

    // 초기 기본값을 부모에게 emit (사용자가 아무것도 건드리지 않아도 _details에 반영)
    WidgetsBinding.instance.addPostFrameCallback((_) => _emitChange());
  }

  @override
  void dispose() {
    _partnerNameController.dispose();
    _durationController.dispose();
    _behaviorNotesController.dispose();
    super.dispose();
  }

  void _emitChange() {
    final details = <String, dynamic>{
      'mating_success': _matingSuccess.value,
    };

    if (_partnerId != null) {
      details['partner_id'] = _partnerId;
    }

    if (_partnerNameController.text.trim().isNotEmpty) {
      details['partner_name'] = _partnerNameController.text.trim();
    }

    if (_durationController.text.isNotEmpty) {
      details['duration_minutes'] =
          int.tryParse(_durationController.text) ??
              double.tryParse(_durationController.text);
    }

    if (_behaviorNotesController.text.trim().isNotEmpty) {
      details['behavior_notes'] = _behaviorNotesController.text.trim();
    }

    if (_expectedLayingDate != null) {
      details['expected_laying_date'] =
          _expectedLayingDate!.toIso8601String().split('T').first;
    }

    widget.onChanged(details);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mating Success dropdown
        DropdownButtonFormField<MatingSuccess>(
          value: _matingSuccess,
          decoration: InputDecoration(
            labelText: '${l10n.matingSuccess} *',
            prefixIcon: const Icon(Icons.favorite),
          ),
          items: MatingSuccess.values
              .map((ms) => DropdownMenuItem(
                    value: ms,
                    child: Text(matingSuccessLabel(ms, l10n)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              setState(() => _matingSuccess = v);
              _emitChange();
            }
          },
        ),
        const SizedBox(height: 16),

        // Partner selector from user's animals
        _buildPartnerSelector(l10n),
        const SizedBox(height: 16),

        // External partner name
        TextFormField(
          controller: _partnerNameController,
          decoration: InputDecoration(
            labelText: l10n.partnerName,
            prefixIcon: const Icon(Icons.pets),
          ),
          onChanged: (_) => _emitChange(),
        ),
        const SizedBox(height: 16),

        // Duration
        TextFormField(
          controller: _durationController,
          decoration: InputDecoration(
            labelText: l10n.durationMinutes,
            prefixIcon: const Icon(Icons.timer),
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => _emitChange(),
        ),
        const SizedBox(height: 16),

        // Behavior Notes
        TextFormField(
          controller: _behaviorNotesController,
          decoration: InputDecoration(
            labelText: l10n.behaviorNotes,
            prefixIcon: const Icon(Icons.note),
          ),
          maxLines: 2,
          onChanged: (_) => _emitChange(),
        ),
        const SizedBox(height: 16),

        // Expected Laying Date
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _expectedLayingDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() => _expectedLayingDate = date);
              _emitChange();
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.expectedLayingDate,
              prefixIcon: const Icon(Icons.calendar_today),
              suffixIcon: _expectedLayingDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() => _expectedLayingDate = null);
                        _emitChange();
                      },
                    )
                  : null,
            ),
            child: Text(
              _expectedLayingDate != null
                  ? DateFormat('yyyy-MM-dd').format(_expectedLayingDate!)
                  : '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerSelector(AppLocalizations l10n) {
    final animalsAsync = ref.watch(animalListProvider);

    return animalsAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => Text(l10n.errorMessage),
      data: (animals) {
        // Filter out current animal
        final partners = animals
            .where((a) => a.id != widget.currentAnimalId)
            .toList();

        if (partners.isEmpty) {
          return const SizedBox.shrink();
        }

        return DropdownButtonFormField<String>(
          value: _partnerId,
          decoration: InputDecoration(
            labelText: l10n.selectPartner,
            prefixIcon: const Icon(Icons.people),
          ),
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(l10n.noneSelected),
            ),
            ...partners.map((a) => DropdownMenuItem(
                  value: a.id,
                  child: Text(a.name),
                )),
          ],
          onChanged: (id) {
            setState(() {
              _partnerId = id;
              if (id != null) {
                final partner = partners.firstWhere((a) => a.id == id);
                _partnerNameController.text = partner.name;
              }
            });
            _emitChange();
          },
        );
      },
    );
  }

}
