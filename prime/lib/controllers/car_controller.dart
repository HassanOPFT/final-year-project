import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prime/utils/generate_reference_number.dart';

import '../models/car.dart';
import '../models/status_history.dart';
import '../services/firebase/firebase_storage_service.dart';
import 'status_history_controller.dart';

class CarController {
  static const String _carCollectionName = 'Car';
  static const String _hostIdFieldName = 'hostId';
  static const String _hostBankAccountIdFieldName = 'hostBankAccountId';
  static const String _defaultAddressIdFieldName = 'defaultAddressId';
  static const String _manufacturerFieldName = 'manufacturer';
  static const String _modelFieldName = 'model';
  static const String _manufactureYearFieldName = 'manufactureYear';
  static const String _colorFieldName = 'color';
  static const String _engineTypeFieldName = 'engineType';
  static const String _transmissionFieldName = 'transmission';
  static const String _seatsFieldName = 'seats';
  static const String _carTypeFieldName = 'carType';
  static const String _hourPriceFieldName = 'hourPrice';
  static const String _dayPriceFieldName = 'dayPrice';
  static const String _imagesUrlFieldName = 'imagesUrl';
  static const String _descriptionFieldName = 'description';
  static const String _statusFieldName = 'status';
  static const String _registrationDocumentIdFieldName =
      'registrationDocumentId';
  static const String _roadTaxDocumentIdFieldName = 'roadTaxDocumentId';
  static const String _insuranceDocumentIdFieldName = 'insuranceDocumentId';
  static const String _referenceNumberFieldName = 'referenceNumber';
  static const String _createdAtFieldName = 'createdAt';

  final _carCollection =
      FirebaseFirestore.instance.collection(_carCollectionName);
  final _statusHistoryController = StatusHistoryController();

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
      final carReferenceNumber = generateReferenceNumber('CAR');
      // Upload car images to Firebase Storage
      final imagesUrls = await _uploadCarImages(
        carReferenceNumber,
        carImagesPaths,
      );

      // final referenceNumber = _generateReferenceNumber();
      const newCarStatus = CarStatus.uploaded;

      final newCar = await _carCollection.add({
        _hostIdFieldName: hostId,
        _hostBankAccountIdFieldName: hostBankAccountId,
        _defaultAddressIdFieldName: '',
        _manufacturerFieldName: manufacturer,
        _modelFieldName: model,
        _manufactureYearFieldName: manufactureYear,
        _colorFieldName: color,
        _engineTypeFieldName: engineType.name,
        _transmissionFieldName: transmissionType.name,
        _seatsFieldName: seats,
        _carTypeFieldName: carType.name,
        _hourPriceFieldName: hourPrice,
        _dayPriceFieldName: dayPrice,
        _imagesUrlFieldName: imagesUrls,
        _descriptionFieldName: description,
        _statusFieldName: newCarStatus.name,
        _registrationDocumentIdFieldName: '',
        _roadTaxDocumentIdFieldName: '',
        _insuranceDocumentIdFieldName: '',
        _referenceNumberFieldName: carReferenceNumber,
        _createdAtFieldName: Timestamp.fromDate(DateTime.now()),
      });

      // create status history record for the car
      await _statusHistoryController.createStatusHistory(
        StatusHistory(
          linkedObjectId: newCar.id,
          linkedObjectType: 'Car',
          linkedObjectSubtype: '',
          previousStatus: CarStatus.uploaded.getCarStatusString(),
          newStatus: newCarStatus.getCarStatusString(),
          statusDescription: '',
          modifiedById: hostId,
        ),
      );

      // update car status to pending approval
      await newCar.update({
        _statusFieldName: CarStatus.pendingApproval.name,
      });

      // update status history record for the car
      await _statusHistoryController.createStatusHistory(
        StatusHistory(
          linkedObjectId: newCar.id,
          linkedObjectType: 'Car',
          linkedObjectSubtype: '',
          previousStatus: newCarStatus.getCarStatusString(),
          newStatus: CarStatus.pendingApproval.getCarStatusString(),
          statusDescription: '',
          modifiedById: hostId,
        ),
      );

