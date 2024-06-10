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
}
