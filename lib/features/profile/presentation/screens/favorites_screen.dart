import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sika_customer/core/widgets/app_loader.dart';
import '../../../../core/utils/image_url_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Load stores on init
    Future.microtask(() => ref.read(storesProvider.notifier).loadStores());
  }

  @override
  Widget build(BuildContext context) {
    final storesState = ref.watch(storesProvider);
    final favoriteStoreIds = ref.watch(favoritesProvider);
    final favoriteStores = storesState.stores
        .where((store) => favoriteStoreIds.contains(store.storeId))
        .toList();

    // Also consider favorites that may be products. favoritesProvider stores int ids
    // which can refer to either a storeId or a productId. We'll detect products
    // by checking the stores provider's product list.
    final allProducts = storesState.products;
    final favoriteProducts = allProducts
        .where((product) => favoriteStoreIds.contains(product.productId))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.favorites_title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: storesState.isLoading
          ? const Center(child: AppLoader())
          : storesState.errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(storesState.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(storesProvider.notifier).loadStores(),
                    child: Text(AppLocalizations.of(context)!.retry),
                  ),
                ],
              ),
            )
          : (favoriteStores.isEmpty && favoriteProducts.isEmpty)
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (favoriteProducts.isNotEmpty) ...[
                  Text(
                    AppLocalizations.of(context)!.favoriteProducts,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...favoriteProducts.map((product) {
                    final matchingStores = storesState.stores
                        .where((s) => s.storeId == product.storeId)
                        .toList();
                    final store = matchingStores.isNotEmpty
                        ? matchingStores.first
                        : null;
                    return Container(
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
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Navigate to product details with extra product
                            context.push(
                              '/product/${product.productId}',
                              extra: product,
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child:
                                      product.imageUrl != null &&
                                          product.imageUrl!.isNotEmpty
                                      ? Image.network(
                                          ImageUrlHelper.toFullUrl(
                                                product.imageUrl,
                                              ) ??
                                              '',
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: const Color(
                                                    0xFFF5F5F5,
                                                  ),
                                                  child: const Icon(
                                                    Icons.fastfood,
                                                    size: 40,
                                                    color: Color(0xFFFF6B35),
                                                  ),
                                                );
                                              },
                                        )
                                      : Container(
                                          width: 80,
                                          height: 80,
                                          color: const Color(0xFFF5F5F5),
                                          child: const Icon(
                                            Icons.fastfood,
                                            size: 40,
                                            color: Color(0xFFFF6B35),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.nameEn.isNotEmpty
                                            ? product.nameEn
                                            : product.nameAr,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        store != null ? store.name : '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${product.price.toStringAsFixed(0)} LBP',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.favorite,
                                    color: Color(0xFFFF6B35),
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(favoritesProvider.notifier)
                                        .removeFavorite(product.productId);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${product.nameEn.isNotEmpty ? product.nameEn : product.nameAr} ${AppLocalizations.of(context)!.removed_from_favorites}',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],
                if (favoriteStores.isNotEmpty) ...[
                  Text(
                    AppLocalizations.of(context)!.favoriteStores,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                ],
                ...favoriteStores.map((store) {
                  return Container(
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Use route that matches router config
                          context
                              .push(
                                '/store-details/${store.storeId}',
                                extra: store,
                              )
                              .then((_) {
                                // Refresh stores list when returning from details
                                ref.read(storesProvider.notifier).loadStores();
                              });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Store Banner Image
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child:
                                  store.logoUrl != null &&
                                      store.logoUrl!.isNotEmpty
                                  ? Image.network(
                                      ImageUrlHelper.toFullUrl(store.logoUrl) ??
                                          '',
                                      height: 160,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              height: 160,
                                              color: const Color(0xFFF5F5F5),
                                              child: const Icon(
                                                Icons.restaurant,
                                                size: 50,
                                                color: Color(0xFFFF6B35),
                                              ),
                                            );
                                          },
                                    )
                                  : Container(
                                      height: 160,
                                      color: const Color(0xFFF5F5F5),
                                      child: const Icon(
                                        Icons.restaurant,
                                        size: 50,
                                        color: Color(0xFFFF6B35),
                                      ),
                                    ),
                            ),
                            // Store Info
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          store.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          ref
                                              .read(favoritesProvider.notifier)
                                              .removeFavorite(store.storeId);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '${store.name} ${AppLocalizations.of(context)!.removed_from_favorites}',
                                              ),
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Icon(
                                          Icons.favorite,
                                          color: Color(0xFFFF6B35),
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (store.description != null &&
                                      store.description!.isNotEmpty)
                                    Text(
                                      store.description!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Color(0xFFFFA726),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        store.ratingAvg?.toStringAsFixed(1) ??
                                            AppLocalizations.of(context)!.notAvailable,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        Icons.access_time,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        store.estimatedDeliveryTime ?? AppLocalizations.of(context)!.notAvailable,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noFavoritesYet,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.startAddingYourFavoriteRestaurants,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
