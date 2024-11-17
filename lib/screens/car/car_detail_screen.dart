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
        Navigator.pop(context);
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
      body: Stack(
        children: [
          // Car Image Header
          car.imageUrls.isNotEmpty
              ? Hero(
                  tag: car.id,
                  child: Image.network(
                    car.imageUrls.first,
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.red,
                          size: 100,
                        ),
                      );
                    },
                  ),
                )
              : Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.car_repair,
                    size: 100,
                    color: Colors.grey[700],
                  ),
                ),

          // Content Section
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.6,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Title and Owner Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          car.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        if (isOwner)
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editCar(context),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCar(context),
                              ),
                            ],
                          ),
                      ],
                    ),
                    SizedBox(height: 8.0),

                    // Description
                    Text(
                      car.description,
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 16.0),

                    // Tags
                    Wrap(
                      spacing: 8.0,
                      children: car.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: Colors.blueAccent.withOpacity(0.2),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16.0),

                    // Additional Images Section
                    Text(
                      'More Images',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8.0),
                    car.imageUrls.length > 1
                        ? SizedBox(
                            height: 150,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: car.imageUrls.length - 1,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(
                                      car.imageUrls[index + 1],
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 150,
                                          height: 150,
                                          color: Colors.grey[300],
                                          child: Icon(Icons.broken_image,
                                              color: Colors.red),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Text(
                            'No additional images available.',
                            style: TextStyle(color: Colors.grey),
                          ),
                  ],
                ),
              );
            },
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
