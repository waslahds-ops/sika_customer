import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sika_customer/l10n/app_localizations.dart';
import '../../../../core/utils/image_url_helper.dart';
import '../../../stores/domain/entities/store_entities.dart';

class FoodCategoriesSection extends ConsumerWidget {
  final List<CategoryEntity> categories;
  final Function(CategoryEntity) onCategoryTap;
  final int? selectedCategoryId;
  final List<String>? bannerImages;
  final void Function(int index)? onBannerTap;

  const FoodCategoriesSection({
    super.key,
    required this.categories,
    required this.onCategoryTap,
    this.selectedCategoryId,
    this.bannerImages,
    this.onBannerTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Return empty if categories is empty
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isTablet = screenWidth > 600;

        final double itemSize = isTablet ? 90 : 60;
        final double spacing = isTablet ? 14 : 8;
        final double height = itemSize + 40;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 6),
              child: Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.categories,
                    style: TextStyle(
                      fontSize: isTablet ? 22 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),          
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: height,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 6),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (context, index) => SizedBox(width: spacing),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected =
                      selectedCategoryId != null && selectedCategoryId == category.categoryId;
                  return _buildCategoryCard(
                    context,
                    Localizations.localeOf(context).languageCode == 'ar'
                        ? category.nameAr
                        : category.nameEn,
                    Icons.restaurant,
                    const Color(0xFFFFEBEE),
                    () => onCategoryTap(category),
                    category.imageUrl,
                    isSelected: isSelected,
                    size: itemSize,
                  );
                },
              ),
            ),
            // Banner area: shows after categories if images provided
            if (bannerImages != null && bannerImages!.isNotEmpty) ...[
              SizedBox(height: isTablet ? 20 : 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 6),
                child: _buildBannerCarousel(context, bannerImages!, isTablet, onBannerTap),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildBannerCarousel(
    BuildContext context,
    List<String> images,
    bool isTablet,
    void Function(int index)? onTap,
  ) {
    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: isTablet ? 140 : 120,
      child: PageView.builder(
        itemCount: images.length,
        controller: PageController(viewportFraction: 0.92),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final url = images[index];
          return GestureDetector(
            onTap: () => onTap?.call(index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  ImageUrlHelper.toFullUrl(url) ?? url,
                  width: double.infinity,
                  height: isTablet ? 140 : 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(child: Icon(Icons.image, size: 36, color: Colors.grey)),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String name,
    IconData icon,
    Color backgroundColor,
    VoidCallback onTap,
    String? imageUrl,
    {bool isSelected = false, double size = 60}
  ) {
    final lowerName = name.toLowerCase();
    lowerName.contains('booking');
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: size + 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              CustomPaint(
                foregroundPainter: GradientBorderPainter(
                  borderRadius: 14,
                ),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            ImageUrlHelper.toFullUrl(imageUrl) ?? imageUrl,
                            width: size,
                            height: size,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(icon, size: size * 0.5, color: Colors.black54);
                            },
                          ),
                        )
                      : Icon(icon, size: size * 0.5, color: Colors.black54),
                ),
              )
            else
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          ImageUrlHelper.toFullUrl(imageUrl) ?? imageUrl,
                          width: size,
                          height: size,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(icon, size: size * 0.5, color: Colors.black54);
                          },
                        ),
                      )
                    : Icon(icon, size: size * 0.5, color: Colors.black54),
              ),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: size > 60 ? 13 : 11,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

}

class GradientBorderPainter extends CustomPainter {
  final double borderRadius;
  final double borderWidth = 2.0;

  GradientBorderPainter({required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final halfStroke = borderWidth / 2;
    final rect = Rect.fromLTWH(
      halfStroke,
      halfStroke,
      size.width - borderWidth,
      size.height - borderWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    
    final gradient = LinearGradient(
      colors: [
        const Color(0xFF02B251),
        const Color(0xFFFBEF53),
      ],
      stops: const [0.0, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(GradientBorderPainter oldDelegate) {
    return true;
  }
}
