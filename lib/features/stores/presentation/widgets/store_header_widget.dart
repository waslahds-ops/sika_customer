import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/image_url_helper.dart';
import '../../../../core/providers/country_currency_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/store_entities.dart';

class StoreHeaderWidget extends ConsumerWidget {
  final StoreEntity store;
  final VoidCallback? onFilterTap;
  final BoxConstraints? constraints;

  const StoreHeaderWidget({
    super.key,
    required this.store,
    this.onFilterTap,
    this.constraints,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSmallScreen = (constraints?.maxWidth ?? 360) < 360;
    final containerPadding = isSmallScreen ? 12.0 : 16.0;
    final logoSize = isSmallScreen ? 36.0 : 40.0;

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Store Logo and Name in Row
          Row(
            children: [
              Container(
                width: logoSize,
                height: logoSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: store.logoUrl != null && store.logoUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.network(
                          ImageUrlHelper.toFullUrl(store.logoUrl) ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                store.name[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          store.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (store.description != null)
                      Text(
                        store.description!,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey[500]),
          SizedBox(height: isSmallScreen ? 10 : 16),
          // Pre-order and Rating section
          Row(
            children: [
              // Pre-order section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.deliveryTime,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDeliveryTime(store.estimatedDeliveryTime),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Container(
                width: 1,
                height: 30,
                color: Colors.grey[300],
              ),
              // Rating section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.ratingAndReviews,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: isSmallScreen ? 14 : 16,
                          color: const Color(0xFFFFB800),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            store.ratingAvg?.toStringAsFixed(1) ?? '4.9',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            store.ordersCount != null 
                                ? _formatOrderCount(store.ordersCount!)
                                : '(0)',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 9 : 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatOrderCount(int count) {
    if (count >= 1000000) {
      return '(${(count / 1000000).toStringAsFixed(1)}M+)';
    } else if (count >= 1000) {
      return '(${(count / 1000).toStringAsFixed(1)}k+)';
    } else {
      return '($count)';
    }
  }

  String _formatDeliveryTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return '15-30 mins';
    }
    if (raw.contains('min')) {
      return raw;
    }
    return '$raw mins';
  }
}
