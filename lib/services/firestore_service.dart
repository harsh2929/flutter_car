// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Generates a unique ID for a new car
  String generateCarId() {
    return _db.collection('users').doc().id;
  }

  // Adds a new car to Firestore
  Future<void> addCar(Car car) async {
    try {
      await _db
          .collection('users')
          .doc(car.ownerId)
          .collection('cars')
          .doc(car.id)
          .set(car.toMap());
    } catch (e) {
      print('Error adding car: $e');
      throw e; // Rethrow the error to handle it in the calling function
    }
  }

  // Fetches all cars for a specific user
  Stream<List<Car>> getCars(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('cars')
        .orderBy('title') // Optional: Order cars by title
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Car.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Searches cars by a keyword in tags
  Stream<List<Car>> searchCars(String userId, String keyword) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('cars')
        .where('tags', arrayContains: keyword.toLowerCase())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Car.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Updates an existing car in Firestore
  Future<void> updateCar(Car car) async {
    try {
      await _db
          .collection('users')
          .doc(car.ownerId)
          .collection('cars')
          .doc(car.id)
          .update(car.toMap());
    } catch (e) {
      print('Error updating car: $e');
      throw e; // Rethrow the error to handle it in the calling function
    }
  }

  // Deletes a car from Firestore
  Future<void> deleteCar(String ownerId, String carId) async {
    try {
      await _db
          .collection('users')
          .doc(ownerId)
          .collection('cars')
          .doc(carId)
          .delete();
    } catch (e) {
      print('Error deleting car: $e');
      throw e; // Rethrow the error to handle it in the calling function
    }
  }
}
