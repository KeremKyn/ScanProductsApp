import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:scan_products_app/screens/home_screen.dart';
import 'package:scan_products_app/screens/product_list_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Kullanılabilir kameraları al
  try {
    // Kullanılabilir kameraları al
    cameras = await availableCameras();
  } catch (e) {
    print('Kamera alınırken bir hata oluştu: $e');
    // Kamera ile ilgili işlevselliklerin devre dışı bırakılması veya alternatif bir uygulama akışının sağlanması
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/products':(BuildContext context) => ProductListScreen(),
        '/home':(BuildContext context) => HomeScreen.withCameras(cameras),
      },
      initialRoute: '/home',
    );
  }
}
