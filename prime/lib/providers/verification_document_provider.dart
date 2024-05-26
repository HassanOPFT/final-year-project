import 'package:flutter/material.dart';
import '../controllers/verification_document_controller.dart';
import '../models/user.dart';
import '../models/verification_document.dart';

class VerificationDocumentProvider extends ChangeNotifier {
  final VerificationDocumentController _verificationDocumentController =
      VerificationDocumentController();

  Future<String> createVerificationDocument(
    String? linkedObjectId,
    VerificationDocumentLinkedObjectType? linkedObjectType,
    VerificationDocumentType? documentType,
    DateTime? expiryDate,
    String? filePath,
    String modifiedById,
  ) async {
    try {
      final documentId =
          await _verificationDocumentController.createVerificationDocument(
        linkedObjectId,
        linkedObjectType,
        documentType,
        expiryDate,
        filePath,
        modifiedById,
      );
      notifyListeners();
      return documentId;
    } catch (_) {
      rethrow;
    }
  }

  Future<VerificationDocument?> getVerificationDocumentById(
    String documentId,
  ) async {
    try {
      return await _verificationDocumentController.getVerificationDocumentById(
        documentId,
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<VerificationDocument?> getVerificationDocumentByDocumentType(
    String linkedObjectId,
    VerificationDocumentType documentType,
  ) async {
    try {
      return await _verificationDocumentController
          .getVerificationDocumentByDocumentType(
        linkedObjectId,
        documentType,
      );
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
      await _verificationDocumentController.updateVerificationDocument(
        verificationDocumentId: verificationDocumentId,
        changeDocument: changeDocument,
        expiryDate: expiryDate,
        previousStatus: previousStatus,
        newStatus: newStatus,
        verificationDocumentReferenceNumber:
            verificationDocumentReferenceNumber,
        documentType: documentType,
        modifiedById: modifiedById,
        filePath: filePath,
        verificationDocumentUrl: verificationDocumentUrl,
      );
      notifyListeners();
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
      await _verificationDocumentController.updateVerificationDocumentStatus(
        verificationDocumentId: verificationDocumentId,
        newStatus: newStatus,
        previousStatus: previousStatus,
        statusDescription: statusDescription,
        documentType: documentType,
        modifiedById: modifiedById,
      );
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }


  Future<List<VerificationDocument>> getVerificationDocumentsByLinkedObjectId(
    String linkedObjectId,
  ) async {
    try {
      return await _verificationDocumentController
          .getVerificationDocumentsByLinkedObjectId(
        linkedObjectId,
      );
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
      await _verificationDocumentController.deleteVerificationDocument(
        documentId: documentId,
        referenceNumber: referenceNumber,
        documentType: documentType,
        userRole: userRole,
        previousStatus: previousStatus,
        modifiedById: modifiedById,
      );
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }
}
