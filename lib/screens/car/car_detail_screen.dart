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

  /// Deletes the car listing if the user is the owner.
  void _deleteCar(BuildContext context) async {
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    if (user == null || user.uid != car.ownerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You do not have permission to delete this car.')),
      );
      return;
    }

    bool confirm = await _showConfirmationDialog(context, 'Delete Car',
        'Are you sure you want to delete this car? This action cannot be undone.');

    if (confirm) {
      try {
        await firestoreService.deleteCar(car.id);
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
  }

  void _editCar(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CarEditScreen(car: car)),
    );
  }

  /// Displays a confirmation dialog for critical actions.
  Future<bool> _showConfirmationDialog(
      BuildContext context, String title, String content) async {
    bool confirmed = false;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              confirmed = false;
              Navigator.of(ctx).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              confirmed = true;
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    return confirmed;
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
                  tooltip: 'Edit Car',
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteCar(context),
                  tooltip: 'Delete Car',
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                car.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8.0),
              // Description
              Text(
                car.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 16.0),
              // Tags
              Wrap(
                spacing: 8.0,
                children: car.tags.map((tag) {
                  return Chip(label: Text(tag));
                }).toList(),
              ),
              SizedBox(height: 16.0),
              // Images Grid
              Text(
                'Images',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 8.0),
              car.imageUrls.isNotEmpty
                  ? GridView.builder(
                      shrinkWrap: true, // Ensures grid doesn't take infinite space
                      physics: NeverScrollableScrollPhysics(), // Prevents grid from scrolling independently
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Two columns in the grid
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 1.0, // Square images
                      ),
                      itemCount: car.imageUrls.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            car.imageUrls[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.broken_image,
                                    color: Colors.red),
                              );
                            },
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.car_repair,
                        size: 100,
                        color: Colors.grey[700],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
