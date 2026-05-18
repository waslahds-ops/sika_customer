class PromoCode {
  final int promoId;
  final String code;
  final String discountType;
  final double discountValue;
  final double? minOrderAmount;
  final double? maxDiscount;
  final int usageLimit;
  final int usedCount;
  final DateTime startsAt;
  final DateTime expiresAt;
  final bool isActive;

  PromoCode({
    required this.promoId,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount,
    this.maxDiscount,
    required this.usageLimit,
    required this.usedCount,
    required this.startsAt,
    required this.expiresAt,
    required this.isActive,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      promoId: json['promo_id'] as int,
      code: json['code'] as String,
      discountType: json['discount_type'] as String,
      discountValue: double.parse(json['discount_value'].toString()),
      minOrderAmount: json['min_order_amount'] != null
          ? double.parse(json['min_order_amount'].toString())
          : null,
      maxDiscount: json['max_discount'] != null
          ? double.parse(json['max_discount'].toString())
          : null,
      usageLimit: json['usage_limit'] as int,
      usedCount: json['used_count'] as int,
      startsAt: DateTime.parse(json['starts_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'promo_id': promoId,
      'code': code,
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_order_amount': minOrderAmount,
      'max_discount': maxDiscount,
      'usage_limit': usageLimit,
      'used_count': usedCount,
      'starts_at': startsAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        startsAt.isBefore(now) &&
        expiresAt.isAfter(now) &&
        usedCount < usageLimit;
  }
}
