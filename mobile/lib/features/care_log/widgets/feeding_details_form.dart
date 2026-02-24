import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../core/enums/enums.dart';
import '../../../core/utils/enum_labels.dart';

class FeedingDetailsForm extends StatefulWidget {
  final Map<String, dynamic>? initialDetails;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const FeedingDetailsForm({
    super.key,
    this.initialDetails,
    required this.onChanged,
  });

  @override
  State<FeedingDetailsForm> createState() => _FeedingDetailsFormState();
}

class _FeedingDetailsFormState extends State<FeedingDetailsForm> {
  late FoodType _foodType;
  late final TextEditingController _foodItemController;
  late final TextEditingController _quantityController;
  late Unit _unit;
  final Set<String> _supplements = {};
  FeedingResponse? _feedingResponse;
  FeedingMethod? _feedingMethod;

  @override
  void initState() {
    super.initState();
    final d = widget.initialDetails;

    _foodType = d != null && d['food_type'] != null
        ? FoodType.fromValue(d['food_type'] as String)
        : FoodType.liveInsect;

    _foodItemController =
        TextEditingController(text: d?['food_item'] as String? ?? '');

    _quantityController = TextEditingController(
      text: d?['quantity'] != null ? d!['quantity'].toString() : '',
    );

    _unit = d != null && d['unit'] != null
        ? Unit.fromValue(d['unit'] as String)
        : Unit.ea;

    if (d != null && d['supplements'] != null) {
      final list = d['supplements'] as List;
      _supplements.addAll(list.cast<String>());
    }

    _feedingResponse = d != null && d['feeding_response'] != null
        ? FeedingResponse.fromValue(d['feeding_response'] as String)
        : null;

    _feedingMethod = d != null && d['feeding_method'] != null
        ? FeedingMethod.fromValue(d['feeding_method'] as String)
        : null;
  }

  @override
  void dispose() {
    _foodItemController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _emitChange() {
    final details = <String, dynamic>{
      'food_type': _foodType.value,
      'food_item': _foodItemController.text.trim(),
    };

    if (_quantityController.text.isNotEmpty) {
      details['quantity'] = double.tryParse(_quantityController.text) ??
          int.tryParse(_quantityController.text);
      details['unit'] = _unit.value;
    }

    if (_supplements.isNotEmpty) {
      details['supplements'] = _supplements.toList();
    }

    if (_feedingResponse != null) {
      details['feeding_response'] = _feedingResponse!.value;
    }

    if (_feedingMethod != null) {
      details['feeding_method'] = _feedingMethod!.value;
    }

    widget.onChanged(details);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Food Type dropdown
        DropdownButtonFormField<FoodType>(
          value: _foodType,
          decoration: InputDecoration(
            labelText: '${l10n.foodType} *',
            prefixIcon: const Icon(Icons.restaurant_menu),
          ),
          items: FoodType.values
              .map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(foodTypeLabel(t, l10n)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              setState(() => _foodType = v);
              _emitChange();
            }
          },
        ),
        const SizedBox(height: 16),

        // Food Item text
        TextFormField(
          controller: _foodItemController,
          decoration: InputDecoration(
            labelText: '${l10n.foodItem} *',
            hintText: l10n.foodItemHint,
            prefixIcon: const Icon(Icons.fastfood),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return '${l10n.foodItem}을 입력해주세요';
            }
            return null;
          },
          onChanged: (_) => _emitChange(),
        ),
        const SizedBox(height: 16),

        // Quantity + Unit row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: l10n.quantity,
                  prefixIcon: const Icon(Icons.numbers),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _emitChange(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<Unit>(
                value: _unit,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                items: Unit.values
                    .map((u) => DropdownMenuItem(
                          value: u,
                          child: Text(unitLabel(u, l10n)),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _unit = v);
                    _emitChange();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Supplements checkboxes
        Text(l10n.supplements,
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _supplementChip('CALCIUM_POWDER', l10n.calciumPowder),
            _supplementChip('MULTIVITAMIN', l10n.multivitamin),
            _supplementChip('VITAMIN_D3', l10n.vitaminD3),
          ],
        ),
        const SizedBox(height: 16),

        // Feeding Response
        DropdownButtonFormField<FeedingResponse>(
          value: _feedingResponse,
          decoration: InputDecoration(
            labelText: l10n.feedingResponse,
            prefixIcon: const Icon(Icons.sentiment_satisfied_alt),
          ),
          items: FeedingResponse.values
              .map((r) => DropdownMenuItem(
                    value: r,
                    child: Text(feedingResponseLabel(r, l10n)),
                  ))
              .toList(),
          onChanged: (v) {
            setState(() => _feedingResponse = v);
            _emitChange();
          },
        ),
        const SizedBox(height: 16),

        // Feeding Method
        DropdownButtonFormField<FeedingMethod>(
          value: _feedingMethod,
          decoration: InputDecoration(
            labelText: l10n.feedingMethod,
            prefixIcon: const Icon(Icons.pan_tool_alt),
          ),
          items: FeedingMethod.values
              .map((m) => DropdownMenuItem(
                    value: m,
                    child: Text(feedingMethodLabel(m, l10n)),
                  ))
              .toList(),
          onChanged: (v) {
            setState(() => _feedingMethod = v);
            _emitChange();
          },
        ),
      ],
    );
  }

  Widget _supplementChip(String value, String label) {
    final selected = _supplements.contains(value);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (sel) {
        setState(() {
          if (sel) {
            _supplements.add(value);
          } else {
            _supplements.remove(value);
          }
        });
        _emitChange();
      },
    );
  }

}
