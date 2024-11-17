 
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

   Future<String> uploadImage(
      XFile image, String userId, String carId, int index) async {
    try {
       Uint8List imageData = await image.readAsBytes();

       String filePath = 'users/$userId/cars/$carId/image_$index.jpg';

       UploadTask uploadTask = _storage.ref(filePath).putData(imageData);

       TaskSnapshot taskSnapshot = await uploadTask;

       String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Upload Image Error: $e');
      return ''; // Return an empty string to indicate failure
    }
  }
}
