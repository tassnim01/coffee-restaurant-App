import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_review.dart';

class ReviewRepository {
  final FirebaseFirestore _db;

  ReviewRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _db.collection('reviews');

  Stream<List<ProductReview>> watchProductReviews(String productId) {
    return _reviews.where('productId', isEqualTo: productId).snapshots().map((
      snapshot,
    ) {
      final reviews = snapshot.docs
          .map((doc) => ProductReview.fromMap(doc.id, doc.data()))
          .toList();
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }

  Future<List<ProductReview>> fetchAllReviews() async {
    final snapshot = await _reviews.get();
    final reviews = snapshot.docs
        .map((doc) => ProductReview.fromMap(doc.id, doc.data()))
        .toList();
    reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reviews;
  }

  Future<void> addReview(ProductReview review) async {
    await _reviews.add(review.toMap());
  }

  Future<void> deleteReview(String reviewId) async {
    await _reviews.doc(reviewId).delete();
  }

  Future<void> respondToReview(String reviewId, String response) async {
    await _reviews.doc(reviewId).set({
      'adminResponse': response.trim(),
    }, SetOptions(merge: true));
  }
}
