enum LogType {
  feeding('FEEDING'),
  shedding('SHEDDING'),
  defecation('DEFECATION'),
  mating('MATING'),
  eggLaying('EGG_LAYING'),
  candling('CANDLING'),
  hatching('HATCHING');

  const LogType(this.value);
  final String value;

  static LogType fromValue(String value) {
    return LogType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => LogType.feeding,
    );
  }
}
