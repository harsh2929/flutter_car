// lib/screens/profile_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../models/user.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  String? displayName;
  File? _imageFile;
  bool isLoading = false;

  void _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _saveProfile(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      final authService = Provider.of<AuthService>(context, listen: false);
      final storageService = StorageService();
      final firestore = FirebaseFirestore.instance;

      UserModel? user = context.read<UserModel?>();
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      String? photoUrl = user.photoUrl;

      if (_imageFile != null) {
        photoUrl = await storageService.uploadImage(
            _imageFile! as XFile, user.id, 'profile_photo', 0);
      }

      // Update Firestore user document
      await firestore.collection('users').doc(user.id).update({
        'displayName': displayName,
        'photoUrl': photoUrl,
      });

      setState(() => isLoading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserModel?>();
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Edit Profile')),
        body: Center(child: Text('No user information available.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: _imageFile != null
                            ? CircleAvatar(
                                radius: 50,
                                backgroundImage: FileImage(_imageFile!),
                              )
                            : user.photoUrl != null
                                ? CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(user.photoUrl!),
                                  )
                                : CircleAvatar(
                                    radius: 50,
                                    child: Icon(Icons.person, size: 50),
                                  ),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        initialValue: user.displayName,
                        decoration: InputDecoration(labelText: 'Display Name'),
                        onChanged: (value) => displayName = value.trim(),
                      ),
                      SizedBox(height: 32.0),
                      ElevatedButton(
                        onPressed: () => _saveProfile(context),
                        child: Text('Save'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
