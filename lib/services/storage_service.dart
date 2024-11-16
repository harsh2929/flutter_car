// lib/services/storage_service.dart

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Uploads an image and returns its download URL
  Future<String> uploadImage(
      XFile image, String userId, String carId, int index) async {
    try {
      // Read image bytes
      Uint8List imageData = await image.readAsBytes();

      // Define the storage path
      String filePath = 'users/$userId/cars/$carId/image_$index.jpg';

      // Upload the image data
      UploadTask uploadTask = _storage.ref(filePath).putData(imageData);

      // Wait for the upload to complete
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Upload Image Error: $e');
      return ''; // Return an empty string to indicate failure
    }
  }
}
