import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePickerWidget extends StatefulWidget {
  final Function(List<File>) onImagesSelected;

  ImagePickerWidget({required this.onImagesSelected});

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  List<File> images = [];
  final ImagePicker _picker = ImagePicker();

  void _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.length <= 10) {
      setState(() {
        images = pickedFiles.map((e) => File(e.path)).toList();
        widget.onImagesSelected(images);
      });
    } else if (pickedFiles != null && pickedFiles.length > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You can select up to 10 images.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        images.isNotEmpty
            ? Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: images
                    .map((image) => Image.file(
                          image,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ))
                    .toList(),
              )
            : Container(),
        SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: _pickImages,
          child: Text('Select Images'),
        ),
      ],
    );
  }
}
