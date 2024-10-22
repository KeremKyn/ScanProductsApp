import 'dart:async';
import 'package:scan_products_app/data/ingredient_service.dart';
import 'package:scan_products_app/models/ingredient.dart';

class IngredientBloc {
  final ingredientStreamController = StreamController<List<Ingredient>>.broadcast();

  Stream<List<Ingredient>> get getStream => ingredientStreamController.stream;

  Future<void> fetchIngredients() async {
    List<Ingredient> ingredients = await IngredientService().getAllIngredients();
    ingredientStreamController.sink.add(ingredients);
  }

  void dispose() {
    ingredientStreamController.close();
  }
}

final ingredientBloc = IngredientBloc();
