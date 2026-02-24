enum ShedCompletion {
  complete('COMPLETE'),
  partial('PARTIAL'),
  stuck('STUCK'),
  inProgress('IN_PROGRESS');

  const ShedCompletion(this.value);
  final String value;

  static ShedCompletion fromValue(String value) {
    return ShedCompletion.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ShedCompletion.complete,
    );
  }
}
