import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_pallete.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../models/keeta_features.dart';

class ReviewsBottomSheet extends ConsumerStatefulWidget {
  final int storeId;
  final int? productId;
  final double averageRating;
  final int totalReviews;

  const ReviewsBottomSheet({
    super.key,
    required this.storeId,
    this.productId,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  ConsumerState<ReviewsBottomSheet> createState() => _ReviewsBottomSheetState();
}

class _ReviewsBottomSheetState extends ConsumerState<ReviewsBottomSheet> {
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    // Mock reviews - replace with actual API call
    setState(() {
      final storeName = widget.storeId != null
          ? 'Store #${widget.storeId}'
          : 'This store';
      _reviews = [
        Review(
          reviewId: 1,
          customerId: 101,
          customerName: 'John Smith',
          customerImage: null,
          storeId: widget.storeId,
          productId: widget.productId,
          rating: 5,
          comment:
              'Amazing food! Fast delivery and everything was hot and fresh. Highly recommend!',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Review(
          reviewId: 2,
          customerId: 102,
          customerName: 'Sarah Johnson',
          customerImage: null,
          storeId: widget.storeId,
          productId: widget.productId,
          rating: 4,
          comment: 'Good quality and taste. Packaging could be better.',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Review(
          reviewId: 3,
          customerId: 103,
          customerName: 'Ahmed Ali',
          customerImage: null,
          storeId: widget.storeId,
          productId: widget.productId,
          rating: 5,
          comment: 'طعم رائع وخدمة ممتازة!',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        Review(
          reviewId: 4,
          customerId: 104,
          customerName: 'Emily Davis',
          customerImage: null,
          storeId: widget.storeId,
          productId: widget.productId,
          rating: 3,
          comment:
              'Average experience. Food was okay but delivery took longer than expected.',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
        Review(
          reviewId: 5,
          customerId: 105,
          customerName: 'Michael Brown',
          customerImage: null,
          storeId: widget.storeId,
          productId: widget.productId,
          rating: 5,
          comment: 'Best pizza in town! Always consistent quality.',
          createdAt: DateTime.now().subtract(const Duration(days: 14)),
        ),
        Review(
          reviewId: 6,
          customerId: 106,
          customerName: 'Lea Haddad',
          customerImage: null,
          storeId: widget.storeId,
          productId: widget.productId,
          rating: 4,
          comment: 'Loved the fresh ingredients from $storeName.',
          createdAt: DateTime.now().subtract(const Duration(days: 18)),
        ),
        Review(
          reviewId: 7,
          customerId: 107,
          customerName: 'Carlos Diaz',
          customerImage: null,
          storeId: widget.storeId,
          productId: widget.productId,
          rating: 5,
          comment: '$storeName delivered in under 20 mins. Great service!',
          createdAt: DateTime.now().subtract(const Duration(days: 21)),
        ),
        Review(
          reviewId: 8,
          customerId: 108,
          customerName: 'Nour Rahim',
          customerImage: null,
          storeId: widget.storeId,
          productId: widget.productId,
          rating: 3,
          comment: 'Portions could be bigger, but taste was good.',
          createdAt: DateTime.now().subtract(const Duration(days: 24)),
        ),
      ];
    });
  }

  Map<int, int> _getRatingDistribution() {
    final distribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in _reviews) {
      distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
    }
    return distribution;
  }

  void _showWriteReviewDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: WriteReviewSheet(
          storeId: widget.storeId,
          productId: widget.productId,
          onReviewSubmitted: (review) {
            setState(() {
              _reviews.insert(0, review);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final distribution = _getRatingDistribution();

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Reviews & Ratings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Rating Summary
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                // Average Rating
                Column(
                  children: [
                    Text(
                      widget.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < widget.averageRating.floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 20,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.totalReviews} reviews',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                // Rating Distribution
                Expanded(
                  child: Column(
                    children: [5, 4, 3, 2, 1].map((rating) {
                      final count = distribution[rating] ?? 0;
                      final percentage = _reviews.isEmpty
                          ? 0.0
                          : count / _reviews.length;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text(
                              '$rating',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percentage,
                                  backgroundColor: Colors.grey[200],
                                  color: AppPallete.primaryTeal,
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Write Review Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showWriteReviewDialog,
                icon: const Icon(Icons.rate_review, color: Colors.white),
                label: const Text(
                  'Write a Review',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPallete.primaryTeal,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          // Reviews List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _reviews.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                return _ReviewCard(review: _reviews[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: AppPallete.primaryTeal,
              child: Text(
                (review.customerName ?? 'U')[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        review.customerName ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified, size: 10, color: Colors.green),
                            SizedBox(width: 2),
                            Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < review.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 14,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getTimeAgo(review.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (review.comment != null) ...[
          const SizedBox(height: 8),
          Text(review.comment!, style: const TextStyle(fontSize: 14)),
        ],
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class WriteReviewSheet extends ConsumerStatefulWidget {
  final int storeId;
  final int? productId;
  final Function(Review) onReviewSubmitted;

  const WriteReviewSheet({
    super.key,
    required this.storeId,
    this.productId,
    required this.onReviewSubmitted,
  });

  @override
  ConsumerState<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends ConsumerState<WriteReviewSheet> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.selectRating)),
      );
      return;
    }

    final review = Review(
      reviewId: DateTime.now().millisecondsSinceEpoch,
      customerId: 999, // Replace with actual user ID
      customerName: 'You', // Replace with actual user name
      customerImage: null,
      storeId: widget.storeId,
      productId: widget.productId,
      rating: _rating,
      comment: _commentController.text.isNotEmpty
          ? _commentController.text
          : null,
      createdAt: DateTime.now(),
    );

    widget.onReviewSubmitted(review);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.submitReview)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Write a Review',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text(
            'How would you rate your experience?',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return GestureDetector(
                onTap: () => setState(() => _rating = starIndex),
                child: Icon(
                  starIndex <= _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 48,
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _commentController,
            textDirection: TextDirection.ltr,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your experience... (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryTeal,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Submit Review',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
