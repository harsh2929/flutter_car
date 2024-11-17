// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car.dart';
import '../models/user.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Generates a unique ID for a new car
  String generateCarId() {
    return _db.collection('cars').doc().id;
  }

  // Adds a new car to Firestore
  Future<void> addCar(Car car) async {
    try {
      await _db.collection('cars').doc(car.id).set(car.toMap());
    } catch (e) {
      print('Error adding car: $e');
      throw e;
    }
  }

  // Fetches user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  // Adds a new user to Firestore
  Future<void> addUser(UserModel user) async {
    try {
      await _db.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      print('Error adding user: $e');
      throw e;
    }
  }

  // Fetches all cars for a specific user (User's Own Cars)
  Stream<List<Car>> getUserCars(String userId) {
    return _db
        .collection('cars')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Car.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Fetches all cars globally (Global Cars)
  Stream<List<Car>> getAllCars() {
    return _db
        .collection('cars')
        .orderBy('title')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Car.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Searches cars globally based on a query (e.g., title, description, tags)
  Stream<List<Car>> searchGlobalCars(String query) {
    // Split the query into individual words
    List<String> keywords = query.toLowerCase().split(' ').where((word) => word.isNotEmpty).toList();

    if (keywords.isEmpty) {
      // If no valid keywords, return all cars
      return getAllCars();
    }

    // Firestore's array-contains-any allows up to 10 elements
    // So we limit the keywords to 10
    List<String> limitedKeywords = keywords.length > 10 ? keywords.sublist(0, 10) : keywords;

    return _db
        .collection('cars')
        .where('searchKeywords', arrayContainsAny: limitedKeywords)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Car.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Searches within a user's own cars based on a query
  Stream<List<Car>> searchUserCars(String userId, String query) {
    List<String> keywords = query.toLowerCase().split(' ').where((word) => word.isNotEmpty).toList();

    if (keywords.isEmpty) {
      return getUserCars(userId);
    }

    // Limit to 10 keywords as per Firestore's array-contains-any limitation
    List<String> limitedKeywords = keywords.length > 10 ? keywords.sublist(0, 10) : keywords;

    return _db
        .collection('cars')
        .where('ownerId', isEqualTo: userId)
        .where('searchKeywords', arrayContainsAny: limitedKeywords)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Car.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Updates an existing car in Firestore
  Future<void> updateCar(Car car) async {
    try {
      await _db.collection('cars').doc(car.id).update(car.toMap());
    } catch (e) {
      print('Error updating car: $e');
      throw e;
    }
  }

  // Deletes a car from Firestore
  Future<void> deleteCar(String carId) async {
    try {
      await _db.collection('cars').doc(carId).delete();
    } catch (e) {
      print('Error deleting car: $e');
      throw e;
    }
  }
}
