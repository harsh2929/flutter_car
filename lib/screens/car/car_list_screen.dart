// lib/screens/car/car_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../models/car.dart';
import '../../widgets/car_card.dart';
import '../car/car_create_screen.dart';
import '../../utils/constants.dart';
import 'dart:async'; // Import for Timer

class CarListScreen extends StatefulWidget {
  @override
  _CarListScreenState createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String globalSearchQuery = ''; // Search query for All Cars
  String myCarsSearchQuery = ''; // Search query for My Cars
  Timer? _debounce; // Timer for debouncing

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _debounce?.cancel(); // Cancel the timer if active
    super.dispose();
  }

  // Logout method
  void _logout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.logout(); // Sign out the user
      Navigator.pushReplacementNamed(context, '/login'); // Navigate to the login page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout. Please try again.')),
      );
    }
  }

  Widget _buildMyCarsTab(FirestoreService firestoreService, String userId) {
    return Column(
      children: [
        // Search Bar for My Cars with Debouncing
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search my cars...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                setState(() {
                  myCarsSearchQuery = value.trim().toLowerCase();
                });
              });
            },
          ),
        ),
        // My Cars List
        Expanded(
          child: StreamBuilder<List<Car>>(
            stream: myCarsSearchQuery.isEmpty
                ? firestoreService.getUserCars(userId)
                : firestoreService.searchUserCars(userId, myCarsSearchQuery),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Center(child: Text('You have not added any cars.'));
              } else if (!snapshot.hasData) {
                return Center(child: Text('No cars available.'));
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
    );
  }

  Widget _buildAllCarsTab(FirestoreService firestoreService, String currentUserId) {
    return Column(
      children: [
        // Global Search Bar with Debouncing
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Search all cars...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                setState(() {
                  globalSearchQuery = value.trim().toLowerCase();
                });
              });
            },
          ),
        ),
        // Global Car List
        Expanded(
          child: StreamBuilder<List<Car>>(
            stream: globalSearchQuery.isEmpty
                ? firestoreService.getAllCars()
                : firestoreService.searchGlobalCars(globalSearchQuery),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Center(child: Text('No cars found.'));
              } else if (!snapshot.hasData) {
                return Center(child: Text('No cars available.'));
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService = FirestoreService();
    final user = authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.home),
        ),
        body: Center(
          child: Text('User not authenticated.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.home),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'My Cars'),
            Tab(text: 'All Cars'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add Car',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CarCreateScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyCarsTab(firestoreService, user.uid),
          _buildAllCarsTab(firestoreService, user.uid),
        ],
      ),
    );
  }
}
