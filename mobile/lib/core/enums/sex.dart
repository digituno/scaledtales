enum Sex {
  male('MALE'),
  female('FEMALE'),
  unknown('UNKNOWN');

  const Sex(this.value);
  final String value;

  static Sex fromValue(String value) {
    return Sex.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Sex.unknown,
    );
  }
}