      return newCar.id;
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<Car?> getCarById(String carId) async {
    try {
      if (carId.isEmpty) {
        throw Exception('Car ID is required');
      }

      final docSnapshot = await _carCollection.doc(carId).get();

      if (!docSnapshot.exists) {
        return null;
      }

      final data = docSnapshot.data()!;
      return Car(
        id: docSnapshot.id,
        hostId: data[_hostIdFieldName],
        hostBankAccountId: data[_hostBankAccountIdFieldName],
        defaultAddressId: data[_defaultAddressIdFieldName],
        manufacturer: data[_manufacturerFieldName],
        model: data[_modelFieldName],
        manufactureYear: data[_manufactureYearFieldName],
        color: data[_colorFieldName],
        engineType: EngineType.values
            .firstWhere((e) => e.name == data[_engineTypeFieldName]),
        transmissionType: TransmissionType.values
            .firstWhere((e) => e.name == data[_transmissionFieldName]),
        seats: data[_seatsFieldName],
        carType:
            CarType.values.firstWhere((e) => e.name == data[_carTypeFieldName]),
        hourPrice: data[_hourPriceFieldName],
        dayPrice: data[_dayPriceFieldName],
        imagesUrl: List<String>.from(data[_imagesUrlFieldName]),
        description: data[_descriptionFieldName],
        status: CarStatus.values
            .firstWhere((e) => e.name == data[_statusFieldName]),
        registrationDocumentId: data[_registrationDocumentIdFieldName],
        roadTaxDocumentId: data[_roadTaxDocumentIdFieldName],
        insuranceDocumentId: data[_insuranceDocumentIdFieldName],
        referenceNumber: data[_referenceNumberFieldName],
        createdAt: (data[_createdAtFieldName] as Timestamp).toDate(),
      );
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<List<Car>> getAllCars() async {
    try {
      final querySnapshot = await _carCollection.get();
      final cars = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Car(
          id: doc.id,
          hostId: data[_hostIdFieldName],
          hostBankAccountId: data[_hostBankAccountIdFieldName],
          defaultAddressId: data[_defaultAddressIdFieldName],
          manufacturer: data[_manufacturerFieldName],
          model: data[_modelFieldName],
          manufactureYear: data[_manufactureYearFieldName],
          color: data[_colorFieldName],
          engineType: EngineType.values.firstWhere(
            (e) => e.name == data[_engineTypeFieldName],
          ),
          transmissionType: TransmissionType.values.firstWhere(
            (e) => e.name == data[_transmissionFieldName],
          ),
          seats: data[_seatsFieldName],
          carType: CarType.values.firstWhere(
            (e) => e.name == data[_carTypeFieldName],
          ),
          hourPrice: data[_hourPriceFieldName],
          dayPrice: data[_dayPriceFieldName],
          imagesUrl: List<String>.from(data[_imagesUrlFieldName]),
          description: data[_descriptionFieldName],
          status: CarStatus.values.firstWhere(
            (e) => e.name == data[_statusFieldName],
          ),
          registrationDocumentId: data[_registrationDocumentIdFieldName],
          roadTaxDocumentId: data[_roadTaxDocumentIdFieldName],
          insuranceDocumentId: data[_insuranceDocumentIdFieldName],
          referenceNumber: data[_referenceNumberFieldName],
          createdAt: (data[_createdAtFieldName] as Timestamp).toDate(),
        );
      }).toList();
      return cars;
    } catch (e) {
      rethrow;
    }
  }

  // create update car method
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
      final List<String> urls =
          carImagesPaths.where((path) => path.startsWith('http')).toList();
      final List<String> localFiles =
          carImagesPaths.where((path) => !path.startsWith('http')).toList();

      final List<String> uploadedUrls = await _uploadCarImages(
        referenceNumber,
        localFiles,
      );

      final List<String> combinedUrls = [...urls, ...uploadedUrls];

