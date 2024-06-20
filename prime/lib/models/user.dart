class User {
  String? userId;
  String? userFirstName;
  String? userLastName;
  String? userEmail;
  UserRole? userRole;
  String? userReferenceNumber;
  String? userProfileUrl;
  String? userPhoneNumber;
  String? userFcmToken;
  ActivityStatus? userActivityStatus; // TODO: either implement a feature to manage this or remove it
  bool? notificationsEnabled;
  DateTime? createdAt;

  User({
    this.userId,
    this.userFirstName,
    this.userLastName,
    this.userEmail,
    this.userRole,
    this.userReferenceNumber,
    this.userProfileUrl,
    this.userPhoneNumber,
    this.userFcmToken,
    this.userActivityStatus,
    this.notificationsEnabled,
    this.createdAt,
  });
}

enum UserRole {
  primaryAdmin,
  secondaryAdmin,
  customer,
  host,
}

enum ActivityStatus {
  active,
  halted,
}

extension UserRoleExtension on UserRole {
  String toReadableString() {
    switch (this) {
      case UserRole.primaryAdmin:
        return 'Primary Admin';
      case UserRole.secondaryAdmin:
        return 'Secondary Admin';
      case UserRole.customer:
        return 'Customer';
      case UserRole.host:
        return 'Host';
      default:
        return '';
    }
  }
}

extension ActivityStatusExtension on ActivityStatus {
  String toReadableString() {
    switch (this) {
      case ActivityStatus.active:
        return 'Active';
      case ActivityStatus.halted:
        return 'Halted';
      default:
        return '';
    }
  }
}
