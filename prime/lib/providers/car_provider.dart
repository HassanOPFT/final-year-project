import 'package:flutter/foundation.dart';

import '../controllers/car_controller.dart';
import '../models/car.dart';

class CarProvider extends ChangeNotifier {
  final _carController = CarController();

  Future<String> createCar({
    required String hostId,
    required String hostBankAccountId,
    required String manufacturer,
    required String model,
    required int manufactureYear,
    required String color,
    required EngineType engineType,
    required TransmissionType transmissionType,
    required int seats,
    required CarType carType,
    required double hourPrice,
    required double dayPrice,
    required List<String> carImagesPaths,
    required String? description,
  }) async {
    try {
      final newCarId = await _carController.createCar(
        hostId: hostId,
        hostBankAccountId: hostBankAccountId,
        manufacturer: manufacturer,
        model: model,
        manufactureYear: manufactureYear,
        color: color,
        engineType: engineType,
        transmissionType: transmissionType,
        seats: seats,
        carType: carType,
        hourPrice: hourPrice,
        dayPrice: dayPrice,
        carImagesPaths: carImagesPaths,
        description: description,
      );
      notifyListeners();
      return newCarId;
    } catch (_) {
      rethrow;
    }
  }

  // get car by car id
  Future<Car?> getCarById(String carId) async {
    try {
      final car = await _carController.getCarById(carId);
      return car;
    } catch (_) {
      rethrow;
    }
  }

  Future<List<Car>> getCarsByHostId(String userId) async {
    try {
      final cars = await _carController.getCarsByHostId(userId);
      return cars;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> hasCarsWithHostId(String hostId) async {
    try {
      final hasCars = await _carController.hasCarsWithHostId(hostId);
      return hasCars;
    } catch (_) {
      rethrow;
    }
  }
}
