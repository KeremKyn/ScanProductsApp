import 'package:flutter/material.dart';

class Comment {
  String? commentId;
  String? ingredientRecommendationId; // Buradaki hata düzeltilmiş
  String? commenterName;
  String? commenterEmail;
  int? likeCount;
  String? commentText;
  DateTime? creationTime;
  AnimationController? animationController;

  Comment(
      this.commentId,
      this.ingredientRecommendationId,
      this.commenterName,
      this.commenterEmail,
      this.likeCount,
      this.commentText,
      this.creationTime,
      );
}
