// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Getter for the current user
  User? get currentUser => _auth.currentUser;

  // Stream to monitor auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign Up method
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Sign Up Error: ${e.code} - ${e.message}');
      rethrow; // Allow the UI to handle the error
    } catch (e) {
      print('Sign Up Unknown Error: $e');
      rethrow;
    }
  }

  // Login method
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Login Error: ${e.code} - ${e.message}');
      rethrow; // Allow the UI to handle the error
    } catch (e) {
      print('Login Unknown Error: $e');
      rethrow;
    }
  }

  // Logout method
Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Logout Error: $e');
      throw e; // Propagate the error to the calling function
    }
  }
}
