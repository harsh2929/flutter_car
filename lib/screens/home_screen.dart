// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/car/car_list_screen.dart';
import '../utils/constants.dart'; // Ensure this exists

class HomeScreen extends StatelessWidget {
  void _logout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.logout();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to logout. Please try again.')),
      );
    }
  }

  void _navigateToAddCar(BuildContext context) {
    Navigator.pushNamed(context, '/addCar'); // Use the named route
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(AppStrings.home), // Define AppStrings.home
      //   actions: [
          // IconButton(
          //   icon: Icon(Icons.logout),
          //   onPressed: () => _logout(context),
          //   tooltip: 'Logout',
          // ),
      //   ],
      // ),
      body: CarListScreen(), // Ensure CarListScreen is correctly implemented
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddCar(context), // Navigate using the named route
        child: Icon(Icons.add),
        tooltip: 'Add Car',
      ),
    );
  }
}
