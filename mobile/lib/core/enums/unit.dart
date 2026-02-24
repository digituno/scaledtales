enum Unit {
  ea('EA'),
  g('G'),
  ml('ML');

  const Unit(this.value);
  final String value;

  static Unit fromValue(String value) {
    return Unit.values.firstWhere(
      (e) => e.value == value,
      orElse: () => Unit.ea,
    );
  }
}
