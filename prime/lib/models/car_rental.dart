import 'package:prime/models/user.dart';

class CarRental {
  String? id;
  String? carId;
  String? customerId;
  DateTime? startDate;
  DateTime? endDate;
  double? rating;
  String? review;
  CarRentalStatus? status;
  String? referenceNumber;
  String? stripeChargeId;
  int? extensionCount;
  DateTime? createdAt;

  CarRental({
    this.id,
    this.carId,
    this.customerId,
    this.startDate,
    this.endDate,
    this.rating,
    this.review,
    this.status,
    this.referenceNumber,
    this.stripeChargeId,
    this.extensionCount,
    this.createdAt,
  });
}

enum CarRentalStatus {
  rentedByCustomer,
  pickedUpByCustomer,
  customerReportedIssue,
  customerExtendedRental,
  customerReturnedCar,
  hostConfirmedPickup,
  customerCancelled,
  hostReportedIssue,
  hostConfirmedReturn,
  adminConfirmedPayment,
}

extension RentalStatusExtension on CarRentalStatus {
  String getStatusString(UserRole role) {
    switch (this) {
      case CarRentalStatus.rentedByCustomer:
        return 'Upcoming';
      case CarRentalStatus.pickedUpByCustomer:
        return 'Picked';
      case CarRentalStatus.customerReportedIssue:
        return 'Issue Reported By Customer';
      case CarRentalStatus.customerExtendedRental:
        return 'Extended';
      case CarRentalStatus.customerReturnedCar:
        return 'Returned';
      case CarRentalStatus.hostConfirmedPickup:
        return 'Ongoing';
      case CarRentalStatus.customerCancelled:
        return 'Cancelled';
      case CarRentalStatus.hostReportedIssue:
        return 'Issue Reported By Host';
      case CarRentalStatus.hostConfirmedReturn:
        if (role == UserRole.customer) {
          return 'Completed';
        } else {
          return 'Completed & Pending Payout';
        }
      case CarRentalStatus.adminConfirmedPayment:
        if (role == UserRole.host ||
            role == UserRole.primaryAdmin ||
            role == UserRole.secondaryAdmin) {
          return 'Completed & Paid';
        } else {
          return 'Completed';
        }
      default:
        return 'Unknown Status';
    }
  }
}