      await _carCollection.doc(carId).update({
        _manufacturerFieldName: manufacturer,
        _modelFieldName: model,
        _manufactureYearFieldName: manufactureYear,
        _colorFieldName: color,
        _engineTypeFieldName: engineType.name,
        _transmissionFieldName: transmissionType.name,
        _seatsFieldName: seats,
        _carTypeFieldName: carType.name,
        _hourPriceFieldName: hourPrice,
        _dayPriceFieldName: dayPrice,
        _imagesUrlFieldName: combinedUrls,
        _descriptionFieldName: description,
        _statusFieldName: CarStatus.updated.name,
      });

      // create status history record for the car
      await _statusHistoryController.createStatusHistory(
        StatusHistory(
          linkedObjectId: carId,
          linkedObjectType: 'Car',
          linkedObjectSubtype: '',
          previousStatus: previousStatus.getCarStatusString(),
          newStatus: CarStatus.updated.getCarStatusString(),
          statusDescription: '',
          modifiedById: modifiedById,
        ),
      );
    } on FirebaseException catch (_) {
      rethrow;
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
      final docRef = _carCollection.doc(carId);

      await docRef.update({
        _statusFieldName: newStatus.name,
      });

      // create status history record for the car
      await _statusHistoryController.createStatusHistory(
        StatusHistory(
          linkedObjectId: carId,
          linkedObjectType: 'Car',
          linkedObjectSubtype: '',
          previousStatus: previousStatus.getCarStatusString(),
          newStatus: newStatus.getCarStatusString(),
          statusDescription: statusDescription,
          modifiedById: modifiedById,
        ),
      );
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> setCarRegistrationDocument({
    required String carId,
    required String registrationDocumentId,
  }) async {
    try {
      await _carCollection.doc(carId).update({
        _registrationDocumentIdFieldName: registrationDocumentId,
      });
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteCarRegistrationDocument({required String carId}) async {
    try {
      await _carCollection.doc(carId).update({
        _registrationDocumentIdFieldName: '',
      });
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> setCarRoadTaxDocument({
    required String carId,
    required String roadTaxDocumentId,
  }) async {
    try {
      await _carCollection.doc(carId).update({
        _roadTaxDocumentIdFieldName: roadTaxDocumentId,
      });
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteCarRoadTaxDocument(String carId) async {
    try {
      await _carCollection.doc(carId).update({
        _roadTaxDocumentIdFieldName: '',
      });
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> setCarInsuranceDocument({
    required String carId,
    required String insuranceDocumentId,
  }) async {
    try {
      await _carCollection.doc(carId).update({
        _insuranceDocumentIdFieldName: insuranceDocumentId,
      });
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteCarInsuranceDocument(String carId) async {
    try {
      await _carCollection.doc(carId).update({
        _insuranceDocumentIdFieldName: '',
      });
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> hasCarsWithHostId(String hostId) async {
    try {
      if (hostId.isEmpty) {
        throw Exception('Host ID is required');
      }
      final querySnapshot = await _carCollection
          .where(_hostIdFieldName, isEqualTo: hostId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<List<Car>> getCarsByHostId(String hostId) async {
    try {
      if (hostId.isEmpty) {
        throw Exception('Host ID is required');
      }

      final querySnapshot =
          await _carCollection.where(_hostIdFieldName, isEqualTo: hostId).get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Car(
          id: doc.id,
          hostId: data[_hostIdFieldName],
          hostBankAccountId: data[_hostBankAccountIdFieldName],
          defaultAddressId: data[_defaultAddressIdFieldName],
          manufacturer: data[_manufacturerFieldName],
          model: data[_modelFieldName],
          manufactureYear: data[_manufactureYearFieldName],
          color: data[_colorFieldName],
          engineType: EngineType.values
              .firstWhere((e) => e.name == data[_engineTypeFieldName]),
          transmissionType: TransmissionType.values
              .firstWhere((e) => e.name == data[_transmissionFieldName]),
          seats: data[_seatsFieldName],
          carType: CarType.values
              .firstWhere((e) => e.name == data[_carTypeFieldName]),
          hourPrice: data[_hourPriceFieldName],
          dayPrice: data[_dayPriceFieldName],
          imagesUrl: List<String>.from(data[_imagesUrlFieldName]),
          description: data[_descriptionFieldName],
          status: CarStatus.values
              .firstWhere((e) => e.name == data[_statusFieldName]),
          registrationDocumentId: data[_registrationDocumentIdFieldName],
          roadTaxDocumentId: data[_roadTaxDocumentIdFieldName],
          insuranceDocumentId: data[_insuranceDocumentIdFieldName],
          referenceNumber: data[_referenceNumberFieldName],
          createdAt: (data[_createdAtFieldName] as Timestamp).toDate(),
        );
      }).toList();
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<List<String>> _uploadCarImages(
    String carReferenceNumber,
    List<String> carImagesPaths,
  ) async {
    // car-images/${referenceNumber}/somethingHere.jpg all images in the carId folder
    final storageService = FirebaseStorageService();
    final imagesUrls = <String>[];

    for (final imagePath in carImagesPaths) {
      final fileName = imagePath.split('/').last;
      final storagePath = 'car-images/$carReferenceNumber/$fileName';
      final imageUrl = await storageService.uploadFile(
        filePath: imagePath,
        storagePath: storagePath,
      );
      if (imageUrl != null) {
        imagesUrls.add(imageUrl);
      }
    }
    return imagesUrls;
  }

  Future<void> setCarDefaultAddress({
    required String carId,
    required String addressId,
  }) async {
    try {
      await _carCollection.doc(carId).update({
        _defaultAddressIdFieldName: addressId,
      });
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteCarDefaultAddress(String carId) async {
    try {
      await _carCollection.doc(carId).update({
        _defaultAddressIdFieldName: '',
      });
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  String _extractCarImageStoragePathFromUrl(String imageUrl) {
    final uri = Uri.parse(imageUrl);
    final pathSegments = uri.pathSegments;
    final index = pathSegments.indexWhere((segment) => segment == 'o');
    if (index != -1 && index + 1 < pathSegments.length) {
      final encodedPath = pathSegments.sublist(index + 1).join('/');
      return Uri.decodeFull(encodedPath);
    }
    throw Exception('Invalid image URL: $imageUrl');
  }

  // delete car
  Future<void> deleteCar({
    required String carId,
    required bool isAdmin,
    required String modifiedById,
    String? statusDescription = '',
  }) async {
    try {
      final car = await getCarById(carId);
      if (car == null) {
        throw Exception('Car not found');
      }

      if (isAdmin) {
        if (car.imagesUrl != null && car.imagesUrl!.isNotEmpty) {
          for (final imageUrl in car.imagesUrl!) {
            final storagePath = _extractCarImageStoragePathFromUrl(imageUrl);
            await FirebaseStorageService().deleteFile(storagePath);
          }
        }
        await _carCollection.doc(carId).delete();
        // delete all status history records for the car
        await _statusHistoryController.deleteStatusHistories(carId);
      } else {
        await _carCollection.doc(carId).update({
          _statusFieldName: CarStatus.deletedByHost.name,
        });

        await _statusHistoryController.createStatusHistory(
          StatusHistory(
            linkedObjectId: carId,
            linkedObjectType: 'Car',
            linkedObjectSubtype: '',
            previousStatus: car.status?.getCarStatusString() ?? '',
            newStatus: CarStatus.deletedByHost.getCarStatusString(),
            statusDescription: statusDescription,
            modifiedById: modifiedById,
          ),
        );
      }
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  // Future<String> _uploadCarDocument(String? carId, String folder, File document) async {
  //   final fileName = '${carId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  //   final documentRef = _storageRef.child('$folder/$fileName');
  //   final uploadTask = documentRef.putFile(document);
  //   final snapshot = await uploadTask.whenComplete(() => null);
  //   return await snapshot.ref.getDownloadURL();
  // }
}

// car-insurance/${referenceNumber}_${randomString}.jpg
// car-registration/${referenceNumber}_${randomString}.jpg
// car-road-tax/${referenceNumber}_${randomString}.jpg
