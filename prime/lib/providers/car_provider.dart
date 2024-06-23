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

  Future<Car?> getCarById(String carId) async {
    try {
      final car = await _carController.getCarById(carId);
      return car;
    } catch (_) {
      rethrow;
    }
  }

  Stream<CarStatus> listenToCarStatus(String carId) {
    try {
      return _carController.listenToCarStatus(carId);
    } on Exception catch (_) {
      rethrow;
    }
  }

  Future<List<Car>> getAllCars() async {
    try {
      final cars = await _carController.getAllCars();
      return cars;
    } catch (_) {
      rethrow;
    }
  }

  Future<List<Car>> getCarsByStatusAndUserId({
    required List<String> carStatusList,
    required String currentUserId,
  }) async {
    try {
      final cars = await _carController.getCarsByStatusAndUserId(
        carStatusList: carStatusList,
        currentUserId: currentUserId,
      );
      return cars;
    } catch (_) {
      rethrow;
    }
  }

  Stream<List<Car>> getCarsByStatusAndUserIdStream({
    required List<String> carStatusList,
    required String currentUserId,
  }) {
    return _carController.getCarsByStatusAndUserIdStream(
      carStatusList: carStatusList,
      currentUserId: currentUserId,
    );
  }

  // update car method
  Future<void> updateCar({
    required String carId,
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
    required String modifiedById,
    required CarStatus previousStatus,
    required String referenceNumber,
  }) async {
    try {
      await _carController.updateCar(
        carId: carId,
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
        modifiedById: modifiedById,
        previousStatus: previousStatus,
        referenceNumber: referenceNumber,
      );
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateCarStatus({
    required String carId,
    required CarStatus previousStatus,
    required CarStatus newStatus,
    required String modifiedById,
    String statusDescription = '',
  }) async {
    try {
      await _carController.updateCarStatus(
        carId: carId,
        newStatus: newStatus,
        previousStatus: previousStatus,
        modifiedById: modifiedById,
        statusDescription: statusDescription,
      );
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> setCarRegistrationDocument({
    required String carId,
    required String registrationDocumentId,
  }) async {
    try {
      await _carController.setCarRegistrationDocument(
        carId: carId,
        registrationDocumentId: registrationDocumentId,
      );
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteCarRegistrationDocument({required String carId}) async {
    try {
      await _carController.deleteCarRegistrationDocument(carId: carId);
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> setCarInsuranceDocument({
    required String carId,
    required String insuranceDocumentId,
  }) async {
    try {
      await _carController.setCarInsuranceDocument(
        carId: carId,
        insuranceDocumentId: insuranceDocumentId,
      );
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteCarInsuranceDocument({required String carId}) async {
    try {
      await _carController.deleteCarInsuranceDocument(carId);
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> setCarRoadTaxDocument({
    required String carId,
    required String roadTaxDocumentId,
  }) async {
    try {
      await _carController.setCarRoadTaxDocument(
        carId: carId,
        roadTaxDocumentId: roadTaxDocumentId,
      );
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteCarRoadTaxDocument({required String carId}) async {
    try {
      await _carController.deleteCarRoadTaxDocument(carId);
      notifyListeners();
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

  Future<void> setCarDefaultAddress({
    required String carId,
    required String addressId,
  }) async {
    try {
      await _carController.setCarDefaultAddress(
        carId: carId,
        addressId: addressId,
      );
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteCarDefaultAddress({required String carId}) async {
    try {
      await _carController.deleteCarDefaultAddress(carId);
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteCar({
    required String carId,
    required bool isAdmin,
    required String modifiedById,
    String? statusDescription = '',
  }) async {
    try {
      await _carController.deleteCar(
        carId: carId,
        isAdmin: isAdmin,
        modifiedById: modifiedById,
        statusDescription: statusDescription,
      );
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }

  Future<List<CarStatus>> getCarStatuses() async {
    try {
      final carStatuses = await _carController.getCarStatuses();
      return carStatuses;
    } catch (_) {
      rethrow;
    }
  }
}
