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
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        leading: car.imageUrls.isNotEmpty
            ? Image.network(car.imageUrls.first,
                width: 50, height: 50, fit: BoxFit.cover)
            : Image.asset('assets/images/placeholder.png',
                width: 50, height: 50),
        title: Text(car.title),
        subtitle: Text(car.description),
        onTap: () => _navigateToDetail(context),
      ),
    );
  }
}
