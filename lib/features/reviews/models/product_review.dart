import 'package:cloud_firestore/cloud_firestore.dart';

class ProductReview {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final int rating;
  final String comment;
  final String photoUrl;
  final String adminResponse;
  final DateTime createdAt;

  const ProductReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    this.photoUrl = '',
    this.adminResponse = '',
    required this.createdAt,
  });

  ProductReview copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    int? rating,
    String? comment,
    String? photoUrl,
    String? adminResponse,
    DateTime? createdAt,
  }) => ProductReview(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    userId: userId ?? this.userId,
    userName: userName ?? this.userName,
    rating: rating ?? this.rating,
    comment: comment ?? this.comment,
    photoUrl: photoUrl ?? this.photoUrl,
    adminResponse: adminResponse ?? this.adminResponse,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'userId': userId,
    'userName': userName,
    'rating': rating,
    'comment': comment,
    'photoUrl': photoUrl,
    'adminResponse': adminResponse,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory ProductReview.fromMap(String id, Map<String, dynamic> map) =>
      ProductReview(
        id: id,
        productId: map['productId'] as String? ?? '',
        userId: map['userId'] as String? ?? '',
        userName: map['userName'] as String? ?? 'Client',
        rating: (map['rating'] as num?)?.toInt() ?? 0,
        comment: map['comment'] as String? ?? '',
        photoUrl: map['photoUrl'] as String? ?? '',
        adminResponse: map['adminResponse'] as String? ?? '',
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
