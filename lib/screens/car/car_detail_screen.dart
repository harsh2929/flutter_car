// lib/screens/car/car_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/car.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import 'car_edit_screen.dart';

class CarDetailScreen extends StatelessWidget {
  final Car car;

  CarDetailScreen({required this.car});

  void _deleteCar(BuildContext context) async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null || user.uid != car.ownerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You do not have permission to delete this car.')),
      );
      return;
    }

    try {
      await firestoreService.deleteCar(car.ownerId, car.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Car deleted successfully.')),
      );
      Navigator.pop(context); // Navigate back after deletion
    } catch (e) {
      print('Error deleting car: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete car. Please try again.')),
      );
    }
  }

  void _editCar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CarEditScreen(car: car)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    bool isOwner = user != null && user.uid == car.ownerId;

    return Scaffold(
      appBar: AppBar(
        title: Text(car.title),
        actions: isOwner
            ? [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editCar(context),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteCar(context),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Carousel
            SizedBox(
              height: 300,
              child: PageView(
                children: car.imageUrls.map((url) {
                  return Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(Icons.broken_image, size: 100, color: Colors.red),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    car.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  SizedBox(height: 16.0),
                  Wrap(
                    spacing: 8.0,
                    children: car.tags.map((tag) {
                      return Chip(label: Text(tag));
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
