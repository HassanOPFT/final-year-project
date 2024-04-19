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
  ActivityStatus? userActivityStatus;
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
