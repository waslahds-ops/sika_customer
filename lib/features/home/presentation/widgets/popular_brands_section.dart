import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:sika_customer/core/widgets/app_loader.dart';
import 'package:sika_customer/l10n/app_localizations.dart';
import '../../../../core/utils/image_url_helper.dart';
import '../../../stores/domain/entities/store_entities.dart';
import '../../../stores/presentation/providers/stores_provider.dart';

class PopularBrandsSection extends ConsumerWidget {
  final Function(StoreEntity)? onStoreTap;
  final CategoryEntity? selectedCategory;

  const PopularBrandsSection({
    super.key,
    this.onStoreTap,
    this.selectedCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final popularStoresAsync = ref.watch(popularStoresProvider);
    
    return popularStoresAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.popularBrands,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: GoogleFonts.lalezar().fontFamily,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
          ],
        ),
      ),
      error: (err, st) {
        print('❌ Popular Brands Error: $err');
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.popularBrands,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: GoogleFonts.lalezar().fontFamily,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  AppLocalizations.of(context)!.noBrandsAvailable,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        );
      },
      data: (stores) {
        // Popular brands should show regardless of currently selected category
        print('📊 Popular Brands: Displaying ${stores.length} popular stores');
        
        if (stores.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.popularBrands,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: GoogleFonts.lalezar().fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;

                  const fixedItemWidth = 74.0;
                  const fixedItemHeight = 96.0;
                  const fixedSpacing = 2.0;

                  math.max(1, ((maxWidth + fixedSpacing) ~/ (fixedItemWidth + fixedSpacing)));

                  // Split stores evenly between two rows
                  final firstRow = <StoreEntity>[];
                  final secondRow = <StoreEntity>[];

                  for (int i = 0; i < stores.length; i++) {
                    if (i % 2 == 0) {
                      firstRow.add(stores[i]);
                    } else {
                      secondRow.add(stores[i]);
                    }
                  }

                  Widget buildRowScroll(List<StoreEntity> items) {
                    return Row(
                      children: List.generate(items.length, (i) {
                        final store = items[i];
                        return Padding(
                          padding: EdgeInsets.only(right: i == items.length - 1 ? 0 : fixedSpacing),
                          child: SizedBox(
                            width: fixedItemWidth,
                            height: fixedItemHeight,
                            child: _buildBrandItem(
                              context,
                              store.name,
                              store.logoUrl ?? '',
                              () {
                                onStoreTap?.call(store);
                                context.push('/store-details/${store.storeId}', extra: store);
                              },
                            ),
                          ),
                        );
                      }),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildRowScroll(firstRow),
                        if (secondRow.isNotEmpty) const SizedBox(height: 12),
                        if (secondRow.isNotEmpty) buildRowScroll(secondRow),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBrandItem(
    BuildContext context,
    String name,
    String imageUrl,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 60x60 image box
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          ImageUrlHelper.toFullUrl(imageUrl) ?? imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: AppButtonLoader(size: 20));
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(Icons.store, size: 24, color: Colors.grey[400]),
                            );
                          },
                        )
                      : Center(
                          child: Icon(Icons.store, size: 24, color: Colors.grey[400]),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              // Brand name under the image
              Text(
                name,
                style: TextStyle(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
