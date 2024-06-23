import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prime/models/status_history.dart';
import 'package:prime/utils/generate_reference_number.dart';

import '../models/car_rental.dart';
import 'status_history_controller.dart';

class CarRentalController {
  static const String _carRentalCollectionName = 'CarRental';
  static const String _carIdFieldName = 'carId';
  static const String _customerIdFieldName = 'customerId';
  static const String _startDateFieldName = 'startDate';
  static const String _endDateFieldName = 'endDate';
  static const String _ratingFieldName = 'rating';
  static const String _reviewFieldName = 'review';
  static const String _statusFieldName = 'status';
  static const String _referenceNumberFieldName = 'referenceNumber';
  static const String _stripeChargeIdFieldName = 'stripeChargeId';
  static const String _extensionCountFieldName = 'extensionCount';
  static const String _createdAtFieldName = 'createdAt';

  final _carRentalCollection =
      FirebaseFirestore.instance.collection(_carRentalCollectionName);
  final _statusHistoryController = StatusHistoryController();

  Future<String> createCarRental({
    required String carId,
    required customerId,
    required DateTime startDate,
    required DateTime endDate,
    required String stripeChargeId,
  }) async {
    if (startDate.isAfter(endDate)) {
      throw Exception('Start date cannot be after end date');
    }
    if (carId.isEmpty || customerId.isEmpty || stripeChargeId.isEmpty) {
      throw Exception(
          'Car ID, Customer ID, and Stripe Charge ID cannot be empty');
    }

    const newCarRentalStatus = CarRentalStatus.rentedByCustomer;
    final carRentalReferenceNumber = generateReferenceNumber('CR');

    try {
      final newCarRental = await _carRentalCollection.add({
        _carIdFieldName: carId,
        _customerIdFieldName: customerId,
        _startDateFieldName: Timestamp.fromDate(startDate),
        _endDateFieldName: Timestamp.fromDate(endDate),
        _ratingFieldName: 0.0,
        _reviewFieldName: '',
        _statusFieldName: newCarRentalStatus.name,
        _referenceNumberFieldName: carRentalReferenceNumber,
        _stripeChargeIdFieldName: stripeChargeId,
        _extensionCountFieldName: 0,
        _createdAtFieldName: Timestamp.fromDate(DateTime.now()),
      });

      // Create StatusHistory Record
      await _statusHistoryController.createStatusHistory(
        StatusHistory(
          linkedObjectId: newCarRental.id,
          linkedObjectType: 'CarRental',
          linkedObjectSubtype: '',
          previousStatus: newCarRentalStatus.name,
          newStatus: newCarRentalStatus.name,
          statusDescription: '',
          modifiedById: customerId,
        ),
      );
      return newCarRental.id;
    } catch (_) {
      rethrow;
    }
  }

  Future<List<CarRental>> getCarRentalsByCustomerIdAndStatuses(
    String customerId,
    List<CarRentalStatus> statuses,
  ) async {
    try {
      final carRentals = await _carRentalCollection
          .where(_customerIdFieldName, isEqualTo: customerId)
          .where(_statusFieldName,
              whereIn: statuses.map((status) => status.name).toList())
          .get();

      return carRentals.docs
          .map((carRental) => _fromMap(carRental.id, carRental.data()))
          .toList();
    } catch (_) {
      rethrow;
    }
  }

