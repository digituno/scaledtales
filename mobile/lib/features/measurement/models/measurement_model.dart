class MeasurementLog {
  final String id;
  final String animalId;
  final String measuredDate;
  final double? weight;
  final double? length;
  final String? notes;
  final String createdAt;

  const MeasurementLog({
    required this.id,
    required this.animalId,
    required this.measuredDate,
    this.weight,
    this.length,
    this.notes,
    required this.createdAt,
  });

  factory MeasurementLog.fromJson(Map<String, dynamic> json) {
    return MeasurementLog(
      id: json['id'] as String,
      animalId: json['animal_id'] as String,
      measuredDate: json['measured_date'] as String,
      weight: _toDouble(json['weight']),
      length: _toDouble(json['length']),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String,
    );
  }
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
