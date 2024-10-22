import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scan_products_app/models/product.dart';

class ProductService {
  List<Product> products = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamController<List<Product>> _productController = StreamController<List<Product>>.broadcast();

  static final ProductService _singleton = ProductService._internal();

  factory ProductService() {
    return _singleton;
  }

  ProductService._internal();

  Stream<List<Product>> get productStream => _productController.stream;

  Future<List<Product>> getAllProducts() async {
    QuerySnapshot querySnapshot = await _firestore.collection('Products').get();
    products = querySnapshot.docs.map((doc) {
      return Product(
        doc.id,  // Using document ID as productId
        doc['productBrand'],
        doc['productName'],
        doc['categoryId'],
        List<String>.from(doc['ingredients']),
        doc['viewCount'] ?? 0, // Default value for viewCount is 0 if not present
      );
    }).toList();
    _productController.sink.add(products); // Ürünleri stream'e ekleme
    return products;
  }

  void filterProductsByCategory(String categoryId) {
    final filteredProducts = products.where((product) {
      return product.categoryId == categoryId;
    }).toList();
    _productController.sink.add(filteredProducts);
  }

  void filterProductsBySearchQuery(String query) {
    final filteredProducts = products.where((product) {
      final productBrand = product.productBrand?.toLowerCase() ?? '';
      final productName = product.productName?.toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();
      return productBrand.contains(searchQuery) || productName.contains(searchQuery);
    }).toList();
    _productController.sink.add(filteredProducts);
  }

  void filterProductsByCategoryAndSearchQuery(String categoryId, String query) {
    final filteredProducts = products.where((product) {
      final productBrand = product.productBrand?.toLowerCase() ?? '';
      final productName = product.productName?.toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();
      return product.categoryId == categoryId &&
          (productBrand.contains(searchQuery) || productName.contains(searchQuery));
    }).toList();
    _productController.sink.add(filteredProducts);
  }

  Future<void> incrementViewCount(String productId) async {
    DocumentReference productRef = _firestore.collection('Products').doc(productId);
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(productRef);
      if (!snapshot.exists) {
        throw Exception("Product does not exist!");
      }
      int newViewCount = (snapshot.data() as Map<String, dynamic>)['viewCount'] + 1;
      transaction.update(productRef, {'viewCount': newViewCount});
    });
  }

  void dispose() {
    _productController.close();
    _productController = StreamController<List<Product>>.broadcast(); // Reinitialize the StreamController
  }
}
