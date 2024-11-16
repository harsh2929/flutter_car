// lib/screens/auth/signup_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';
import '../../utils/constants.dart'; // Ensure this exists
import '../../utils/theme.dart'; // Ensure this exists

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = false;
  String errorMessage = '';

  void _signUp(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        User? user = await authService.signUp(email, password);

        if (user != null) {
          // Navigate to HomeScreen upon successful sign up
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Handle Firebase-specific errors
        String message = '';
        switch (e.code) {
          case 'email-already-in-use':
            message = 'The account already exists for that email.';
            break;
          case 'invalid-email':
            message = 'The email address is badly formatted.';
            break;
          case 'weak-password':
            message = 'The password provided is too weak.';
            break;
          default:
            message = 'An undefined Error happened.';
        }
        setState(() {
          errorMessage = message;
        });
      } catch (e) {
        // Handle other errors
        setState(() {
          errorMessage = 'An error occurred. Please try again.';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.pop(context); // Assuming LoginScreen is the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.signup), // Define AppStrings.signup
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            !value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                    ),
                    SizedBox(height: 16.0),

                    // Password Field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.trim().length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          password = value;
                        });
                      },
                    ),
                    SizedBox(height: 16.0),

                    // Error Message
                    if (errorMessage.isNotEmpty)
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ),
                    SizedBox(height: 16.0),

                    // Sign Up Button
                    ElevatedButton(
                      onPressed: () => _signUp(context),
                      child: Text('Sign Up'),
                    ),

                    // Navigate to Login
                    TextButton(
                      onPressed: () => _navigateToLogin(context),
                      child: Text('Already have an account? Login'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
