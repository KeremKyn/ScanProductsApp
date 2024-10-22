import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scan_products_app/models/productRecommendation.dart';

class ProductRecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> addProductRecommendation(ProductRecommendation recommendation) async {
    try {
      DocumentReference docRef = await _firestore.collection('ProductRecommendation').add({
        'recommendedBrand': recommendation.recommendedBrand,
        'recommendedProductName': recommendation.recommendedProductName,
        'recommendationDescription': recommendation.recommendationDescription,
        'recommendedProductCategoryId': recommendation.recommendedProductCategoryId,
        'ingredients': recommendation.ingredients,
        'recommenderName': recommendation.recommenderName,
        'recommenderEmail': recommendation.recommenderEmail,
        'creationTime': recommendation.creationTime ?? FieldValue.serverTimestamp(),
      });
      return docRef.id; // ID'yi döndür
    } catch (error) {
      print('Error adding recommendation: $error'); // Log errors
      rethrow;
    }
  }
}
