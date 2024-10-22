class IngredientRecommendation {
  String? recommendationId;
  String? recommendedIngredientName;
  String? recommendationDescription;
  String? recommendedIngredientCategoryId;
  String? recommenderEmail;
  String? recommenderName;
  int? approvalCount;
  int? rejectionCount;
  bool? isAnonymous;
  DateTime? creationTime;
  String? fileUrl;

  IngredientRecommendation(
    this.recommendationId,
    this.recommendedIngredientName,
    this.recommendationDescription,
    this.recommendedIngredientCategoryId,
    this.recommenderEmail,
    this.recommenderName,
    this.approvalCount,
    this.rejectionCount,
    this.isAnonymous,
    this.creationTime,
    this.fileUrl
  );
}
