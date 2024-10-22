import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scan_products_app/main.dart';
import 'dart:math';

class PictureIngredientScreen extends StatelessWidget {
  final String? message;

  PictureIngredientScreen(this.message);

  @override
  Widget build(BuildContext context) {
    String fileUrl = 'URL yok';
    List<dynamic> ingredients = [];

    if (message != null && message!.isNotEmpty) {
      try {
        Map<String, dynamic>? responseData = jsonDecode(message!);
        if (responseData != null) {
          fileUrl = responseData['file_url'] ?? 'URL yok';
          ingredients = responseData['ingredients'] ?? [];
        }
      } catch (e) {
        print('JSON ayrıştırma hatası: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('EC2 Response'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Dosya URL:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  fileUrl,
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'İçerikler:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Each row contains 2 items
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1, // Makes the items square
                  ),
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: getRandomLightColor(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Center(
                          child: Text(
                            ingredients[index],
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => MyApp()), // Navigate to the main screen
                          (Route<dynamic> route) => false, // Remove all previous routes
                    );
                  },
                  child: Text(
                    'Anasayfaya Dön',
                    style: TextStyle(color: Colors.deepPurple), // Text color purple
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white, // Background white
                    side: BorderSide(color: Colors.deepPurple), // Border purple
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
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

  Color getRandomLightColor() {
    final Random random = Random();
    return Color.fromARGB(
      255,
      200 + random.nextInt(56), // 200-255 arası
      200 + random.nextInt(56), // 200-255 arası
      200 + random.nextInt(56), // 200-255 arası
    );
  }
}
