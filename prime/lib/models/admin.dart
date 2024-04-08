import 'user.dart';

class Admin extends User {
  Admin({
    super.userId,
    super.userFirstName,
    super.userLastName,
    super.userEmail,
    super.userRole,
    super.userReferenceNumber,
    super.userProfileUrl,
    super.userPhoneNumber,
    super.userFcmToken,
    super.userActivityStatus,
    super.notificationsEnabled,
    super.createdAt,
  });
}
