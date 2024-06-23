import 'package:flutter/material.dart';
import 'package:prime/models/car_rental.dart';

import '../controllers/car_rental_controller.dart';

class CarRentalProvider with ChangeNotifier {
  final _carRentalController = CarRentalController();

  Future<String> createCarRental({
    required String carId,
    required customerId,
    required DateTime startDate,
    required DateTime endDate,
    required String stripeChargeId,
  }) async {
    try {
      final carRentalId = await _carRentalController.createCarRental(
        carId: carId,
        customerId: customerId,
        startDate: startDate,
        endDate: endDate,
        stripeChargeId: stripeChargeId,
      );
      notifyListeners();
      return carRentalId;
    } catch (_) {
      rethrow;
    }
  }

  Future<List<CarRental>> getCarRentalsByCustomerIdAndStatuses(
    String customerId,
    List<CarRentalStatus> statuses,
  ) async {
    try {
      final carRentals =
          await _carRentalController.getCarRentalsByCustomerIdAndStatuses(
        customerId,
        statuses,
      );
      return carRentals;
    } catch (_) {
      rethrow;
    }
  }

  Future<CarRental?> getCarRentalById(String carRentalId) async {
    try {
      final carRental =
          await _carRentalController.getCarRentalById(carRentalId);
      return carRental;
    } catch (_) {
      rethrow;
    }
  }

  Future<List<CarRental>> getCarRentalsByCarId(
    String carId,
  ) async {
    try {
      final carRentals = await _carRentalController.getCarRentalsByCarId(carId);
      return carRentals;
    } catch (_) {
      rethrow;
    }
  }

  Future<List<CarRental>> getCarRentalsByCarIdAndStatuses(
    String carId,
    List<CarRentalStatus> statuses,
  ) async {
    try {
      final carRentals =
          await _carRentalController.getCarRentalsByCarIdAndStatuses(
        carId,
        statuses,
      );
      return carRentals;
    } catch (_) {
      rethrow;
    }
  }

  Future<List<CarRental>> getCarRentalsByStatuses(
    List<CarRentalStatus> statuses,
  ) async {
    try {
      final carRentals = await _carRentalController.getCarRentalsByStatuses(
        statuses,
      );
      return carRentals;
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
      await _carRentalController.updateCarRentalStatus(
        carRentalId: carRentalId,
        previousStatus: previousStatus,
        newStatus: newStatus,
        statusDescription: statusDescription,
        modifiedById: modifiedById,
      );
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateCarRentalReviewAndRating({
    required String carRentalId,
    String? review,
    required double rating,
  }) async {
    try {
      await _carRentalController.updateReviewAndRating(
        carRentalId: carRentalId,
        review: review,
        rating: rating,
      );
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<List<CarRentalStatus>> getCarRentalStatuses() async {
    try {
      final carRentalStatuses =
          await _carRentalController.getCarRentalStatuses();
      return carRentalStatuses;
    } catch (_) {
      rethrow;
    }
  }
}