  CarRental _fromMap(String carRentalId, Map<String, dynamic> map) {
    return CarRental(
      id: carRentalId,
      carId: map[_carIdFieldName],
      customerId: map[_customerIdFieldName],
      startDate: map[_startDateFieldName] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map[_startDateFieldName].millisecondsSinceEpoch)
          : null,
      endDate: map[_endDateFieldName] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map[_endDateFieldName].millisecondsSinceEpoch)
          : null,
      rating: map[_ratingFieldName]?.toDouble(),
      review: map[_reviewFieldName],
      status: map[_statusFieldName] != null
          ? CarRentalStatus.values.byName(map[_statusFieldName])
          : null,
      referenceNumber: map[_referenceNumberFieldName],
      stripeChargeId: map[_stripeChargeIdFieldName],
      extensionCount: map[_extensionCountFieldName],
      createdAt: map[_createdAtFieldName] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map[_createdAtFieldName].millisecondsSinceEpoch)
          : null,
    );
  }

  Future<CarRental?> getCarRentalById(String carRentalId) async {
    try {
      final carRentalSnapshot =
          await _carRentalCollection.doc(carRentalId).get();

      if (carRentalSnapshot.exists) {
        return _fromMap(carRentalSnapshot.id, carRentalSnapshot.data()!);
      }

      return null;
    } catch (_) {
      rethrow;
    }
  }

  Future<List<CarRental>> getCarRentalsByCarId(String carId) async {
    try {
      final carRentals = await _carRentalCollection
          .where(_carIdFieldName, isEqualTo: carId)
          .get();

      return carRentals.docs
          .map((carRental) => _fromMap(carRental.id, carRental.data()))
          .toList();
    } catch (_) {
      rethrow;
    }
  }

  Future<List<CarRental>> getCarRentalsByCarIdAndStatuses(
    String carId,
    List<CarRentalStatus> statuses,
  ) async {
    try {
      final carRentals = await _carRentalCollection
          .where(_carIdFieldName, isEqualTo: carId)
          .where(_statusFieldName,
              whereIn: statuses.map((status) => status.name).toList())
          .get();

      return carRentals.docs
          .map((carRental) => _fromMap(carRental.id, carRental.data()))
          .toList();
    } catch (_) {
      rethrow;
    }
  }

  Future<List<CarRental>> getCarRentalsByStatuses(
    List<CarRentalStatus> statuses,
  ) async {
    try {
      final carRentals = await _carRentalCollection
          .where(_statusFieldName,
              whereIn: statuses.map((status) => status.name).toList())
          .get();

      return carRentals.docs
          .map((carRental) => _fromMap(carRental.id, carRental.data()))
          .toList();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateCarRentalStatus({
    required String carRentalId,
    required CarRentalStatus previousStatus,
    required CarRentalStatus newStatus,
    String? statusDescription = '',
    required String modifiedById,
  }) async {
    try {
      DocumentReference carRentalRef = _carRentalCollection.doc(
        carRentalId,
      );

      await carRentalRef.update({
        _statusFieldName: newStatus.name,
      });

      // Create StatusHistory Record
      await _statusHistoryController.createStatusHistory(
        StatusHistory(
          linkedObjectId: carRentalId,
          linkedObjectType: 'CarRental',
          linkedObjectSubtype: '',
          previousStatus: previousStatus.name,
          newStatus: newStatus.name,
          statusDescription: statusDescription,
          modifiedById: modifiedById,
        ),
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateReviewAndRating({
    required String carRentalId,
    String? review,
    required double rating,
  }) async {
    try {
      if (rating < 0 || rating > 5) {
        throw Exception('Rating must be between 0 and 5');
      }
      if (carRentalId.isEmpty) {
        throw Exception('Car Rental ID cannot be empty');
      }
      DocumentReference carRentalRef = _carRentalCollection.doc(
        carRentalId,
      );

      await carRentalRef.update({
        _reviewFieldName: review ?? '',
        _ratingFieldName: rating,
      });
    } catch (_) {
      rethrow;
    }
  }

  Future<List<CarRentalStatus>> getCarRentalStatuses() async {
    try {
      final carRentals = await _carRentalCollection.get();

      return carRentals.docs
          .map((carRental) => carRental.data()[_statusFieldName])
          .toSet()
          .map((status) => CarRentalStatus.values.byName(status))
          .toList();
    } catch (_) {
      rethrow;
    }
  }
}
