import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';
import '../models/status_history.dart';
import '../models/verification_document.dart';
import '../services/firebase/firebase_storage_service.dart';
import '../utils/generate_reference_number.dart';
import 'status_history_controller.dart';

class VerificationDocumentController {
  static const String _verificationDocumentCollectionName =
      'VerificationDocument';
  static const String _linkedObjectIdFieldName = 'linkedObjectId';
  static const String _linkedObjectTypeFieldName = 'linkedObjectType';
  static const String _documentUrlFieldName = 'documentUrl';
  static const String _documentTypeFieldName = 'documentType';
  static const String _statusFieldName = 'status';
  static const String _expiryDateFieldName = 'expiryDate';
  static const String _referenceNumberFieldName = 'referenceNumber';
  static const String _createdAtFieldName = 'createdAt';

  final _verificationDocumentCollection = FirebaseFirestore.instance
      .collection(_verificationDocumentCollectionName);
  final _statusHistoryController = StatusHistoryController();

  Future<String> createVerificationDocument(
    String? linkedObjectId,
    VerificationDocumentLinkedObjectType? linkedObjectType,
    VerificationDocumentType? documentType,
    DateTime? expiryDate,
    String? filePath,
    String modifiedById,
  ) async {
    try {
      if (filePath == null || filePath.isEmpty) {
        throw Exception(
          'File path is required for creating a verification document.',
        );
      }
      if (linkedObjectId == null ||
          linkedObjectId.isEmpty ||
          linkedObjectType == null ||
          documentType == null ||
          expiryDate == null) {
        throw Exception(
          'Linked object ID, linked object type, document type and expiry date are required for creating a verification document.',
        );
      }

      final objectType = getObjectType(documentType);
      final documentReferenceNumber = generateReferenceNumber(objectType);

      // upload file to storage
      final firebaseStorageService = FirebaseStorageService();
      final documentStoragePath = _generateVerificationDocumentStoragePath(
        documentReferenceNumber,
        documentType,
      );

      final documentUrl = await firebaseStorageService.uploadFile(
        filePath: filePath,
        storagePath: documentStoragePath,
      );

      if (documentUrl == null || documentUrl.isEmpty) {
        throw Exception('Document URL is empty after uploading the file.');
      }
      final status = VerificationDocumentStatus.uploaded.name;

      final newDocument = await _verificationDocumentCollection.add({
        _linkedObjectIdFieldName: linkedObjectId,
        _linkedObjectTypeFieldName: linkedObjectType.name,
        _documentUrlFieldName: documentUrl,
        _documentTypeFieldName: documentType.name,
        _statusFieldName: status,
        _expiryDateFieldName: expiryDate,
        _referenceNumberFieldName: documentReferenceNumber,
        _createdAtFieldName: DateTime.now(),
      });

      // Create StatusHistory record
      await _createStatusHistory(
        linkedObjectId: newDocument.id,
        linkedObjectType: documentType.name,
        previousStatus: VerificationDocumentStatus.uploaded.getStatusString(),
        newStatus: VerificationDocumentStatus.uploaded.getStatusString(),
        modifiedById: modifiedById,
      );

      // Update document status to pendingApproval
      await newDocument.update({
        _statusFieldName: VerificationDocumentStatus.pendingApproval.name,
      });

      // Create StatusHistory record for pendingApproval status
      await _createStatusHistory(
        linkedObjectId: newDocument.id,
        linkedObjectType: documentType.name,
        previousStatus: VerificationDocumentStatus.uploaded.getStatusString(),
        newStatus: VerificationDocumentStatus.pendingApproval.getStatusString(),
        modifiedById: modifiedById,
      );

      return newDocument.id;
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  // Storage path format:
  // car-road-tax/$referenceNumber.jpg
  // driving-license/$referenceNumber.jpg
  // user-identity-document/$referenceNumber.jpg
  // car-insurance/$referenceNumber.jpg
  // car-registration/$referenceNumber.jpg

  String _generateVerificationDocumentStoragePath(
    String referenceNumber,
    VerificationDocumentType documentType,
  ) {
    switch (documentType) {
      case VerificationDocumentType.identity:
        return 'user-identity-document/$referenceNumber.jpg';
      case VerificationDocumentType.drivingLicense:
        return 'driving-license/$referenceNumber.jpg';
      case VerificationDocumentType.carRegistration:
        return 'car-registration/$referenceNumber.jpg';
      case VerificationDocumentType.carInsurance:
        return 'car-insurance/$referenceNumber.jpg';
      case VerificationDocumentType.carRoadTax:
        return 'car-road-tax/$referenceNumber.jpg';
      default:
        throw Exception('Invalid document type');
    }
  }

  Future<VerificationDocument?> getVerificationDocumentById(
    String documentId,
  ) async {
    try {
      if (documentId.isEmpty) {
        throw Exception('Document ID is required for fetching.');
      }

      final documentSnapshot =
          await _verificationDocumentCollection.doc(documentId).get();

      if (documentSnapshot.exists) {
        final data = documentSnapshot.data();

        final linkedObjectType = _getLinkedObjectType(
          data?[_linkedObjectTypeFieldName],
        );
        final documentType = _getDocumentType(data?[_documentTypeFieldName]);
        final status = _getStatus(data?[_statusFieldName]);

        return VerificationDocument(
          id: documentId,
          linkedObjectId: data?[_linkedObjectIdFieldName],
          linkedObjectType: linkedObjectType,
          documentUrl: data?[_documentUrlFieldName],
          documentType: documentType,
          status: status,
          expiryDate: data?[_expiryDateFieldName]?.toDate(),
          referenceNumber: data?[_referenceNumberFieldName],
          createdAt: data?[_createdAtFieldName]?.toDate(),
        );
      } else {
        return null;
      }
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<VerificationDocument?> getVerificationDocumentByDocumentType(
    String linkedObjectId,
    VerificationDocumentType documentType,
  ) async {
    try {
      if (linkedObjectId.isEmpty) {
        throw Exception('Linked object ID is required for fetching.');
      }

      final querySnapshot = await _verificationDocumentCollection
          .where(_linkedObjectIdFieldName, isEqualTo: linkedObjectId)
          .where(_documentTypeFieldName, isEqualTo: documentType.name)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();

        final documentId = querySnapshot.docs.first.id;

        final linkedObjectType =
            _getLinkedObjectType(data[_linkedObjectTypeFieldName]);
        final retrievedDocumentType =
            _getDocumentType(data[_documentTypeFieldName]);
        final status = _getStatus(data[_statusFieldName]);

        return VerificationDocument(
          id: documentId,
          linkedObjectId: data[_linkedObjectIdFieldName],
          linkedObjectType: linkedObjectType,
          documentUrl: data[_documentUrlFieldName],
          documentType: retrievedDocumentType,
          status: status,
          expiryDate: data[_expiryDateFieldName]?.toDate(),
          referenceNumber: data[_referenceNumberFieldName],
          createdAt: data[_createdAtFieldName]?.toDate(),
        );
      } else {
        return null;
      }
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateVerificationDocument({
    required String verificationDocumentId,
    required bool changeDocument,
    required DateTime expiryDate,
    required VerificationDocumentStatus previousStatus,
    required VerificationDocumentStatus newStatus,
    required String verificationDocumentReferenceNumber,
    required VerificationDocumentType documentType,
    required String modifiedById,
    String? filePath,
    String? verificationDocumentUrl,
  }) async {
    try {
      String? newDocumentUrl;
      if (verificationDocumentId.isEmpty) {
        throw Exception(
          'Verification document ID is required for updating.',
        );
      }
      if (changeDocument && (filePath == null || filePath.isEmpty)) {
        throw Exception(
          'File path is required for updating the document.',
        );
      }
      if (changeDocument) {
        final newDocumentStoragePath = _generateVerificationDocumentStoragePath(
          verificationDocumentReferenceNumber,
          documentType,
        );
        await FirebaseStorageService().deleteFile(newDocumentStoragePath);
        newDocumentUrl = await FirebaseStorageService().uploadFile(
          filePath: filePath!,
          storagePath: newDocumentStoragePath,
        );
        if (newDocumentUrl == null || newDocumentUrl.isEmpty) {
          throw Exception('Document URL is empty after uploading the file.');
        }
      }

      final newData = {
        if (changeDocument) _documentUrlFieldName: newDocumentUrl,
        _statusFieldName: newStatus.name,
        _expiryDateFieldName: expiryDate,
      };

      await _verificationDocumentCollection
          .doc(verificationDocumentId)
          .update(newData);

      // Create StatusHistory record
      await _createStatusHistory(
        linkedObjectId: verificationDocumentId,
        linkedObjectType: documentType.name,
        previousStatus: previousStatus.getStatusString(),
        newStatus: newStatus.getStatusString(),
        modifiedById: modifiedById,
      );
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateVerificationDocumentStatus({
    required String verificationDocumentId,
    required VerificationDocumentStatus newStatus,
    required VerificationDocumentStatus previousStatus,
    String? statusDescription,
    required VerificationDocumentType documentType,
    required String modifiedById,
  }) async {
    try {
      DocumentReference documentRef =
          _verificationDocumentCollection.doc(verificationDocumentId);

      await documentRef.update({
        _statusFieldName: newStatus.name,
      });

      // Create StatusHistory record
      await _createStatusHistory(
        linkedObjectId: verificationDocumentId,
        linkedObjectType: documentType.name,
        previousStatus: previousStatus.getStatusString(),
        newStatus: newStatus.getStatusString(),
        statusDescription: statusDescription ?? '',
        modifiedById: modifiedById,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<VerificationDocument>> getVerificationDocumentsByLinkedObjectId(
      String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception(
            'User ID is required for fetching verification documents.');
      }

      final querySnapshot = await _verificationDocumentCollection
          .where(_linkedObjectIdFieldName, isEqualTo: userId)
          .where(_linkedObjectTypeFieldName,
              isEqualTo: VerificationDocumentLinkedObjectType.user.name)
          .get();

      final documents = <VerificationDocument>[];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();

        final documentId = doc.id;

        final linkedObjectType =
            _getLinkedObjectType(data[_linkedObjectTypeFieldName]);
        final documentType = _getDocumentType(data[_documentTypeFieldName]);
        final status = _getStatus(data[_statusFieldName]);

        final document = VerificationDocument(
          id: documentId,
          linkedObjectId: data[_linkedObjectIdFieldName],
          linkedObjectType: linkedObjectType,
          documentUrl: data[_documentUrlFieldName],
          documentType: documentType,
          status: status,
          expiryDate: data[_expiryDateFieldName]?.toDate(),
          referenceNumber: data[_referenceNumberFieldName],
          createdAt: data[_createdAtFieldName]?.toDate(),
        );

        documents.add(document);
      }

      return documents;
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteVerificationDocument({
    required String documentId,
    required String referenceNumber,
    required VerificationDocumentType documentType,
    required UserRole userRole,
    required VerificationDocumentStatus previousStatus,
    required String modifiedById,
  }) async {
    try {
      VerificationDocumentStatus newStatus;

      if (userRole == UserRole.primaryAdmin ||
          userRole == UserRole.secondaryAdmin) {
        final newDocumentStoragePath = _generateVerificationDocumentStoragePath(
          referenceNumber,
          documentType,
        );
        await FirebaseStorageService().deleteFile(newDocumentStoragePath);
        await _verificationDocumentCollection.doc(documentId).delete();
        newStatus = VerificationDocumentStatus.deletedByAdmin;
        // delete all status history records for the car
        await _statusHistoryController.deleteStatusHistories(documentId);
      } else {
        await _verificationDocumentCollection.doc(documentId).update({
          _statusFieldName: VerificationDocumentStatus.deletedByCustomer.name,
        });
        newStatus = VerificationDocumentStatus.deletedByCustomer;
      }

      // Create StatusHistory record
      await _createStatusHistory(
        linkedObjectId: documentId,
        linkedObjectType: documentType.name,
        previousStatus: previousStatus.getStatusString(),
        newStatus: newStatus.getStatusString(),
        modifiedById: modifiedById,
      );
      // delete all StatusHistory records for the document
      await _statusHistoryController.deleteStatusHistories(
        documentId,
      );
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> _createStatusHistory({
    required String linkedObjectId,
    required String linkedObjectType,
    String linkedObjectSubtype = '',
    required String previousStatus,
    required String newStatus,
    String statusDescription = '',
    required String modifiedById,
  }) async {
    try {
      await _statusHistoryController.createStatusHistory(
        StatusHistory(
          linkedObjectId: linkedObjectId,
          linkedObjectType: linkedObjectType,
          linkedObjectSubtype: linkedObjectSubtype,
          previousStatus: previousStatus,
          newStatus: newStatus,
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

  String getObjectType(VerificationDocumentType documentType) {
    switch (documentType) {
      case VerificationDocumentType.identity:
        return 'VRF_IDT';
      case VerificationDocumentType.drivingLicense:
        return 'VRF_DL';
      case VerificationDocumentType.carRegistration:
        return 'VRF_CR';
      case VerificationDocumentType.carInsurance:
        return 'VRF_INS';
      case VerificationDocumentType.carRoadTax:
        return 'VRF_RT';
      default:
        throw Exception('Invalid document type');
    }
  }

  VerificationDocumentLinkedObjectType _getLinkedObjectType(
      String? linkedObjectType) {
    if (linkedObjectType != null) {
      for (var type in VerificationDocumentLinkedObjectType.values) {
        if (type.name == linkedObjectType) {
          return type;
        }
      }
    }
    return VerificationDocumentLinkedObjectType.user;
  }

  VerificationDocumentType _getDocumentType(String? documentType) {
    if (documentType != null) {
      for (var type in VerificationDocumentType.values) {
        if (type.name == documentType) {
          return type;
        }
      }
    }
    return VerificationDocumentType.identity;
  }

  VerificationDocumentStatus _getStatus(String? status) {
    if (status != null) {
      for (var statusEnum in VerificationDocumentStatus.values) {
        if (statusEnum.name == status) {
          return statusEnum;
        }
      }
    }
    return VerificationDocumentStatus.uploaded;
  }
}
