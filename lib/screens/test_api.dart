import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:scan_products_app/screens/finish_picture_screen.dart';

class TestApi extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TestApiState();
  }
}

class _TestApiState extends State<TestApi> {
  File? _file;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _file = File(pickedFile.path);
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FinishPictureScreen(_file!),
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Pick Image from Gallery'),
          ),
          SizedBox(height: 20),
          if (_file != null) Text('Selected file: ${_file!.path.split('/').last}'),
        ],
      ),
    );
  }
}

