import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import '../data/review_repository.dart';
import '../models/product_review.dart';

class ReviewsProvider extends ChangeNotifier {
  final ReviewRepository _repository;
  final Map<String, StreamSubscription<List<ProductReview>>> _subscriptions =
      {};
  final Map<String, List<ProductReview>> _productReviews = {};
  List<ProductReview> allReviews = [];
  bool isLoadingAll = false;
  String? error;
  bool _disposed = false;

  ReviewsProvider(this._repository);

  void _notifySafe() {
    if (_disposed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) notifyListeners();
    });
  }

  List<ProductReview> reviewsFor(String productId) =>
      List.unmodifiable(_productReviews[productId] ?? const []);

  void watchProduct(String productId) {
    if (_subscriptions.containsKey(productId)) return;
    _subscriptions[productId] = _repository
        .watchProductReviews(productId)
        .listen(
          (reviews) {
            _productReviews[productId] = reviews;
            notifyListeners();
          },
          onError: (_) {
            error = 'Impossible de charger les avis.';
            notifyListeners();
          },
        );
  }

  Future<bool> addReview({
    required String productId,
    required String userId,
    required String userName,
    required int rating,
    required String comment,
    String photoUrl = '',
  }) async {
    try {
      await _repository.addReview(
        ProductReview(
          id: '',
          productId: productId,
          userId: userId,
          userName: userName,
          rating: rating,
          comment: comment.trim(),
          photoUrl: photoUrl,
          createdAt: DateTime.now(),
        ),
      );
      error = null;
      return true;
    } catch (_) {
      error = 'Impossible d’ajouter votre avis.';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadAllReviews() async {
    isLoadingAll = true;
    error = null;
    notifyListeners();
    try {
      allReviews = await _repository.fetchAllReviews();
    } catch (_) {
      error = 'Impossible de charger les avis.';
    } finally {
      isLoadingAll = false;
      notifyListeners();
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      await _repository.deleteReview(reviewId);
      allReviews.removeWhere((review) => review.id == reviewId);
      for (final entry in _productReviews.entries) {
        entry.value.removeWhere((review) => review.id == reviewId);
      }
      error = null;
      notifyListeners();
      return true;
    } catch (_) {
      error = 'Impossible de supprimer cet avis.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> respondToReview(String reviewId, String response) async {
    try {
      await _repository.respondToReview(reviewId, response);
      for (var i = 0; i < allReviews.length; i++) {
        if (allReviews[i].id == reviewId) {
          allReviews[i] = allReviews[i].copyWith(
            adminResponse: response.trim(),
          );
          break;
        }
      }
      for (final entry in _productReviews.entries) {
        for (var i = 0; i < entry.value.length; i++) {
          if (entry.value[i].id == reviewId) {
            entry.value[i] = entry.value[i].copyWith(
              adminResponse: response.trim(),
            );
          }
        }
      }
      error = null;
      _notifySafe();
      return true;
    } catch (e) {
      error = e is FirebaseException
          ? 'Impossible d’envoyer la réponse (${e.code}).'
          : 'Impossible d’envoyer la réponse.';
      _notifySafe();
      return false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    super.dispose();
  }
}
