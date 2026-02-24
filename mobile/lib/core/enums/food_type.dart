enum FoodType {
  liveInsect('LIVE_INSECT'),
  frozenPrey('FROZEN_PREY'),
  pellet('PELLET'),
  fruit('FRUIT'),
  vegetable('VEGETABLE'),
  supplement('SUPPLEMENT'),
  other('OTHER');

  const FoodType(this.value);
  final String value;

  static FoodType fromValue(String value) {
    return FoodType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FoodType.other,
    );
  }
}
