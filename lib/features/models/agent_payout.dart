class AgentPayout {
  final int payoutId;
  final int deliveryAgentId;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime payoutDate;

  AgentPayout({
    required this.payoutId,
    required this.deliveryAgentId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.payoutDate,
  });

  factory AgentPayout.fromJson(Map<String, dynamic> json) {
    return AgentPayout(
      payoutId: json['payout_id'] as int,
      deliveryAgentId: json['delivery_agent_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      status: json['status'] as String,
      payoutDate: DateTime.parse(json['payout_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payout_id': payoutId,
      'delivery_agent_id': deliveryAgentId,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': status,
      'payout_date': payoutDate.toIso8601String(),
    };
  }
}
