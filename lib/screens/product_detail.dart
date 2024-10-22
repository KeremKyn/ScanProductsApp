import 'package:flutter/material.dart';
import 'package:scan_products_app/constants/constant.dart';
import 'package:scan_products_app/data/product_service.dart';
import 'package:scan_products_app/models/product.dart';
import 'package:scan_products_app/models/ingredient.dart';

class ProductDetail extends StatefulWidget {
  final Product product;
  final List<Ingredient> allIngredients;

  ProductDetail(this.product, this.allIngredients);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> with SingleTickerProviderStateMixin {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final ProductService _productService = ProductService();
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _incrementViewCount();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _incrementViewCount() async {
    await _productService.incrementViewCount(widget.product.productId!);
  }

  void _showAnimatedDialog(int initialIndex) {
    _controller.forward();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black45,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return ScaleTransition(
          scale: _animation,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      scrollDirection: Axis.vertical, // Dikey kaydırma
                      controller: PageController(initialPage: initialIndex),
                      itemCount: widget.allIngredients.length,
                      itemBuilder: (context, index) {
                        Ingredient ingredient = widget.allIngredients[index];
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                ingredient.ingredientName ?? 'İsim yok',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Text(
                                        ingredient.ingredientDescription ?? 'Açıklama yok',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              Text.rich(
                                TextSpan(
                                  text: 'Bu içerik ',
                                  style: TextStyle(fontSize: 16),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: ingredient.isHarmful ?? false ? 'şüpheli ' : 'güvenli ',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(
                                      text: ingredient.isHarmful ?? false ? 'olabilir.' : 'görünüyor.',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true).pop(); // Dialogu kapat
                                  _controller.reset();
                                },
                                child: Text('Kapat', style: TextStyle(color: ProductsPageColor)), // Sabiti kullanın
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: ProductsPageColor), // Sabiti kullanın
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0), // Yuvarlak kenarlar
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Kaydırarak geçiş yapabilirsiniz',
                      style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w200),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
    ).then((_) => _controller.reset());
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Ingredient> productIngredients = widget.allIngredients
        .where((ingredient) =>
    widget.product.ingredients?.contains(ingredient.ingredientId) ?? false)
        .toList();

    List<Ingredient> filteredIngredients = productIngredients.where((ingredient) {
      return ingredient.ingredientName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
    }).toList();

    int totalIngredients = productIngredients.length;
    int suspiciousIngredients = productIngredients.where((ingredient) => ingredient.isHarmful ?? false).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.product.productBrand} ${widget.product.productName}',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ProductsPageColor, // Sabiti kullanın
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.black87, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '$totalIngredients',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Toplam İçerik Sayısı',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.redAccent, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '$suspiciousIngredients',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Şüpheli İçerik Sayısı',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'İçerik Ara',
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: Icon(Icons.search, color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(25.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              cursorColor: Colors.black,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredIngredients.length,
                itemBuilder: (context, index) {
                  Ingredient ingredient = filteredIngredients[index];
                  return Card(
                    color: ingredient.isHarmful ?? false ? Colors.red[50] : Colors.grey[50], // Sabiti kullanın
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      height: 80,
                      child: ListTile(
                        title: Text(
                          ingredient.ingredientName ?? '',
                          style: TextStyle(color: Colors.black),
                          overflow: TextOverflow.ellipsis, // Uzun metinler için ekledik
                        ),
                        subtitle: Text(
                          (ingredient.ingredientDescription?.length ?? 0) > 70
                              ? '${ingredient.ingredientDescription?.substring(0, 70)}...'
                              : ingredient.ingredientDescription ?? '',
                          style: TextStyle(color: Colors.black54),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis, // Uzun açıklamalar için ekledik
                        ),
                        onTap: () {
                          _showAnimatedDialog(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
