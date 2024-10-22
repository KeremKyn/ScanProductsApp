import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Clipboard işlemleri için gerekli
import 'package:scan_products_app/main.dart';
import 'package:scan_products_app/models/ingredientRecommendation.dart';
import 'package:scan_products_app/screens/home_screen.dart';
import 'package:scan_products_app/data/productCategory_service.dart';
import 'package:scan_products_app/models/productCategory.dart';

class FinishIngredientRecScreen extends StatefulWidget {
  final IngredientRecommendation? ingredientRecommendation;
  final ProductCategoryService _categoryService = ProductCategoryService();

  FinishIngredientRecScreen(this.ingredientRecommendation) {
    _categoryService.getAllProductCategories();
  }

  @override
  _FinishIngredientRecScreenState createState() => _FinishIngredientRecScreenState();
}

class _FinishIngredientRecScreenState extends State<FinishIngredientRecScreen> {
  bool _isCopied = false;

  @override
  Widget build(BuildContext context) {
    // Ekran boyutlarını almak için MediaQuery kullanıyoruz
    var screenSize = MediaQuery.of(context).size;
    var iconSize = screenSize.width * 0.3; // Ekran genişliğinin %30'u kadar
    var infoContainerHeight = screenSize.height * 0.3; // Ekran yüksekliğinin %30'u kadar

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Dikey olarak ortalar
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: iconSize, // Dinamik ikon boyutu
                ),
                SizedBox(height: 16),
                Text(
                  'Teşekkürler!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Tavsiyeniz için teşekkür ederiz! Tavsiyeniz incelenip, en kısa sürede e-postanıza geri dönüş yapılacaktır.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tavsiye Kodu: ${widget.ingredientRecommendation?.recommendationId}',
                      style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    IconButton(
                      icon: Icon(
                        _isCopied ? Icons.done : Icons.copy,
                        color: Colors.black87,
                        size: 20.0,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: widget.ingredientRecommendation?.recommendationId ?? ''));
                        setState(() {
                          _isCopied = true;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  'Kodu saklayın, işinize yarayabilir!',
                  style: TextStyle(fontSize: 10, color: Colors.black54), // Küçük ve soluk metin
                ),
                SizedBox(height: 32),
                Container(
                  height: infoContainerHeight, // Dinamik yükseklik
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildInfoRow('İçerik Adı', widget.ingredientRecommendation?.recommendedIngredientName),
                        buildInfoRow('Açıklama', widget.ingredientRecommendation?.recommendationDescription),
                        StreamBuilder<List<ProductCategory>>(
                          stream: widget._categoryService.categoryStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return buildInfoRow('Kategori', 'Yükleniyor...');
                            } else if (snapshot.hasError) {
                              return buildInfoRow('Kategori', 'Hata');
                            } else if (snapshot.hasData) {
                              return buildInfoRow('Kategori', getCategoryName(snapshot.data!, widget.ingredientRecommendation?.recommendedIngredientCategoryId));
                            }
                            return buildInfoRow('Kategori', 'Kategori bulunamadı');
                          },
                        ),
                        buildInfoRow('Ad', widget.ingredientRecommendation?.recommenderName),
                        buildInfoRow('E-posta', widget.ingredientRecommendation?.recommenderEmail),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32),
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => MyApp()), // Ana sayfa ekranına yönlendirin
                          (Route<dynamic> route) => false, // Önceki rotaları kaldırır
                    );
                  },
                  child: Text(
                    'Anasayfaya Dön',
                    style: TextStyle(color: Colors.deepPurple), // Yazı rengi mor
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white, // Arka plan beyaz
                    side: BorderSide(color: Colors.deepPurple), // Kenarlar mor
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

  Widget buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Dikey boşluğu azaltarak satırlar arasında daha az boşluk oluşturur
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54), // Fontu küçült ve rengi soluk yap
          ),
          Expanded(
            child: Text(
              value ?? '',
              style: TextStyle(fontSize: 14, color: Colors.black54), // Fontu küçült ve rengi soluk yap
            ),
          ),
        ],
      ),
    );
  }

  String? getCategoryName(List<ProductCategory> categories, String? categoryId) {
    if (categoryId == null) return null;
    try {
      return categories.firstWhere((category) => category.categoryId == categoryId).categoryName;
    } catch (e) {
      return 'Kategori bulunamadı';
    }
  }
}
