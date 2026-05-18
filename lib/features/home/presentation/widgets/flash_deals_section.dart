import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_pallete.dart';
import '../../../../core/utils/image_url_helper.dart';
import '../../../../injection_container.dart';
import '../../../models/keeta_features.dart';
import '../../../models/product.dart';
import '../../../stores/presentation/providers/stores_provider.dart';
import '../../../stores/domain/entities/store_entities.dart';

class FlashDealsSection extends ConsumerStatefulWidget {
  final int? categoryId;

  const FlashDealsSection({
    super.key,
    this.categoryId,
  });

  @override
  ConsumerState<FlashDealsSection> createState() => _FlashDealsSectionState();
}

class _FlashDealsSectionState extends ConsumerState<FlashDealsSection> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update every second for countdown
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch flash deals provider and stores provider for category filtering
    final flashDealsAsync = ref.watch(flashDealsProvider);
    final storesState = ref.watch(storesProvider);

    // Filter flash deals: by selected category if provided
    final filteredDealsAsync = flashDealsAsync.whenData((deals) {
      if (widget.categoryId == null || widget.categoryId == 0) {
        return deals;
      }
      // Filter deals by matching the store's category
      return deals.where((deal) {
        final store = storesState.stores.firstWhere(
          (s) => s.storeId == deal.storeId,
          orElse: () => StoreEntity(
            storeId: -1,
            merchantId: -1,
            categoryId: -1,
            name: '',
            deliveryFee: 0,
            minOrderAmount: 0,
            isOpen: false,
            isActive: false,
          ),
        );
        return store.categoryId == widget.categoryId;
      }).toList();
    });

    return filteredDealsAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 3,
            itemBuilder: (context, index) => Container(
              width: 180,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
              ),
            ),
          ),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
      data: (flashDeals) {
        // Hide section if no flash deals available
        if (flashDeals.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.flash_on,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'FLASH DEALS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: flashDeals.length,
                itemBuilder: (context, index) {
                  return _FlashDealCard(deal: flashDeals[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FlashDealCard extends StatelessWidget {
  final ProductEntity deal;

  const _FlashDealCard({required this.deal});

  @override
  Widget build(BuildContext context) {
    // Create a FlashDeal wrapper for display purposes
    final now = DateTime.now();
    final flashDeal = FlashDeal(
      dealId: deal.productId,
      productId: deal.productId,
      originalPrice: deal.price,
      discountedPrice:
          deal.price * 0.85, // Default 15% discount if not provided
      stockLimit: 50,
      soldCount: 10,
      startTime: now.subtract(const Duration(hours: 1)),
      endTime: now.add(const Duration(hours: 2)),
      isActive: true,
      product: Product(
        productId: deal.productId,
        storeId: deal.storeId,
        nameEn: deal.nameEn,
        nameAr: deal.nameAr,
        descriptionEn: deal.descriptionEn,
        descriptionAr: deal.descriptionAr,
        price: deal.price,
        imageUrl: deal.imageUrl ?? '',
        category: deal.category ?? 'General',
        isAvailable: deal.isAvailable,
        preparationTime: deal.preparationTime ?? '10-15 min',
      ),
    );

    final timeRemaining = flashDeal.timeRemaining;
    final hours = timeRemaining.inHours;
    final minutes = timeRemaining.inMinutes.remainder(60);
    final seconds = timeRemaining.inSeconds.remainder(60);

    final stockPercentage = flashDeal.stockLimit != null
        ? (flashDeal.soldCount / flashDeal.stockLimit! * 100).clamp(0, 100)
        : 0.0;

    return GestureDetector(
      onTap: () {
        // Navigate to product details
      context.push(
        '/product/${deal.productId}',
        extra: deal,
      );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with Discount Badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      ImageUrlHelper.toFullUrl(deal.imageUrl) ?? '',
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 110,
                        color: Colors.grey[200],
                        child: const Icon(Icons.restaurant, size: 40),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '-${flashDeal.discountPercentage}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Product Info
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deal.nameEn,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          'LBP ${flashDeal.discountedPrice.toInt()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.primaryTeal,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'LBP ${deal.price.toInt()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Countdown Timer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (flashDeal.stockLimit != null) ...[
                      const SizedBox(height: 4),
                      // Stock Progress
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Sold: ${flashDeal.soldCount}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '${flashDeal.stockLimit! - flashDeal.soldCount} left',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppPallete.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: stockPercentage / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                stockPercentage > 70
                                    ? AppPallete.error
                                    : AppPallete.primaryTeal,
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
