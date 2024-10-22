import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scan_products_app/models/ingredient.dart';

class IngredientService {
  List<Ingredient> ingredients = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamController<List<Ingredient>> _ingredientController = StreamController<List<Ingredient>>.broadcast();

  static final IngredientService _singleton = IngredientService._internal();

  factory IngredientService() {
    return _singleton;
  }

  IngredientService._internal();

  Stream<List<Ingredient>> get ingredientStream => _ingredientController.stream;

  Future<List<Ingredient>> getAllIngredients() async {
    QuerySnapshot querySnapshot = await _firestore.collection('Ingredients').get();
    ingredients = querySnapshot.docs.map((doc) {
      return Ingredient(
        doc.id,  // Using document ID as ingredientId
        doc['ingredientName'],
        doc['ingredientDescription'],
        doc['ingredientCategoryId'],
        doc['isHarmful'],
        (doc['creationTime'] as Timestamp).toDate(),  // Converting Timestamp to DateTime
      );
    }).toList();
    _ingredientController.sink.add(ingredients); // İçerikleri stream'e ekleme
    return ingredients;
  }

  Future<List<Ingredient>> getIngredientsByIds(List<String> ids) async {
    QuerySnapshot querySnapshot = await _firestore.collection('Ingredients')
        .where(FieldPath.documentId, whereIn: ids)
        .get();
    return querySnapshot.docs.map((doc) {
      return Ingredient(
        doc.id,
        doc['ingredientName'],
        doc['ingredientDescription'],
        doc['ingredientCategoryId'],
        doc['isHarmful'],
        (doc['creationTime'] as Timestamp).toDate(),
      );
    }).toList();
  }

  void filterIngredientsByCategory(String categoryId) {
    final filteredIngredients = ingredients.where((ingredient) {
      return ingredient.ingredientCategoryId == categoryId;
    }).toList();
    _ingredientController.sink.add(filteredIngredients);
  }

  void filterIngredientsBySearchQuery(String query) {
    final filteredIngredients = ingredients.where((ingredient) {
      final ingredientName = ingredient.ingredientName?.toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();
      return ingredientName.contains(searchQuery);
    }).toList();
    _ingredientController.sink.add(filteredIngredients);
  }

  void filterIngredientsByCategoryAndSearchQuery(String categoryId, String query) {
    final filteredIngredients = ingredients.where((ingredient) {
      final ingredientName = ingredient.ingredientName?.toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();
      return ingredient.ingredientCategoryId == categoryId &&
          ingredientName.contains(searchQuery);
    }).toList();
    _ingredientController.sink.add(filteredIngredients);
  }

  void dispose() {
    _ingredientController.close();
    _ingredientController = StreamController<List<Ingredient>>.broadcast(); // StreamController'ı yeniden başlat
  }
}
