import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scan_products_app/models/productCategory.dart';

class ProductCategoryService {
  List<ProductCategory> productCategories = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamController<List<ProductCategory>> _categoryController = StreamController<List<ProductCategory>>.broadcast();
  StreamSubscription? _categorySubscription;

  static final ProductCategoryService _singleton = ProductCategoryService._internal();

  factory ProductCategoryService() {
    return _singleton;
  }

  ProductCategoryService._internal() {
    _listenToCategoryChanges();
  }

  Stream<List<ProductCategory>> get categoryStream => _categoryController.stream;

  void _listenToCategoryChanges() {
    _categorySubscription = _firestore.collection('ProductCategory').snapshots().listen((snapshot) {
      productCategories = snapshot.docs.map((doc) {
        return ProductCategory(
          doc.id,  // Using document ID as productId
          doc['categoryName'],
          doc['categoryDescription'],
          (doc['creationTime'] as Timestamp).toDate(),  // Converting Timestamp to DateTime
        );
      }).toList();
      _categoryController.sink.add(productCategories);
    }, onError: (error) {
      print('Error listening to category changes: $error'); // Log errors
    });
  }

  Future<List<ProductCategory>> getAllProductCategories() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('ProductCategory').get();
      productCategories = querySnapshot.docs.map((doc) {
        return ProductCategory(
          doc.id,  // Using document ID as productId
          doc['categoryName'],
          doc['categoryDescription'],
          (doc['creationTime'] as Timestamp).toDate(),  // Converting Timestamp to DateTime
        );
      }).toList();
      _categoryController.sink.add(productCategories); // Initial fetch
      return productCategories;
    } catch (error) {
      print('Error fetching categories: $error'); // Log errors
      rethrow;
    }
  }

  void dispose() {
    _categorySubscription?.cancel();
    _categoryController.close();
    _categoryController = StreamController<List<ProductCategory>>.broadcast(); // Reinitialize the StreamController
  }
}
