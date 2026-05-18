import 'product.dart';

class ProductAddon {
  final int addonId;
  final int productId;
  final String nameEn;
  final String nameAr;
  final String? descriptionEn;
  final double price;
  final bool isRequired;
  final int? maxSelections;

  ProductAddon({
    required this.addonId,
    required this.productId,
    required this.nameEn,
    required this.nameAr,
    this.descriptionEn,
    required this.price,
    this.isRequired = false,
    this.maxSelections,
  });

  factory ProductAddon.fromJson(Map<String, dynamic> json) {
    return ProductAddon(
      addonId: json['addon_id'] as int,
      productId: json['product_id'] as int,
      nameEn: json['name_en'] as String,
      nameAr: json['name_ar'] as String,
      descriptionEn: json['description_en'] as String?,
      price: double.parse(json['price'].toString()),
      isRequired: json['is_required'] as bool? ?? false,
      maxSelections: json['max_selections'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addon_id': addonId,
      'product_id': productId,
      'name_en': nameEn,
      'name_ar': nameAr,
      'description_en': descriptionEn,
      'price': price,
      'is_required': isRequired,
      'max_selections': maxSelections,
    };
  }
}

class ProductSize {
  final int sizeId;
  final int productId;
  final String nameEn;
  final String nameAr;
  final double priceModifier;
  final bool isDefault;

  ProductSize({
    required this.sizeId,
    required this.productId,
    required this.nameEn,
    required this.nameAr,
    required this.priceModifier,
    this.isDefault = false,
  });

  factory ProductSize.fromJson(Map<String, dynamic> json) {
    return ProductSize(
      sizeId: json['size_id'] as int,
      productId: json['product_id'] as int,
      nameEn: json['name_en'] as String,
      nameAr: json['name_ar'] as String,
      priceModifier: double.parse(json['price_modifier'].toString()),
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'size_id': sizeId,
      'product_id': productId,
      'name_en': nameEn,
      'name_ar': nameAr,
      'price_modifier': priceModifier,
      'is_default': isDefault,
    };
  }
}

class Review {
  final int reviewId;
  final int customerId;
  final int? storeId;
  final int? productId;
  final int? orderId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String? customerName;
  final String? customerImage;

  Review({
    required this.reviewId,
    required this.customerId,
    this.storeId,
    this.productId,
    this.orderId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.customerName,
    this.customerImage,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['review_id'] as int,
      customerId: json['customer_id'] as int,
      storeId: json['store_id'] as int?,
      productId: json['product_id'] as int?,
      orderId: json['order_id'] as int?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      customerName: json['customer_name'] as String?,
      customerImage: json['customer_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'review_id': reviewId,
      'customer_id': customerId,
      'store_id': storeId,
      'product_id': productId,
      'order_id': orderId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'customer_name': customerName,
      'customer_image': customerImage,
    };
  }
}

class Voucher {
  final int voucherId;
  final String code;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final double? minOrderAmount;
  final double? maxDiscountAmount;
  final DateTime validFrom;
  final DateTime validUntil;
  final int? usageLimit;
  final int usageCount;
  final bool isActive;

  Voucher({
    required this.voucherId,
    required this.code,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount,
    this.maxDiscountAmount,
    required this.validFrom,
    required this.validUntil,
    this.usageLimit,
    required this.usageCount,
    required this.isActive,
  });

  bool get isValid {
    final now = DateTime.now();
    if (!isActive) return false;
    if (now.isBefore(validFrom) || now.isAfter(validUntil)) return false;
    if (usageLimit != null && usageCount >= usageLimit!) return false;
    return true;
  }

  double calculateDiscount(double orderAmount) {
    if (!isValid) return 0;
    if (minOrderAmount != null && orderAmount < minOrderAmount!) return 0;

    double discount = 0;
    if (discountType == 'percentage') {
      discount = orderAmount * (discountValue / 100);
    } else {
      discount = discountValue;
    }

    if (maxDiscountAmount != null && discount > maxDiscountAmount!) {
      discount = maxDiscountAmount!;
    }

    return discount;
  }

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      voucherId: json['voucher_id'] as int,
      code: json['code'] as String,
      nameEn: json['name_en'] as String,
      nameAr: json['name_ar'] as String,
      descriptionEn: json['description_en'] as String,
      descriptionAr: json['description_ar'] as String,
      discountType: json['discount_type'] as String,
      discountValue: double.parse(json['discount_value'].toString()),
      minOrderAmount: json['min_order_amount'] != null
          ? double.parse(json['min_order_amount'].toString())
          : null,
      maxDiscountAmount: json['max_discount_amount'] != null
          ? double.parse(json['max_discount_amount'].toString())
          : null,
      validFrom: DateTime.parse(json['valid_from'] as String),
      validUntil: DateTime.parse(json['valid_until'] as String),
      usageLimit: json['usage_limit'] as int?,
      usageCount: json['usage_count'] as int? ?? 0,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'voucher_id': voucherId,
      'code': code,
      'name_en': nameEn,
      'name_ar': nameAr,
      'description_en': descriptionEn,
      'description_ar': descriptionAr,
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_order_amount': minOrderAmount,
      'max_discount_amount': maxDiscountAmount,
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'usage_limit': usageLimit,
      'usage_count': usageCount,
      'is_active': isActive,
    };
  }
}

class FlashDeal {
  final int dealId;
  final int productId;
  final double originalPrice;
  final double discountedPrice;
  final int? stockLimit;
  final int soldCount;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;
  final Product? product;

  FlashDeal({
    required this.dealId,
    required this.productId,
    required this.originalPrice,
    required this.discountedPrice,
    this.stockLimit,
    required this.soldCount,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    this.product,
  });

  bool get isOngoing {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(startTime) &&
        now.isBefore(endTime) &&
        (stockLimit == null || soldCount < stockLimit!);
  }

  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(endTime)) return Duration.zero;
    return endTime.difference(now);
  }

  int get discountPercentage {
    return ((1 - (discountedPrice / originalPrice)) * 100).round();
  }

  factory FlashDeal.fromJson(Map<String, dynamic> json) {
    return FlashDeal(
      dealId: json['deal_id'] as int,
      productId: json['product_id'] as int,
      originalPrice: double.parse(json['original_price'].toString()),
      discountedPrice: double.parse(json['discounted_price'].toString()),
      stockLimit: json['stock_limit'] as int?,
      soldCount: json['sold_count'] as int? ?? 0,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      isActive: json['is_active'] as bool,
      product: json['product'] != null
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deal_id': dealId,
      'product_id': productId,
      'original_price': originalPrice,
      'discounted_price': discountedPrice,
      'stock_limit': stockLimit,
      'sold_count': soldCount,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_active': isActive,
      'product': product?.toJson(),
    };
  }
}
