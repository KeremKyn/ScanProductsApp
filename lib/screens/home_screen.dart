import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:scan_products_app/constants/constant.dart';
import 'package:scan_products_app/screens/ingredient_recommendation_screen.dart';
import 'package:scan_products_app/screens/product_recommendation_screen.dart';
import 'package:scan_products_app/screens/take_picture_screen.dart';
import 'package:scan_products_app/screens/test_api.dart';
import 'package:scan_products_app/screens/vote_rec_screen.dart'; // VoteRecScreen sınıfını import edin
import 'product_list_screen.dart'; // ProductListScreen class'ını import edin
import 'ingredient_list_screen.dart'; // IngredientListScreen class'ını import edin

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomeScreen.withCameras(this.cameras);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Başlangıçta seçili olan tab index'i

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Seçili tab index'ini güncelle
    });
  }

  @override
  Widget build(BuildContext context) {
    // Kamera listesi kontrolü
    Widget cameraScreen = widget.cameras.isNotEmpty
        ? TakePictureScreen(
            camera:
                widget.cameras.first) // Kamera varsa TakePictureScreen kullan
        : Center(
            child: Text('Kamera bulunamadı.')); // Kamera yoksa bilgilendirme

    List<Widget> _widgetOptions = [
      buildSearchOptions(context), // Arama seçenekleri için butonlar
      cameraScreen, // Photo tab için, kamera kontrolü sonrası
      buildSupportItems(context), // Support tab için
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Spack',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 24,
            fontWeight: FontWeight.w300, // Daha ince font ağırlığı
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child:
            _widgetOptions.elementAt(_selectedIndex), // Seçili widget'ı göster
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'İncele',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Kamera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Destek',
          ),
        ],
        currentIndex: _selectedIndex, // Şu anda seçili olan tab index'i
        selectedItemColor: ProductsPageColor,
        onTap: _onItemTapped, // Tab'a tıklanınca bu fonksiyonu çağır
        selectedLabelStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w300, // Daha ince font ağırlığı
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w300, // Daha ince font ağırlığı
        ),
      ),
    );
  }

  Widget buildSearchOptions(BuildContext context) {
    double iconSize = MediaQuery.of(context).size.width *
        0.3; // Ekran genişliğinin %30'u kadar ikon boyutu

    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            margin: EdgeInsets.all(10),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ProductListScreen()), // ProductListScreen'e yönlendir
                );
              },
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: ProductsPageColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Icon(Icons.local_offer,
                        color: Colors.white.withOpacity(0.3), size: iconSize),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 0), // İkonun üstüne biraz boşluk bırak
                        Text(
                          'Ürünler',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            fontWeight:
                                FontWeight.w300, // Daha ince font ağırlığı
                          ),
                        ),
                        SizedBox(height: 10), // Metinler arasında boşluk bırak
                        Text(
                          'Bir ürünün içeriklerini mi merak ediyorsun ?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight:
                                FontWeight.w300, // Daha ince font ağırlığı
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.all(10),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          IngredientListScreen()), // IngredientListScreen'e yönlendir
                );
              },
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Icon(Icons.menu,
                        color: Colors.white.withOpacity(0.3), size: iconSize),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 0), // İkonun üstüne biraz boşluk bırak
                        Text(
                          'İçerikler',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            fontWeight:
                                FontWeight.w300, // Daha ince font ağırlığı
                          ),
                        ),
                        SizedBox(height: 10), // Metinler arasında boşluk bırak
                        Text(
                          'Bir içerik hakkında bilgi ister misin ?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight:
                                FontWeight.w300, // Daha ince font ağırlığı
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSupportItems(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            margin: EdgeInsets.all(10),
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return buildSupportOptions(context);
                  },
                );
              },
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: ProductsPageColor, // Çerçeve rengini ProductsPageColor yapın
                        width: 1, // Çerçeve kalınlığını ayarlayın
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(Icons.add,
                        color: ProductsPageColor.withOpacity(0.3),
                        size: MediaQuery.of(context).size.width * 0.3),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 0),
                        Text(
                          'Bize Tavsiyede Bulun',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Bize ürün veya içerik tavsiyesinde bulun!',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.all(10),
            child: InkWell(
              onTap: () {
                // Tavsiyeleri incele seçeneği için VoteRecScreen'e yönlendir
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VoteRecScreen()),
                );
              },
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100], // Card arka plan rengi beyazımsı gri tonunda
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: IngredientPageColor, // Çerçeve rengini IngredientPageColor yapın
                        width: 1, // Çerçeve kalınlığını ayarlayın
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(Icons.arrow_circle_up,
                        color: IngredientPageColor.withOpacity(0.3), // İkon rengini IngredientPageColor yapın
                        size: MediaQuery.of(context).size.width * 0.3),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 0),
                        Text(
                          'Tavsiyeleri İncele',
                          style: TextStyle(
                            color: Colors.black87, // Yazı rengini siyah tonuna çevirin
                            fontSize: 20,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Yapılan içerik tavsiyeleri hakkında fikrini belirt!',
                          style: TextStyle(
                            color: Colors.black54, // Yazı rengini siyah tonuna çevirin
                            fontSize: 16,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSupportOptions(BuildContext context) {
    return Container(
      height: 150,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.add),
            title: Text('Ürün Tavsiyesinde bulun'),
            onTap: () {
              Navigator.pop(context); // BottomSheet'i kapat
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductRecommendationScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.add),
            title: Text('İçerik Tavsiyesinde bulun'),
            onTap: () {
              Navigator.pop(context); // BottomSheet'i kapat
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => IngredientRecommendationScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
