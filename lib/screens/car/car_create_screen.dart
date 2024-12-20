import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';
import '../../models/car.dart';
import '../../widgets/tag_input_field.dart';
import 'package:image_picker/image_picker.dart';

class CarCreateScreen extends StatefulWidget {
  @override
  _CarCreateScreenState createState() => _CarCreateScreenState();
}

class _CarCreateScreenState extends State<CarCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  List<String> tags = [];
  List<XFile> images = [];
  bool isLoading = false;
  String errorMessage = '';

  List<String> _generateSearchKeywords(String title, List<String> tags, String description) {
    List<String> keywords = [];
    keywords.addAll(title.toLowerCase().split(' '));
    keywords.addAll(tags.map((tag) => tag.toLowerCase()));
    keywords.addAll(description.toLowerCase().split(' '));
    return keywords;
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (images.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select at least one image.')),
        );
        return;
      }

      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final firestoreService = FirestoreService();
        final storageService = StorageService();
        final user = authService.currentUser;

        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not authenticated.')),
          );
          setState(() {
            isLoading = false;
          });
          return;
        }

        String userId = user.uid;
        String carId = firestoreService.generateCarId();

        List<String> searchKeywords = _generateSearchKeywords(title, tags, description);

        List<String> imageUrls = [];
        for (int i = 0; i < images.length; i++) {
          String imageUrl = await storageService.uploadImage(
            images[i],
            userId,
            carId,
            i,
          );

          if (imageUrl.isEmpty) {
            throw Exception('Image upload failed for image index $i');
          }

          imageUrls.add(imageUrl);
        }

        Car newCar = Car(
          id: carId,
          title: title,
          description: description,
          tags: tags,
          imageUrls: imageUrls,
          ownerId: userId,
          searchKeywords: searchKeywords,
        );

        await firestoreService.addCar(newCar);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Car added successfully!')),
        );

        Navigator.pop(context);
      } catch (e) {
        print('Error adding car: $e');
        setState(() {
          errorMessage = 'Failed to add car. Please try again.';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _pickImages() async {
    final ImagePicker _picker = ImagePicker();
    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null) {
        if (pickedFiles.length + images.length > 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You can upload up to 10 images.')),
          );
          return;
        }
        setState(() {
          images.addAll(pickedFiles);
        });
      }
    } catch (e) {
      print('Error picking images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick images.')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

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
        title: Text('Add New Car'),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent.shade100, Colors.blueAccent.shade400],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Field
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Title',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
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
                        decoration: InputDecoration(
                          labelText: 'Description',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
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
                        onTagsChanged: (newTags) {
                          setState(() {
                            tags = newTags;
                          });
                        },
                      ),
                      SizedBox(height: 16.0),

                      // Image Picker
                      Text(
                        'Images (Max 10)',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.0),
                      ElevatedButton.icon(
                        onPressed: _pickImages,
                        icon: Icon(Icons.add_a_photo),
                        label: Text('Select Images'),
                      ),
                      SizedBox(height: 16.0),

                      // Display Selected Images
                      images.isNotEmpty
                          ? Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: List.generate(images.length, (index) {
                                return FutureBuilder<Uint8List?>(
                                  future: _getImageBytes(images[index]),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey[300],
                                        child: Center(child: CircularProgressIndicator()),
                                      );
                                    } else if (snapshot.hasError ||
                                        !snapshot.hasData ||
                                        snapshot.data == null) {
                                      return Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.broken_image, color: Colors.red),
                                      );
                                    } else {
                                      return Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10.0),
                                            child: Image.memory(
                                              snapshot.data!,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: GestureDetector(
                                              onTap: () => _removeImage(index),
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
                          : Text(
                              'No images selected.',
                              style: TextStyle(color: Colors.white),
                            ),
                      SizedBox(height: 24.0),

                      // Submit Button
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _submitForm(context),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text(
                            'Add Car',
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                      // Error Message
                      if (errorMessage.isNotEmpty)
                        Center(
                          child: Text(
                            errorMessage,
                            style: TextStyle(color: Colors.red, fontSize: 14),
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
