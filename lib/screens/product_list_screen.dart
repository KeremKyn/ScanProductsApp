import 'package:flutter/material.dart';
import 'package:scan_products_app/constants/constant.dart';
import 'package:scan_products_app/data/ingredient_service.dart';
import 'package:scan_products_app/data/productCategory_service.dart';
import 'package:scan_products_app/data/product_service.dart';
import 'package:scan_products_app/models/product.dart';
import 'package:scan_products_app/models/ingredient.dart';
import 'package:scan_products_app/models/productCategory.dart';
import 'package:scan_products_app/screens/product_detail.dart';

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> with RouteAware {
  final ProductCategoryService _categoryService = ProductCategoryService();
  final ProductService _productService = ProductService();
  final IngredientService _ingredientService = IngredientService();
  String _searchQuery = '';
  String? _selectedCategoryId;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productService.getAllProducts(); // Ürünleri getirme işlemi
    _categoryService.getAllProductCategories(); // Kategorileri getirme işlemi
    _ingredientService.getAllIngredients(); // Tüm içerikleri getirme
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    RouteObserver<ModalRoute<void>>().subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    RouteObserver<ModalRoute<void>>().unsubscribe(this);
    _categoryService.dispose();
    _productService.dispose();
    _ingredientService.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    setState(() {
      _productService.getAllProducts();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _applyFilters();
    });
  }

  void _onCategorySelected(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _applyFilters();
    });
  }

  void _clearCategorySelection() {
    setState(() {
      _selectedCategoryId = null;
      _applyFilters();
    });
  }

  void _applyFilters() {
    if (_searchQuery.isNotEmpty &&
        _selectedCategoryId != null &&
        _selectedCategoryId!.isNotEmpty) {
      _productService.filterProductsByCategoryAndSearchQuery(
          _selectedCategoryId!, _searchQuery);
    } else if (_searchQuery.isNotEmpty) {
      _productService.filterProductsBySearchQuery(_searchQuery);
    } else if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
      _productService.filterProductsByCategory(_selectedCategoryId!);
    } else {
      _productService.getAllProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ürünler',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: ProductsPageColor, // Sabiti kullanın
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          buildSearchBar(),
          SizedBox(height: 10),
          buildCategorySection(),
          Expanded(child: buildProductList()),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          labelText: 'Ara',
          hintText: 'Ürün adı veya marka',
          prefixIcon: Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear),
            onPressed: _clearSearchQuery,
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)), // Yuvarlak kenarlar
          ),
        ),
      ),
    );
  }

  Widget buildCategorySection() {
    return StreamBuilder<List<ProductCategory>>(
      stream: _categoryService.categoryStream, // Stream kullanılıyor
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Snapshot error: ${snapshot.error}'); // Log errors
          return Center(child: Text('Hata: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('No categories found'); // Log no data
          return Center(child: Text('Kategori yok.'));
        } else {
          print('Categories loaded: ${snapshot.data}'); // Log loaded data
          return buildCategoryList(snapshot.data!);
        }
      },
    );
  }

  Widget buildCategoryList(List<ProductCategory> categories) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final bool isSelected = category.categoryId == _selectedCategoryId;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Stack(
              children: [
                ElevatedButton(
                  onPressed: () => _onCategorySelected(category.categoryId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected
                        ? ProductsPageColor // Sabiti kullanın
                        : Colors.white,
                    side: BorderSide(color: ProductsPageColor), // Sabiti kullanın
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0), // Yuvarlak kenarlar
                    ),
                  ),
                  child: Text(
                    category.categoryName ?? 'isimsiz',
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : ProductsPageColor, // Sabiti kullanın
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _clearCategorySelection,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildProductList() {
    return StreamBuilder<List<Product>>(
      stream: _productService.productStream, // ProductService içinde stream
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Snapshot error: ${snapshot.error}'); // Log errors
          return Center(child: Text('Hata: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('No products found'); // Log no data
          return Center(child: Text('Ürün bulunamadı.'));
        } else {
          print('Products loaded: ${snapshot.data}'); // Log loaded data
          return buildProductListItems(snapshot);
        }
      },
    );
  }

  Widget buildProductListItems(AsyncSnapshot<List<Product>> snapshot) {
    return ListView.builder(
      itemCount: snapshot.data!.length,
      itemBuilder: (BuildContext context, int index) {
        final product = snapshot.data![index];

        return FutureBuilder<List<Ingredient>>(
          future: _ingredientService.getIngredientsByIds(product.ingredients!),
          builder: (context, ingredientSnapshot) {
            if (ingredientSnapshot.connectionState == ConnectionState.waiting) {
              return Center();
            } else if (ingredientSnapshot.hasError) {
              print('Snapshot error: ${ingredientSnapshot.error}'); // Log errors
              return Center(child: Text('Hata: ${ingredientSnapshot.error}'));
            } else if (!ingredientSnapshot.hasData || ingredientSnapshot.data!.isEmpty) {
              print('No ingredients found'); // Log no data
              return Center(child: Text('İçerik bulunamadı.'));
            } else {
              print('Ingredients loaded: ${ingredientSnapshot.data}'); // Log loaded data
              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0), // Yuvarlak kenarlar
                ),
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  leading: CircleAvatar(
                    backgroundColor: ProductsPageColor, // Sabiti kullanın
                    child: Text(
                      product.productName?.substring(0, 1) ?? 'N/A',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: product.productBrand ?? 'Marka yok',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: ' ${product.productName ?? 'İsim yok'}',
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(Icons.visibility, color: Colors.grey, size: 16),
                      SizedBox(width: 4),
                      Text(
                        '${product.viewCount ?? 0} görüntülenme',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                  trailing: Icon(Icons.info, color: ProductsPageColor), // Sabiti kullanın
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetail(product, ingredientSnapshot.data!),
                      ),
                    );
                    setState(() {
                      _productService.getAllProducts();
                    });
                  },
                ),
              );
            }
          },
        );
      },
    );
  }
}
