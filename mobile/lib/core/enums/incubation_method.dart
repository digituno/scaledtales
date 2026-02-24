enum IncubationMethod {
  natural('NATURAL'),
  artificial('ARTIFICIAL'),
  none('NONE');

  const IncubationMethod(this.value);
  final String value;

  static IncubationMethod fromValue(String value) {
    return IncubationMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => IncubationMethod.none,
    );
  }
}
