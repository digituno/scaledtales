enum MatingSuccess {
  successful('SUCCESSFUL'),
  attempted('ATTEMPTED'),
  rejected('REJECTED'),
  inProgress('IN_PROGRESS');

  const MatingSuccess(this.value);
  final String value;

  static MatingSuccess fromValue(String value) {
    return MatingSuccess.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MatingSuccess.attempted,
    );
  }
}
