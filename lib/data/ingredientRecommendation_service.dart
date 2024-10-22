import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:scan_products_app/models/ingredientRecommendation.dart';
import 'package:scan_products_app/models/comment.dart';
import 'package:uuid/uuid.dart';

class IngredientRecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<IngredientRecommendation>> getAllRecommendations() async {
    QuerySnapshot querySnapshot = await _firestore.collection('IngredientRecommendation').get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>?;

      return IngredientRecommendation(
        doc.id,
        data?['recommendedIngredientName'],
        data?['recommendationDescription'],
        data?['recommendedIngredientCategoryId'],
        data?['recommenderEmail'],
        data?['recommenderName'],
        data?['approvalCount'],
        data?['rejectionCount'],
        data?['isAnonymous'],
        (data?['creationTime'] as Timestamp?)?.toDate(),
        data != null && data.containsKey('fileUrl') ? data['fileUrl'] : null,
      );
    }).toList();
  }

  Future<String> uploadFile(File file, {Function(double)? onProgress}) async {
    try {
      String fileName = basename(file.path);
      String uniqueFileName = '${Uuid().v4()}_$fileName';

      Reference storageReference = FirebaseStorage.instance.ref().child('recommendations/$uniqueFileName');
      UploadTask uploadTask = storageReference.putFile(file);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (onProgress != null) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        }
      });

      TaskSnapshot completedTask = await uploadTask;
      String downloadUrl = await completedTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Dosya yüklenirken hata oluştu: $e');
    }
  }

  Future<String> addIngredientRecommendation(IngredientRecommendation recommendation) async {
    try {
      DocumentReference docRef = await _firestore.collection('IngredientRecommendation').add({
        'recommendedIngredientName': recommendation.recommendedIngredientName,
        'recommendationDescription': recommendation.recommendationDescription,
        'recommendedIngredientCategoryId': recommendation.recommendedIngredientCategoryId,
        'recommenderEmail': recommendation.recommenderEmail,
        'recommenderName': recommendation.recommenderName,
        'approvalCount': recommendation.approvalCount ?? 0,
        'rejectionCount': recommendation.rejectionCount ?? 0,
        'isAnonymous': recommendation.isAnonymous ?? false,
        'creationTime': recommendation.creationTime ?? FieldValue.serverTimestamp(),
        'fileUrl': recommendation.fileUrl,
      });
      return docRef.id;
    } catch (error) {
      print('Error adding ingredient recommendation: $error');
      rethrow;
    }
  }

  Future<void> incrementApprovalCount(String recommendationId) async {
    DocumentReference recommendationRef = _firestore.collection('IngredientRecommendation').doc(recommendationId);
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(recommendationRef);
      if (!snapshot.exists) {
        throw Exception("Recommendation does not exist!");
      }
      int newApprovalCount = (snapshot.data() as Map<String, dynamic>)['approvalCount'] + 1;
      transaction.update(recommendationRef, {'approvalCount': newApprovalCount});
    });
  }

  Future<void> incrementRejectionCount(String recommendationId) async {
    DocumentReference recommendationRef = _firestore.collection('IngredientRecommendation').doc(recommendationId);
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(recommendationRef);
      if (!snapshot.exists) {
        throw Exception("Recommendation does not exist!");
      }
      int newRejectionCount = (snapshot.data() as Map<String, dynamic>)['rejectionCount'] + 1;
      transaction.update(recommendationRef, {'rejectionCount': newRejectionCount});
    });
  }

  // Comments Collection Operations
  Future<List<Comment>> getComments(String recommendationId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('Comments')
        .where('ingredientRecommendationId', isEqualTo: recommendationId)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Comment(
        doc.id,
        data['ingredientRecommendationId'],
        data['commenterName'],
        data['commenterEmail'],
        data['likeCount'],
        data['commentText'],
        (data['creationTime'] as Timestamp).toDate(),
      );
    }).toList();
  }

  Future<void> incrementCommentLikeCount(String commentId) async {
    DocumentReference commentRef = _firestore.collection('Comments').doc(commentId);
    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(commentRef);
      if (!snapshot.exists) {
        throw Exception("Comment does not exist!");
      }
      int newLikeCount = (snapshot.data() as Map<String, dynamic>)['likeCount'] + 1;
      transaction.update(commentRef, {'likeCount': newLikeCount});
    });
  }

  Future<void> addComment(Comment comment) async {
    try {
      await _firestore.collection('Comments').add({
        'ingredientRecommendationId': comment.ingredientRecommendationId,
        'commenterName': comment.commenterName,
        'commenterEmail': comment.commenterEmail,
        'likeCount': comment.likeCount ?? 0,
        'commentText': comment.commentText,
        'creationTime': comment.creationTime ?? FieldValue.serverTimestamp(),
      });
    } catch (error) {
      print('Error adding comment: $error');
      rethrow;
    }
  }
}
