// lib/screens/car/car_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../models/car.dart';
import '../../widgets/tag_input_field.dart';
import 'package:image_picker/image_picker.dart';

class CarEditScreen extends StatefulWidget {
  final Car car;

  CarEditScreen({required this.car});

  @override
  _CarEditScreenState createState() => _CarEditScreenState();
}

class _CarEditScreenState extends State<CarEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String description;
  late List<String> tags;
  List<XFile> newImages = [];
  List<String> existingImageUrls = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    title = widget.car.title;
    description = widget.car.description;
    tags = List<String>.from(widget.car.tags);
    existingImageUrls = List<String>.from(widget.car.imageUrls);
  }

  // Handles form submission
  void _updateCar(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final firestoreService = Provider.of<FirestoreService>(context, listen: false);
        final storageService = StorageService();
        final user = authService.currentUser;

        if (user == null || user.uid != widget.car.ownerId) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not authenticated or unauthorized.')),
          );
          setState(() {
            isLoading = false;
          });
          return;
        }

        String userId = user.uid;
        String carId = widget.car.id;

        // Upload new images and get URLs
        List<String> updatedImageUrls = List<String>.from(existingImageUrls);
        for (int i = 0; i < newImages.length; i++) {
          String imageUrl = await storageService.uploadImage(
            newImages[i],
            userId,
            carId,
            updatedImageUrls.length + i,
          );
          updatedImageUrls.add(imageUrl);
        }

        // Create updated Car object
        Car updatedCar = Car(
          id: carId,
          title: title,
          description: description,
          tags: tags,
          imageUrls: updatedImageUrls,
          ownerId: userId,
        );

        // Update the car in Firestore
        await firestoreService.updateCar(updatedCar);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Car updated successfully!')),
        );

        Navigator.pop(context);
      } catch (e) {
        print('Error updating car: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update car. Please try again.')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Handles image picking
  void _pickNewImages() async {
    final ImagePicker _picker = ImagePicker();
    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null) {
        if (pickedFiles.length + newImages.length > 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You can upload up to 10 images.')),
          );
          return;
        }
        setState(() {
          newImages.addAll(pickedFiles);
        });
      }
    } catch (e) {
      print('Error picking images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick images.')),
      );
    }
  }

  // Removes selected new image
  void _removeNewImage(int index) {
    setState(() {
      newImages.removeAt(index);
    });
  }

  // Removes existing image
  void _removeExistingImage(int index) {
    setState(() {
      existingImageUrls.removeAt(index);
    });
  }

  // Converts XFile to Uint8List for image preview on Web
  Future<Uint8List?> _getImageBytes(XFile image) async {
    try {
      return await image.readAsBytes();
    } catch (e) {
      print('Error reading image bytes: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Car'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Field
                      TextFormField(
                        initialValue: title,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            title = value;
                          });
                        },
                      ),
                      SizedBox(height: 16.0),

                      // Description Field
                      TextFormField(
                        initialValue: description,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            description = value;
                          });
                        },
                      ),
                      SizedBox(height: 16.0),

                      // Tags Input Field
                      TagInputField(
                        initialTags: tags,
                        onTagsChanged: (newTags) {
                          setState(() {
                            tags = newTags;
                          });
                        },
                      ),
                      SizedBox(height: 16.0),

                      // Existing Images
                      Text(
                        'Existing Images',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      existingImageUrls.isNotEmpty
                          ? Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: List.generate(existingImageUrls.length, (index) {
                                return Stack(
                                  children: [
                                    Image.network(
                                      existingImageUrls[index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey[300],
                                          child: Icon(Icons.broken_image, color: Colors.red),
                                        );
                                      },
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: GestureDetector(
                                        onTap: () => _removeExistingImage(index),
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.black54,
                                          child: Icon(
                                            Icons.close,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            )
                          : Text('No existing images.'),
                      SizedBox(height: 16.0),

                      // New Images
                      Text(
                        'Add New Images (Max 10)',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      ElevatedButton.icon(
                        onPressed: _pickNewImages,
                        icon: Icon(Icons.add_a_photo),
                        label: Text('Select New Images'),
                      ),
                      SizedBox(height: 8.0),
                      newImages.isNotEmpty
                          ? Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: List.generate(newImages.length, (index) {
                                return FutureBuilder<Uint8List?>(
                                  future: _getImageBytes(newImages[index]),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey[300],
                                        child: Center(child: CircularProgressIndicator()),
                                      );
                                    } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.broken_image, color: Colors.red),
                                      );
                                    } else {
                                      return Stack(
                                        children: [
                                          Image.memory(
                                            snapshot.data!,
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: GestureDetector(
                                              onTap: () => _removeNewImage(index),
                                              child: CircleAvatar(
                                                radius: 12,
                                                backgroundColor: Colors.black54,
                                                child: Icon(
                                                  Icons.close,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                );
                              }),
                            )
                          : Text('No new images selected.'),
                      SizedBox(height: 24.0),

                      // Submit Button
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _updateCar(context),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                            child: Text(
                              'Update Car',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
