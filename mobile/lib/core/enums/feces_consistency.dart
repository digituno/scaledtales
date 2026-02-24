enum FecesConsistency {
  normal('NORMAL'),
  soft('SOFT'),
  hard('HARD'),
  watery('WATERY'),
  bloody('BLOODY'),
  mucus('MUCUS');

  const FecesConsistency(this.value);
  final String value;

  static FecesConsistency fromValue(String value) {
    return FecesConsistency.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FecesConsistency.normal,
    );
  }
}
