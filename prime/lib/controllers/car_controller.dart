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
          previousStatus: CarStatus.uploaded.name,
          newStatus: newCarStatus.name,
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
          previousStatus: newCarStatus.name,
          newStatus: CarStatus.pendingApproval.name,
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
