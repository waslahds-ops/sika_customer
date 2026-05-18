class PromoUsage {
  final int usageId;
  final int promoId;
  final int customerId;
  final int orderId;
  final DateTime usedAt;

  PromoUsage({
    required this.usageId,
    required this.promoId,
    required this.customerId,
    required this.orderId,
    required this.usedAt,
  });

  factory PromoUsage.fromJson(Map<String, dynamic> json) {
    return PromoUsage(
      usageId: json['usage_id'] as int,
      promoId: json['promo_id'] as int,
      customerId: json['customer_id'] as int,
      orderId: json['order_id'] as int,
      usedAt: DateTime.parse(json['used_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usage_id': usageId,
      'promo_id': promoId,
      'customer_id': customerId,
      'order_id': orderId,
      'used_at': usedAt.toIso8601String(),
    };
  }
}
