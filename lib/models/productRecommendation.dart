class ProductRecommendation {
  String? recommendationId;
  String? recommendedBrand;
  String? recommendedProductName;
  String? recommendationDescription;
  String? recommendedProductCategoryId;
  List<String>? ingredients;
  String? recommenderName;
  String? recommenderEmail;
  DateTime? creationTime;

  ProductRecommendation(
      this.recommendedBrand,
      this.recommendedProductName,
      this.recommendationDescription,
      this.recommendedProductCategoryId,
      this.ingredients,
      this.recommenderName,
      this.recommenderEmail
      );
}
