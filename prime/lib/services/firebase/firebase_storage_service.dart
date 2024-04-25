import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<String?> uploadFile({
    required String filePath,
    required String storagePath,
  }) async {
    try {
      final file = File(filePath);
      await _firebaseStorage.ref().child(storagePath).putFile(file);
      return getDownloadUrl(storagePath);
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<String?> getDownloadUrl(String storagePath) async {
    try {
      final downloadUrl =
          await _firebaseStorage.ref().child(storagePath).getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<String?> updateFile({
    required String storagePath,
    String? filePath,
  }) async {
    try {
      if (filePath != null) {
        final file = File(filePath);
        await _firebaseStorage.ref().child(storagePath).putFile(file);
      }
      return getDownloadUrl(storagePath);
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteFile(String storagePath) async {
    try {
      await _firebaseStorage.ref().child(storagePath).delete();
    } on FirebaseException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
