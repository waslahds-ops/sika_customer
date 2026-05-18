class Commission {
  final int commissionId;
  final int orderId;
  final double platformFee;
  final double merchantFee;
  final double deliveryFee;
  final double totalCommission;
  final DateTime calculatedAt;

  Commission({
    required this.commissionId,
    required this.orderId,
    required this.platformFee,
    required this.merchantFee,
    required this.deliveryFee,
    required this.totalCommission,
    required this.calculatedAt,
  });

  factory Commission.fromJson(Map<String, dynamic> json) {
    return Commission(
      commissionId: json['commission_id'] as int,
      orderId: json['order_id'] as int,
      platformFee: (json['platform_fee'] as num).toDouble(),
      merchantFee: (json['merchant_fee'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      totalCommission: (json['total_commission'] as num).toDouble(),
      calculatedAt: DateTime.parse(json['calculated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commission_id': commissionId,
      'order_id': orderId,
      'platform_fee': platformFee,
      'merchant_fee': merchantFee,
      'delivery_fee': deliveryFee,
      'total_commission': totalCommission,
      'calculated_at': calculatedAt.toIso8601String(),
    };
  }
}
