import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final _firebaseAuth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  bool get isUserLoggedIn => _firebaseAuth.currentUser != null;
  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<String> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        if (userCredential.user!.uid.isNotEmpty) {
          return userCredential.user!.uid;
        }
      }
      throw Exception('Sign up failed. Please try again.');
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign up failed. Please try again.');
    } catch (e) {
      throw Exception('Sign up failed. Please try again.');
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign in failed. Please try again.');
    } catch (e) {
      throw Exception('Sign in failed. Please try again.');
    }
  }

  Future<UserCredential> continueWithGoogle() async {
    final googleSignInAccount = await _googleSignIn.signIn();

    if (googleSignInAccount == null) {
      throw Exception('Google Sign-In canceled');
    }

    final googleAuth = await googleSignInAccount.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);

    if (userCredential.user == null) {
      throw Exception('Google Sign-In failed. Please try again.');
    }

    return userCredential;
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      if (currentUser != null) {
        await currentUser!.updatePassword(newPassword);
      } else {
        throw Exception('User not authenticated.');
      }
    } on FirebaseAuthException catch (_) {
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(
        e.message ?? 'Failed to send password reset email. Please try again.',
      );
    } catch (e) {
      throw Exception('Failed to send password reset email. Please try again.');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign out failed. Please try again.');
    } catch (e) {
      throw Exception('Sign out failed. Please try again.');
    }
  }
}
