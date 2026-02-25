import '../../../core/enums/enums.dart';

class UserProfile {
  final String id;
  final String email;
  final UserRole role;
  final String createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        email: json['email'] as String,
        role: UserRole.fromValue(json['role'] as String? ?? 'user'),
        createdAt: json['created_at'] as String,
      );
}
