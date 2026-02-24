enum OriginType {
  cb('CB'),
  wc('WC'),
  ch('CH'),
  cf('CF'),
  unknown('UNKNOWN');

  const OriginType(this.value);
  final String value;

  static OriginType fromValue(String value) {
    return OriginType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OriginType.unknown,
    );
  }
}
