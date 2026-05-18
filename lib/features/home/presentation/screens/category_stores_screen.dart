import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sika_customer/core/widgets/app_loader.dart';
import 'package:sika_customer/l10n/app_localizations.dart';
import '../../../../core/constants/app_pallete.dart';
import '../../../../core/providers/country_currency_provider.dart';
import '../../../../core/utils/image_url_helper.dart';
import '../../../../injection_container.dart';
import '../../../stores/domain/entities/store_entities.dart';

class CategoryStoresScreen extends ConsumerStatefulWidget {
  final CategoryEntity category;

  const CategoryStoresScreen({super.key, required this.category});

  @override
  ConsumerState<CategoryStoresScreen> createState() =>
      _CategoryStoresScreenState();
}

class _CategoryStoresScreenState extends ConsumerState<CategoryStoresScreen> {
  @override
  void initState() {
    super.initState();
    // Load stores when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storesProvider.notifier).loadStores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final storesState = ref.watch(storesProvider);
    final isLoading = storesState.isLoading;
    final allStores = storesState.stores;
    final allCategories = storesState.categories;

    // Filter stores by category - match by both categoryId and category name
    final categoryStores = allStores.where((store) {
      // First try to match by categoryId
      if (store.categoryId == widget.category.categoryId) {
        return true;
      }

      // If no match by ID, try to match by category name
      // Find the store's category and compare names
      final CategoryEntity? storeCategory = allCategories
          .cast<CategoryEntity?>()
          .firstWhere(
            (cat) => cat?.categoryId == store.categoryId,
            orElse: () => null,
          );

      // If store category not found, don't match
      if (storeCategory == null) {
        return false;
      }

      // Match by English or Arabic name (case-insensitive)
      return storeCategory.nameEn.toLowerCase() ==
              widget.category.nameEn.toLowerCase() ||
          storeCategory.nameAr.toLowerCase() ==
              widget.category.nameAr.toLowerCase();
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppPallete.primaryYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category.nameEn,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {
              // Navigate to search screen
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: AppLoader())
          : categoryStores.isEmpty
          ? _buildEmptyState()
          : _buildStoresList(categoryStores),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '${AppLocalizations.of(context)!.noStoresFound} ${widget.category.nameEn}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new stores',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildStoresList(List<StoreEntity> stores) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return _buildStoreCard(store);
      },
    );
  }

  Widget _buildStoreCard(StoreEntity store) {
    return GestureDetector(
      onTap: () {
        // Navigate to store details using GoRouter
        ref.read(storesProvider.notifier).selectStore(store);
        context.push('/store-details/${store.storeId}', extra: store).then((_) {
          // Refresh stores list when returning from details
          ref.read(storesProvider.notifier).loadStores();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: store.logoUrl != null && store.logoUrl!.isNotEmpty
                  ? Image.network(
                      ImageUrlHelper.toFullUrl(store.logoUrl) ?? '',
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 160,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.store,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 160,
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.store,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                    ),
            ),

            // Store Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          store.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: store.isOpen
                              ? Colors.green[50]
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          store.isOpen ? 'Open' : 'Closed',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: store.isOpen ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Description
                  if (store.description != null &&
                      store.description!.isNotEmpty)
                    Text(
                      store.description!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 12),

                  // Store Details Row
                  Row(
                    children: [
                      // Rating
                      if (store.ratingAvg != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              store.ratingAvg!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppPallete.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),

                      // Delivery Fee
                      Row(
                        children: [
                          const Icon(
                            Icons.delivery_dining,
                            size: 16,
                            color: AppPallete.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            store.deliveryFee == 0
                                ? 'Free'
                                : ref
                                      .read(countryCurrencyProvider.notifier)
                                      .formatConvertedPriceWithSymbolFromUsd(
                                        store.deliveryFee,
                                      ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppPallete.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),

                      // Delivery Time
                      if (store.estimatedDeliveryTime != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppPallete.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              store.estimatedDeliveryTime!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppPallete.textSecondary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Minimum Order
                  Text(
                    'Min. order: ${ref.read(countryCurrencyProvider.notifier).formatConvertedPriceWithSymbolFromUsd(store.minOrderAmount)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
