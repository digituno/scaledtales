enum FeedingMethod {
  handFed('HAND_FED'),
  tongs('TONGS'),
  bowl('BOWL'),
  freeRoaming('FREE_ROAMING'),
  other('OTHER');

  const FeedingMethod(this.value);
  final String value;

  static FeedingMethod fromValue(String value) {
    return FeedingMethod.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FeedingMethod.other,
    );
  }
}
