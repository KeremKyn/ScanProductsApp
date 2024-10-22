import 'package:flutter/material.dart';
import 'package:scan_products_app/data/productCategory_service.dart';
import 'package:scan_products_app/data/productRecommendation_service.dart'; // Service'i ekle
import 'package:scan_products_app/models/productCategory.dart';
import 'package:scan_products_app/models/productRecommendation.dart';
import 'package:scan_products_app/screens/finish_product_rec_screen.dart';

class ProductRecommendationScreen extends StatefulWidget {
  @override
  _ProductRecommendationScreenState createState() =>
      _ProductRecommendationScreenState();
}

class _ProductRecommendationScreenState
    extends State<ProductRecommendationScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  final int _totalPages = 7;

  final TextEditingController _recommendedBrandController =
  TextEditingController();
  final TextEditingController _recommendedProductNameController =
  TextEditingController();
  final TextEditingController _recommendationDescriptionController =
  TextEditingController();
  final TextEditingController _recommendedProductCategoryIdController =
  TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _recommenderNameController =
  TextEditingController();
  final TextEditingController _recommenderEmailController =
  TextEditingController();
  final List<String> _ingredients = [];
  bool _showInitialChip = true;
  final ProductCategoryService _categoryService = ProductCategoryService();
  final ProductRecommendationService _recommendationService =
  ProductRecommendationService(); // Service'i tanımla
  List<ProductCategory> _categories = [];

  bool _showError = false; // Error flag

  @override
  void initState() {
    super.initState();
    _categoryService.categoryStream.listen((categories) {
      setState(() {
        _categories = categories;
      });
    });
    _categoryService.getAllProductCategories();
  }

  @override
  void dispose() {
    _categoryService.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Widget> _buildPages() {
    return [
      _buildInputPage(
        'Marka Adı',
        _recommendedBrandController,
        'Bu ürünün markası nedir?',
        true,
      ),
      _buildInputPage(
        'Ürün Adı',
        _recommendedProductNameController,
        'Bu ürünün adı nedir?',
        true,
      ),
      _buildInputPage(
        'Açıklama Yaz',
        _recommendationDescriptionController,
        'Buraya ürün hakkında bir açıklama yazabilirsin!',
        false,
      ),
      _buildCategoryInputPage(
        'Kategori Seç',
        _recommendedProductCategoryIdController,
        'Bu ürün hangi kategoriye giriyor?',
      ),
      _buildIngredientInputPage(
        'Ürün İçeriği',
        _ingredientController,
        'Bu ürünün içeriklerini söyleyin, hepimiz bilelim!',
      ),
      _buildInputPage(
        'Adınız',
        _recommenderNameController,
        'İsminizi de öğrenebilir miyim?',
        false,
      ),
      _buildInputPage(
        'E-posta Adresiniz',
        _recommenderEmailController,
        'Son olarak size ulaşabileceğimiz bir E-posta! ',
        true,
      ),
    ];
  }

  Widget _buildInputPage(String label, TextEditingController controller,
      String hintText, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                errorText: _showError && isRequired && controller.text.isEmpty
                    ? 'Bu alan boş bırakılamaz'
                    : null,
              ),
              onSubmitted: (value) {
                if (isRequired && value.isEmpty) {
                  setState(() {
                    _showError = true;
                  });
                } else {
                  _nextPage();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryInputPage(
      String label, TextEditingController controller, String hintText) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: controller.text.isEmpty ? null : controller.text,
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category.categoryId,
                  child: Text(category.categoryName ?? 'Kategori isimsiz'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  controller.text = value ?? '';
                });
              },
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                errorText: _showError && controller.text.isEmpty
                    ? 'Bu alan boş bırakılamaz'
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientInputPage(
      String label, TextEditingController controller, String hintText) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                errorText: _showError && _ingredients.isEmpty
                    ? 'Bu alan boş bırakılamaz'
                    : null,
              ),
              onChanged: (value) {
                if (value.contains(',')) {
                  List<String> parts = value.split(',');
                  setState(() {
                    for (var part in parts) {
                      if (part.trim().isNotEmpty) {
                        _ingredients.add(part.trim());
                      }
                    }
                    controller.clear();
                    _showInitialChip = false;
                  });
                  _scrollToEnd();
                }
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    _ingredients.add(value);
                    controller.clear();
                    _showInitialChip = false;
                  });
                  _scrollToEnd();
                  _nextPage();
                }
              },
            ),
            SizedBox(height: 16),
            Container(
              height: 50,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_showInitialChip)
                      Chip(
                        label: Text('Virgülle ayırın'),
                        deleteIcon: Icon(
                          Icons.close,
                          size: 18,
                        ),
                        onDeleted: () {
                          setState(() {
                            _showInitialChip = false;
                          });
                        },
                      ),
                    ..._ingredients.map((ingredient) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          label: Text(ingredient),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 18,
                          ),
                          onDeleted: () {
                            setState(() {
                              _ingredients.remove(ingredient);
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _nextPage() {
    FocusScope.of(context).unfocus(); // Klavyeyi kapat
    setState(() {
      _showError = true;
    });

    if (_currentPage < _totalPages - 1) {
      if (_validateCurrentPage()) {
        _pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _showError = false;
        });
      }
    } else {
      _finishRecommendation();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0:
        return _recommendedBrandController.text.isNotEmpty;
      case 1:
        return _recommendedProductNameController.text.isNotEmpty;
      case 3:
        return _recommendedProductCategoryIdController.text.isNotEmpty;
      case 4:
        return _ingredients.isNotEmpty;
      case 6:
        return _recommenderEmailController.text.isNotEmpty;
      default:
        return true;
    }
  }

  void _finishRecommendation() async {
    if (_validateCurrentPage()) {
      ProductRecommendation productRecommendation = ProductRecommendation(
        _recommendedBrandController.text,
        _recommendedProductNameController.text,
        _recommendationDescriptionController.text,
        _recommendedProductCategoryIdController.text,
        _ingredients,
        _recommenderNameController.text,
        _recommenderEmailController.text,
      );

      try {
        String id = await _recommendationService.addProductRecommendation(productRecommendation);
        productRecommendation.recommendationId = id; // ID'yi modelde güncelle
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FinishProductRecScreen(productRecommendation),
          ),
        );
      } catch (e) {
        print('Failed to add recommendation: $e');
        // Hata durumunda kullanıcıya bildirimde bulunabilirsiniz.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ürün Önerisi', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / _totalPages,
            backgroundColor: Colors.deepPurple[100],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(), // Elle kaydırmayı devre dışı bırak
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                  _showError = false; // Sayfa değiştirildiğinde hata bayrağını sıfırlayın
                });
              },
              children: _buildPages(),
            ),
          ),
          SizedBox(height: 16), // Alt kısımda boşluk bırakmak için
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  OutlinedButton(
                    onPressed: _previousPage,
                    child: Text('Geri', style: TextStyle(color: Colors.deepPurple)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.deepPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                    ),
                  ),
                Spacer(), // This adds flexible space
                ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(_currentPage == _totalPages - 1 ? 'Bitir' : 'İleri'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50), // Daha fazla boşluk bırakmak için
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProductRecommendationScreen(),
  ));
}
