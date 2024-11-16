// lib/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/firestore_service.dart';

/// Provider that manages the current user's data.
class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  UserModel? _user;
  UserModel? get user => _user;

  UserProvider() {
    // Listen to authentication state changes.
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  /// Handler for authentication state changes.
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
    } else {
      // Fetch user data from Firestore.
      _user = await _firestoreService.getUserData(firebaseUser.uid);
    }
    notifyListeners();
  }

  /// Refreshes the user data manually.
  Future<void> refreshUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      _user = await _firestoreService.getUserData(firebaseUser.uid);
      notifyListeners();
    }
  }
}
