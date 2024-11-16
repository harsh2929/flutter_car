import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../models/car.dart';
import '../../widgets/car_card.dart';
import 'car_create_screen.dart';

class CarListScreen extends StatefulWidget {
  @override
  _CarListScreenState createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = FirestoreService();
    final user = authService.currentUser;

    if (user == null) {
      return Center(
        child: Text('User not authenticated.'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Cars'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CarCreateScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search cars...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim();
                });
              },
            ),
          ),
          // Car List
          Expanded(
            child: StreamBuilder<List<Car>>(
              stream: searchQuery.isEmpty
                  ? firestoreService.getCars(user.uid)
                  : firestoreService.searchCars(user.uid, searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('No cars found.'),
                  );
                } else if (!snapshot.hasData) {
                  return Center(
                    child: Text('No cars available.'),
                  );
                } else {
                  final cars = snapshot.data!;
                  return ListView.builder(
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      return CarCard(car: cars[index]);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
