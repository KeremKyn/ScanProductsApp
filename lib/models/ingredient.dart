class Ingredient {
  String? ingredientId;
  String? ingredientName;
  String? ingredientDescription;
  String? ingredientCategoryId;
  bool? isHarmful;
  DateTime? creationTime;

  Ingredient(this.ingredientId, this.ingredientName, this.ingredientDescription,
      this.ingredientCategoryId, this.isHarmful, this.creationTime);
}
