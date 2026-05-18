class Review {
  final int reviewId;
  final int orderId;
  final int rating;
  final String? comment;
  final String reviewType;
  final DateTime createdAt;

  Review({
    required this.reviewId,
    required this.orderId,
    required this.rating,
    this.comment,
    required this.reviewType,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['review_id'] as int,
      orderId: json['order_id'] as int,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      reviewType: json['review_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'order_id': orderId,
      'rating': rating,
      'comment': comment,
      'review_type': reviewType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
