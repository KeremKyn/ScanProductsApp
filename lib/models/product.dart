class Product {
  String? productId;
  String? productBrand;
  String? productName;
  String? categoryId;
  List<String>? ingredients;
  DateTime? creationTime;
  int? viewCount;

  Product(this.productId, this.productBrand, this.productName, this.categoryId,
      this.ingredients, this.viewCount);
}
