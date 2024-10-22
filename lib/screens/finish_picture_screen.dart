import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:scan_products_app/data/picture_product_service.dart';
import 'dart:io';
import 'package:scan_products_app/screens/picture_ingredient_screen.dart'; // PictureIngredientScreen'in olduğu dosyayı import edin

class FinishPictureScreen extends StatefulWidget {
  final File imageFile;

  const FinishPictureScreen(this.imageFile);

  @override
  _FinishPictureScreenState createState() => _FinishPictureScreenState();
}

class _FinishPictureScreenState extends State<FinishPictureScreen> {
  final PhotoProductService _photoService = PhotoProductService();
  bool _isUploading = false;
  File? _croppedImageFile;

  @override
  void initState() {
    super.initState();
    _croppedImageFile = widget.imageFile;
  }

  Future<void> _cropImage() async {
    // Eklenen kısım - Aspect Ratio kilidini kaldır ve serbest kırpma oranını ekle
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: widget.imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false, // Bu satır aspect ratio kilidini kaldırır
        ),
        IOSUiSettings(
          minimumAspectRatio: 0.1,
        ),
      ],
    );


    if (croppedFile != null) {
      setState(() {
        _croppedImageFile = File(croppedFile.path); // CroppedFile'i File'a dönüştürme
      });
    }
  }

  void _uploadPhoto() async {
    setState(() {
      _isUploading = true;
    });

    String message = await _photoService.uploadPhotoAndGetMessage(_croppedImageFile!);

    if (message.isNotEmpty) {
      // Başarılı yükleme ve içerik alma durumu
      print('Mesaj: $message');
      await Future.delayed(Duration(milliseconds: 300)); // Kısa bir gecikme ekleyin
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PictureIngredientScreen(message)),
      );
    } else {
      // Başarısız yükleme durumu
      print('Fotoğraf yükleme başarısız oldu.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf yükleme başarısız oldu.'),
        ),
      );
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _cancelUpload() {
    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: _isUploading
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Bu işlem bir kaç saniye sürebilir...',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      _croppedImageFile!,
                      height: MediaQuery.of(context).size.height * 0.7,
                      width: MediaQuery.of(context).size.width * 1,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Fotoğraf analiz edilecek, Onaylıyor musun?',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          if (!_isUploading)
            Positioned(
              bottom: 40,
              left: 20,
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context); // Tekrar fotoğraf çekmek için geri dön
                },
                icon: Icon(Icons.camera_alt),
                color: Colors.grey[700],
                iconSize: 35.0,
              ),
            ),
          if (!_isUploading)
            Positioned(
              bottom: 40,
              right: 20,
              child: IconButton(
                onPressed: _uploadPhoto, // Fotoğrafı onayla ve işlemi yap
                icon: Icon(Icons.check),
                color: Colors.green,
                iconSize: 35.0,
              ),
            ),
          if (!_isUploading)
            Positioned(
              bottom: 40,
              left: MediaQuery.of(context).size.width / 2 - 25,
              child: IconButton(
                onPressed: _cropImage, // Fotoğrafı kırp
                icon: Icon(Icons.crop),
                color: Colors.deepPurple,
                iconSize: 35.0,
              ),
            ),
        ],
      ),
    );
  }
}
