import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../injection_container.dart';

/// Model for voucher product
class VoucherProduct {
  final int productId;
  final String nameEn;
  final String nameAr;
  final String imageUrl;
  final String originalPrice;
  final String finalPrice;
  final String discountAmount;
  final String discountPercentage;
  final int estimatedDeliveryTime;
  final bool freeDelivery;
  final String deliveryFee;
  final int storeId;
  final String storeName;
  final String voucherCode;
  final String voucherNameEn;
  final String voucherNameAr;
  final bool isAvailable;

  VoucherProduct({
    required this.productId,
    required this.nameEn,
    required this.nameAr,
    required this.imageUrl,
    required this.originalPrice,
    required this.finalPrice,
    required this.discountAmount,
    required this.discountPercentage,
    required this.estimatedDeliveryTime,
    required this.freeDelivery,
    required this.deliveryFee,
    required this.storeId,
    required this.storeName,
    required this.voucherCode,
    required this.voucherNameEn,
    required this.voucherNameAr,
    required this.isAvailable,
  });

  factory VoucherProduct.fromJson(Map<String, dynamic> json) {
    return VoucherProduct(
      productId: json['product_id'] ?? 0,
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      imageUrl: json['image_url'] ?? '',
      originalPrice: json['original_price']?.toString() ?? '0',
      finalPrice: json['final_price']?.toString() ?? '0',
      discountAmount: json['discount_amount']?.toString() ?? '0',
      discountPercentage: json['discount_percentage']?.toString() ?? '0',
      estimatedDeliveryTime: json['estimated_delivery_time'] ?? 0,
      freeDelivery: json['free_delivery'] ?? false,
      deliveryFee: json['delivery_fee']?.toString() ?? '0',
      storeId: json['store_id'] ?? 0,
      storeName: json['store_name'] ?? '',
      voucherCode: json['voucher_code'] ?? '',
      voucherNameEn: json['voucher_name_en'] ?? '',
      voucherNameAr: json['voucher_name_ar'] ?? '',
      isAvailable: json['is_available'] ?? true,
    );
  }
}

/// Model for available voucher
class AvailableVoucher {
  final int id;
  final String code;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final String discountType;
  final String discountValue;
  final String maxDiscountAmount;
  final String minOrderAmount;
  final String imageUrl;
  final String validFrom;
  final String validUntil;
  final int applicableProductsCount;
  final int usageRemaining;
  final bool showAsPopup;

  AvailableVoucher({
    required this.id,
    required this.code,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.discountType,
    required this.discountValue,
    required this.maxDiscountAmount,
    required this.minOrderAmount,
    required this.imageUrl,
    required this.validFrom,
    required this.validUntil,
    required this.applicableProductsCount,
    required this.usageRemaining,
    required this.showAsPopup,
  });

  factory AvailableVoucher.fromJson(Map<String, dynamic> json) {
    return AvailableVoucher(
      id: _toInt(json['id']),
      code: json['code'] ?? '',
      nameEn: json['name_en'] ?? '',
      nameAr: json['name_ar'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      descriptionAr: json['description_ar'] ?? '',
      discountType: json['discount_type'] ?? '',
      discountValue: json['discount_value']?.toString() ?? '0',
      maxDiscountAmount: json['max_discount_amount']?.toString() ?? '0',
      minOrderAmount: json['min_order_amount']?.toString() ?? '0',
      imageUrl: json['image_url'] ?? '',
      validFrom: json['valid_from'] ?? '',
      validUntil: json['valid_until'] ?? '',
      applicableProductsCount: _toInt(json['applicable_products_count']),
      usageRemaining: _toInt(json['usage_remaining']),
      showAsPopup: json['show_as_popup'] ?? false,
    );
  }
}

/// Provider to fetch available vouchers
final availableVouchersProvider = FutureProvider<List<AvailableVoucher>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  try {
    final response = await apiService.get('/public/products/voucher/available');
    print('📡 [VOUCHERS API] Raw response: $response');
    
    // Handle both direct array response and paginated response
    List<dynamic> data = [];
    if (response is List) {
      data = response;
    } else if (response is Map && response.containsKey('data')) {
      final dataValue = response['data'];
      data = dataValue is List ? dataValue : [];
    }
    
    print('🎟️ [VOUCHERS] Parsed ${data.length} available vouchers');
    return data.map((v) => AvailableVoucher.fromJson(v as Map<String, dynamic>)).toList();
  } catch (e) {
    print('❌ Error fetching vouchers: $e');
    return [];
  }
});

/// Provider to fetch discounted products for a specific voucher
final voucherProductsProvider = FutureProvider.family<List<VoucherProduct>, int>(
  (ref, voucherId) async {
    final apiService = ref.read(apiServiceProvider);
    try {
      print('🔍 [VOUCHER PRODUCTS] Fetching for voucher $voucherId...');
      final response = await apiService.get(
        '/public/products/voucher/discounted',
        queryParameters: {
          'voucher_id': voucherId,
          'per_page': 10,
        },
      );
      print('📡 [VOUCHER PRODUCTS API] Raw response for voucher $voucherId: $response');
      
      // Handle both direct array response and paginated response
      List<dynamic> data = [];
      if (response is List) {
        data = response;
      } else if (response is Map) {
        // Check for nested pagination: data.data structure
        if (response.containsKey('data') && response['data'] is Map) {
          final paginatedData = response['data'];
          if (paginatedData.containsKey('data') && paginatedData['data'] is List) {
            data = paginatedData['data'];
          }
        } else if (response.containsKey('data') && response['data'] is List) {
          data = response['data'];
        }
      }
      
      print('🛍️ [VOUCHER PRODUCTS] Parsed ${data.length} discounted products for voucher $voucherId');
      return data.map((p) => VoucherProduct.fromJson(p as Map<String, dynamic>)).toList();
    } catch (e) {
      print('❌ Error fetching voucher products: $e');
      return [];
    }
  },
);

/// Helper function to safely convert String or int to int
int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// Provider to get the first available voucher's products
final firstVoucherProductsProvider = FutureProvider<List<VoucherProduct>>((ref) async {
  final vouchers = await ref.watch(availableVouchersProvider.future);
  
  if (vouchers.isEmpty) {
    return [];
  }

  // Get products for the first voucher
  return ref.watch(voucherProductsProvider(vouchers.first.id).future);
});
