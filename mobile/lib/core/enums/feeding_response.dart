enum FeedingResponse {
  good('GOOD'),
  normal('NORMAL'),
  poor('POOR'),
  refused('REFUSED');

  const FeedingResponse(this.value);
  final String value;

  static FeedingResponse fromValue(String value) {
    return FeedingResponse.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FeedingResponse.normal,
    );
  }
}
