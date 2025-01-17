import '../models/admin.dart';
import 'user_controller.dart';

class AdminController {
  // static const String _adminCollectionName = 'Admin';

  // final _adminCollection =
  //     FirebaseFirestore.instance.collection(_adminCollectionName);
  final _userController = UserController();

  // TODO: move the admin creation lgoic from the view to the controller
  Future<void> createAdmin({required Admin admin}) async {
    try {
      if (admin.userId == null || admin.userId!.isEmpty) {
        throw Exception('Admin creation failed. Please try again.');
      }

      // Create a user in the User collection
      await _userController.createUser(user: admin);

      // Create an admin in the Admin collection
      // await _adminCollection.doc(admin.userId).set({});
    } catch (_) {
      rethrow;
    }
  }
}
