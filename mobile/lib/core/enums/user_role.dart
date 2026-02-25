enum UserRole {
  admin('admin'),
  seller('seller'),
  proBreeder('pro_breeder'),
  user('user'),
  suspended('suspended');

  const UserRole(this.value);
  final String value;

  static UserRole fromValue(String value) => UserRole.values.firstWhere(
        (e) => e.value == value,
        orElse: () => UserRole.user,
      );

  /// suspended가 아닌 모든 role은 쓰기 권한 보유
  bool get canWrite => this != UserRole.suspended;
}
