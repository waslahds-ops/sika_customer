class Payment {
  final int paymentId;
  final int orderId;
  final double amount;
  final String method;
  final String status;
  final String? gatewayTransactionId;
  final String currency;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Payment({
    required this.paymentId,
    required this.orderId,
    required this.amount,
    required this.method,
    required this.status,
    this.gatewayTransactionId,
    required this.currency,
    this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['payment_id'] as int,
      orderId: json['order_id'] as int,
      amount: double.parse(json['amount'].toString()),
      method: json['method'] as String,
      status: json['status'] as String,
      gatewayTransactionId: json['gateway_transaction_id'] as String?,
      currency: json['currency'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'order_id': orderId,
      'amount': amount,
      'method': method,
      'status': status,
      'gateway_transaction_id': gatewayTransactionId,
      'currency': currency,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
