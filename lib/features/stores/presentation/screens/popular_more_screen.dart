import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_pallete.dart';
import '../../../../core/providers/country_currency_provider.dart';
import '../../../../core/utils/image_url_helper.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/store_entities.dart';
import '../../../models/product.dart' as models;
import '../../../cart/presentation/providers/cart_provider.dart';

class PopularMoreScreen extends ConsumerWidget {
  final List<ProductEntity> products;
  final StoreEntity store;

  const PopularMoreScreen({
    super.key,
    required this.products,
    required this.store,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = products.take(50).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.popularBadge ?? 'Popular',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      backgroundColor: const Color(0xFFF8F8F8),
      body: items.isEmpty
          ? Center(
              child: Text(
                AppLocalizations.of(context)?.noProductsAvailableAtThisTime ??
                    'No items',
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final product = items[index];
                return _PopularCard(
                  product: product,
                  store: store,
                  onAdd: () => _addToCart(context, ref, product),
                  formattedPrice: ref
                      .read(countryCurrencyProvider.notifier)
                      .formatConvertedPriceWithSymbolFromUsd(product.price),
                );
              },
            ),
    );
  }

  void _addToCart(
    BuildContext context,
    WidgetRef ref,
    ProductEntity product,
  ) {
    final productModel = models.Product(
      productId: product.productId,
      storeId: product.storeId,
      nameAr: product.nameAr,
      nameEn: product.nameEn,
      descriptionAr: product.descriptionAr,
      descriptionEn: product.descriptionEn,
      price: product.price,
      imageUrl: product.imageUrl,
      category: product.category,
      isAvailable: product.isAvailable,
      preparationTime: product.preparationTime,
    );

    final result = ref
        .read(cartProvider.notifier)
        .addItem(productModel, quantity: 1, force: false);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    if (result == AddItemResult.success || result == AddItemResult.conflict) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            '${product.nameEn} ${AppLocalizations.of(context)?.addedToCart ?? 'added to cart'}',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppPallete.primaryYellow,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (result == AddItemResult.requiresVerification) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pleaseLoginFirst, 
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

class _PopularCard extends StatelessWidget {
  final ProductEntity product;
  final StoreEntity store;
  final VoidCallback onAdd;
  final String formattedPrice;

  const _PopularCard({
    required this.product,
    required this.store,
    required this.onAdd,
    required this.formattedPrice,
  });

  @override
  Widget build(BuildContext context) {
    final brand = (product.category ?? store.name).toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: product.imageUrl != null &&
                              product.imageUrl!.isNotEmpty
                          ? Image.network(
                              ImageUrlHelper.toFullUrl(product.imageUrl) ?? '',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[200],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  brand,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product.nameEn,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  formattedPrice,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)?.addToCart ?? 'Add to cart',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppPallete.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEB3B),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
