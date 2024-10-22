import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scan_products_app/models/ingredientCategory.dart';

class IngredientCategoryService {
  List<IngredientCategory> ingredientCategories = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamController<List<IngredientCategory>> _categoryController = StreamController<List<IngredientCategory>>.broadcast();
  StreamSubscription? _categorySubscription;

  static final IngredientCategoryService _singleton = IngredientCategoryService._internal();

  factory IngredientCategoryService() {
    return _singleton;
  }

  IngredientCategoryService._internal() {
    _listenToCategoryChanges();
  }

  Stream<List<IngredientCategory>> get categoryStream => _categoryController.stream;

  void _listenToCategoryChanges() {
    _categorySubscription = _firestore.collection('IngredientCategory').snapshots().listen((snapshot) {
      ingredientCategories = snapshot.docs.map((doc) {
        return IngredientCategory(
          doc.id,  // Using document ID as categoryId
          doc['categoryName'],
          doc['categoryDescription'],
          (doc['creationTime'] as Timestamp).toDate(),  // Converting Timestamp to DateTime
        );
      }).toList();
      _categoryController.sink.add(ingredientCategories);
    }, onError: (error) {
      print('Error listening to category changes: $error'); // Log errors
    });
  }

  Future<List<IngredientCategory>> getAllIngredientCategories() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('IngredientCategory').get();
      ingredientCategories = querySnapshot.docs.map((doc) {
        return IngredientCategory(
          doc.id,  // Using document ID as categoryId
          doc['categoryName'],
          doc['categoryDescription'],
          (doc['creationTime'] as Timestamp).toDate(),  // Converting Timestamp to DateTime
        );
      }).toList();
      _categoryController.sink.add(ingredientCategories); // Initial fetch
      return ingredientCategories;
    } catch (error) {
      print('Error fetching categories: $error'); // Log errors
      rethrow;
    }
  }

  void dispose() {
    _categorySubscription?.cancel();
    _categoryController.close();
    _categoryController = StreamController<List<IngredientCategory>>.broadcast(); // Reinitialize the StreamController
  }
}
