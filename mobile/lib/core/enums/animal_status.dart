enum AnimalStatus {
  alive('ALIVE'),
  deceased('DECEASED'),
  rehomed('REHOMED');

  const AnimalStatus(this.value);
  final String value;

  static AnimalStatus fromValue(String value) {
    return AnimalStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AnimalStatus.alive,
    );
  }
}
