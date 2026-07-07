enum UserRole { user, admin, helpdesk }

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:
        return "Admin";
      case UserRole.helpdesk:
        return "Helpdesk";
      case UserRole.user:
        return "User";
    }
  }

  static UserRole fromName(String name) {
    return UserRole.values.firstWhere(
          (e) => e.name == name,
      orElse: () => UserRole.user,
    );
  }
}
