// lib/widgets/car_card.dart

import 'package:flutter/material.dart';
import '../models/car.dart';
import '../screens/car/car_detail_screen.dart';

class CarCard extends StatelessWidget {
  final Car car;

  CarCard({required this.car});

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CarDetailScreen(car: car)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Generate a snippet from the description
    String descriptionSnippet = car.description.length > 50
        ? '${car.description.substring(0, 50)}...'
        : car.description;

    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: car.imageUrls.isNotEmpty
            ? Image.network(
                car.imageUrls.first,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/placeholder.png',
                    width: 50,
                    height: 50,
                  );
                },
              )
            : Image.asset(
                'assets/images/placeholder.png',
                width: 50,
                height: 50,
              ),
        title: Text(car.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(descriptionSnippet),
            SizedBox(height: 4.0),
            Wrap(
              spacing: 4.0,
              children: car.tags.map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.blueAccent.withOpacity(0.2),
                  )).toList(),
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () => _navigateToDetail(context),
      ),
    );
  }
}
