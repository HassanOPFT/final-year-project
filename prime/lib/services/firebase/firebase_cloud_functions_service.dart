import 'package:cloud_functions/cloud_functions.dart';

class FirebaseCloudFunctionsService {
  final FirebaseFunctions _firebaseCloudFunctions = FirebaseFunctions.instance;

  Future<String?> createUser({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final HttpsCallable callable = _firebaseCloudFunctions.httpsCallable(
        'createUser',
      );
      final result = await callable.call(
        <String, dynamic>{
          'email': email,
          'password': password,
          'displayName': displayName,
        },
      );

      return result.data['uid'];
    } catch (_) {
      rethrow;
    }
  }
}
