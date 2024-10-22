import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:scan_products_app/data/ingredientRecommendation_service.dart'; // Service'i ekle
import 'package:scan_products_app/models/ingredientRecommendation.dart';
import 'package:scan_products_app/data/ingredientCategory_service.dart'; // IngredientCategoryService'i ekle
import 'package:scan_products_app/models/ingredientCategory.dart';
import 'package:scan_products_app/screens/finish_ingredient_rec_screen.dart';
import 'package:path/path.dart' as path;

class IngredientRecommendationScreen extends StatefulWidget {
  @override
  _IngredientRecommendationScreenState createState() =>
      _IngredientRecommendationScreenState();
}

class _IngredientRecommendationScreenState
    extends State<IngredientRecommendationScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  final int _totalPages = 7;

  final TextEditingController _recommendedIngredientNameController = TextEditingController();
  final TextEditingController _recommendationDescriptionController = TextEditingController();
  final TextEditingController _recommendedIngredientCategoryIdController = TextEditingController();
  final TextEditingController _recommenderNameController = TextEditingController();
  final TextEditingController _recommenderEmailController = TextEditingController();
  final IngredientCategoryService _categoryService = IngredientCategoryService();
  final IngredientRecommendationService _recommendationService = IngredientRecommendationService(); // Service'i tanımla
  List<IngredientCategory> _categories = [];

  bool _showError = false; // Error flag
  File? _selectedFile; // Dosya seçimi
  bool _isUploading = false; // Dosya yükleme durumu
  double _uploadProgress = 0.0; // Dosya yükleme ilerlemesi
  bool _isFinishing = false; // Bitirme durumu
  bool _isAnonymous = false; // Anonimlik durumu

  String? _fileURL; // Yüklenen dosya URL'si

  @override
  void initState() {
    super.initState();
    _categoryService.categoryStream.listen((categories) {
      setState(() {
        _categories = categories;
      });
    });
    _categoryService.getAllIngredientCategories();
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
        'İçerik Adı',
        _recommendedIngredientNameController,
        'Bu içeriğin adı nedir?',
        true,
      ),
      _buildFileUploadPage(), // Dosya yükleme sayfası
      _buildInputPage(
        'Açıklama Yaz',
        _recommendationDescriptionController,
        'İçerik hakkındaki fikirlerinle bizi etkile!',
        true,
      ),
      _buildCategoryInputPage(
        'Kategori Seç',
        _recommendedIngredientCategoryIdController,
        'Bu içerik hangi kategoriye giriyor?',
      ),
      _buildInputPage(
        'Adınız',
        _recommenderNameController,
        'İsminizi de öğrenebilir miyim? Sadece isterseniz!',
        false,
      ),
      _buildInputPage(
        'E-posta Adresiniz',
        _recommenderEmailController,
        'Son olarak size ulaşabileceğimiz bir E-posta! ',
        true,
      ),
      _buildAnonymousPage(),
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
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
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

  Widget _buildFileUploadPage() {
    return GestureDetector(
      onTap: _selectedFile == null ? _pickFile : null,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_isUploading) ...[
              Text(
                'Dosya yükleniyor... %${(_uploadProgress * 100).isNaN ? 0 : (_uploadProgress * 100).toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Container(
                height: 1,
                width: 200,
                child: LinearProgressIndicator(
                  value: _uploadProgress.isFinite && !_uploadProgress.isNaN ? _uploadProgress : 0,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.deepPurple,
                  ),
                ),
              ),
            ] else ...[
              if (_selectedFile == null) ...[
                OutlinedButton(
                  onPressed: _pickFile,
                  child: Text(
                    'Dosya Seç',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.deepPurple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 32.0,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Bizi ikna etmek için elinden geleni yapabilirsin!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    path.basename(_selectedFile!.path),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedFile = null;
                    });
                  },
                  child: Text(
                    'Dosyayı Kaldır',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.deepPurple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 32.0,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Şimdi ikna olmaya daha yakınız!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (_selectedFile == null)
                Text(
                  'Yükleyebileceğiniz dosya türleri: jpg, png, pdf, jpeg, doc, txt, pptx',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'pdf', 'jpeg', 'doc', 'txt', 'pptx'],
    );

    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _selectedFile = file;
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      try {
        // Örnek dosya yükleme işlemi, bu kısmı kendi dosya yükleme mantığınıza göre değiştirin
        String fileUrl = await _recommendationService.uploadFile(
          file,
          onProgress: (progress) {
            setState(() {
              _uploadProgress = progress.isNaN ? 0 : progress;
            });
          },
        );

        setState(() {
          _fileURL = fileUrl;
          _isUploading = false;
        });
      } catch (e) {
        setState(() {
          _isUploading = false;
        });
        // Hata durumunda kullanıcıya bildirimde bulunabilirsiniz
      }
    }
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
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
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

  Widget _buildAnonymousPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Anonim Olmak İster misiniz?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'İsminizin oylama sayfasında görüntülenmesini istemiyorsanız anonim kalabilirsiniz!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Anonim Ol'),
              value: _isAnonymous,
              onChanged: (value) {
                setState(() {
                  _isAnonymous = value;
                });
              },
              activeColor: Colors.deepPurple,
            ),
          ],
        ),
      ),
    );
  }

  void _nextPage() {
    FocusScope.of(context).unfocus(); // Klavyeyi kapat
    setState(() {
      _showError = true;
    });

    if (_validateCurrentPage()) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _showError = false;
      });
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
        return _recommendedIngredientNameController.text.isNotEmpty;
      case 3:
        return _recommendedIngredientCategoryIdController.text.isNotEmpty;
      case 5:
        return _recommenderEmailController.text.isNotEmpty;
      default:
        return true;
    }
  }

  void _finishRecommendation() async {
    if (_validateCurrentPage()) {
      IngredientRecommendation ingredientRecommendation = IngredientRecommendation(
        null,
        _recommendedIngredientNameController.text,
        _recommendationDescriptionController.text,
        _recommendedIngredientCategoryIdController.text,
        _recommenderEmailController.text,
        _recommenderNameController.text,
        0,
        0,
        _isAnonymous,
        DateTime.now(),
        _fileURL, // fileUrl burada konstruktöre ekleniyor
      );

      try {
        String id = await _recommendationService.addIngredientRecommendation(ingredientRecommendation);
        ingredientRecommendation.recommendationId = id; // ID'yi modelde güncelle
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FinishIngredientRecScreen(ingredientRecommendation),
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
        title: Text('İçerik Önerisi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              LinearProgressIndicator(
                value: (_currentPage + 1) / _totalPages,
                backgroundColor: Colors.deepPurple[100],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
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
                    Spacer(), // Bu esnek boşluk ekler
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _totalPages - 1) {
                          setState(() {
                            _isFinishing = true;
                          });
                          _finishRecommendation();
                        } else {
                          _nextPage();
                        }
                      },
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
          if (_isFinishing)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: IngredientRecommendationScreen(),
  ));
}
