import 'user.dart';

class Customer extends User {
  String? defaultAddressId;
  String? identityDocumentId;
  String? drivingLicenseDocumentId;
  String? stripeCustomerId;

  Customer({
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
    this.defaultAddressId,
    this.identityDocumentId,
    this.drivingLicenseDocumentId,
    this.stripeCustomerId,
  });
}
