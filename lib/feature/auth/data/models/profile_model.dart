import '../../../../core/models/user_role.dart';

export '../../../../core/models/user_role.dart' show UserRole, UserRoleX;

class AppProfile {
  final String id; 
  final String username;
  final String? fullName;
  final UserRole role;

  final bool isActive;

  AppProfile({
    required this.id,
    required this.username,
    required this.role,
    this.fullName,
    this.isActive = true,
  });

  factory AppProfile.fromRow(Map<String, dynamic> row) => AppProfile(
    id: row['id'] as String,
    username: row['username'] as String,
    fullName: row['full_name'] as String?,
    role: UserRoleX.fromName(row['role'] as String),
    isActive: row['is_active'] as bool? ?? true,
  );

  AppProfile copyWith({UserRole? role, bool? isActive, String? fullName}) => AppProfile(
    id: id,
    username: username,
    fullName: fullName ?? this.fullName,
    role: role ?? this.role,
    isActive: isActive ?? this.isActive,
  );
}
