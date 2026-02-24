enum UrateCondition {
  normal('NORMAL'),
  yellow('YELLOW'),
  orange('ORANGE'),
  green('GREEN'),
  absent('ABSENT');

  const UrateCondition(this.value);
  final String value;

  static UrateCondition fromValue(String value) {
    return UrateCondition.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UrateCondition.normal,
    );
  }
}
