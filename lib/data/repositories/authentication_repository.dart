import 'package:booking_app/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationRepository {
  static const String demoEmail = 'demo@travel365.com';
  static const String demoPassword = 'demo123';

  Future<UserModel> login(String email, String pass) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail == demoEmail && pass == demoPassword) {
      try {
        UserCredential credential;
        try {
          credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: demoEmail,
            password: demoPassword,
          );
        } on FirebaseAuthException catch (error) {
          if (error.code != 'invalid-credential' &&
              error.code != 'user-not-found') {
            rethrow;
          }
          credential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: demoEmail,
            password: demoPassword,
          );
          await credential.user!.updateDisplayName('Travel365 Demo');
          await FirebaseFirestore.instance
              .collection('users')
              .doc(credential.user!.uid)
              .set({
            'name': 'Travel365 Demo',
            'email': demoEmail,
            'photoUrl': null,
            'role': 'customer',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        return _firebaseUserToModel(
          FirebaseAuth.instance.currentUser ?? credential.user!,
          fallbackName: 'Travel365 Demo',
        );
      } on FirebaseAuthException catch (error) {
        if (error.code != 'operation-not-allowed' &&
            error.code != 'network-request-failed') {
          throw Exception(_authMessage(error.code));
        }
        await Future<void>.delayed(const Duration(milliseconds: 350));
        return UserModel(
          id: 1,
          name: 'Travel365 Demo',
          email: demoEmail,
          apiToken: 'demo-token',
          image: null,
        );
      }
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: pass,
      );
      return _firebaseUserToModel(credential.user!);
    } on FirebaseAuthException catch (error) {
      throw Exception(_authMessage(error.code));
    }
  }

  Future<UserModel> register(UserModel obj) async {
    final email = obj.email?.trim().toLowerCase() ?? '';
    final password = obj.password ?? '';

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      final name = obj.name?.trim() ?? '';

      if (name.isNotEmpty) {
        await user.updateDisplayName(name);
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'photoUrl': null,
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return _firebaseUserToModel(
        FirebaseAuth.instance.currentUser!,
        fallbackName: name,
      );
    } on FirebaseAuthException catch (error) {
      throw Exception(_authMessage(error.code));
    }
  }

  Future<void> logout() => FirebaseAuth.instance.signOut();

  Future<UserModel> _firebaseUserToModel(
    User user, {
    String? fallbackName,
  }) async {
    final token = await user.getIdToken();
    return UserModel(
      id: user.uid.hashCode & 0x7fffffff,
      name: user.displayName ?? fallbackName ?? 'Travel365 Traveller',
      email: user.email,
      apiToken: token,
      image: user.photoURL,
    );
  }

  String _authMessage(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Use a password with at least 6 characters.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      case 'operation-not-allowed':
        return 'Email/password login is not enabled in Firebase yet.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
