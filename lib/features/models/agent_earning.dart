class AgentEarning {
  final int earningId;
  final int deliveryAgentId;
  final int orderId;
  final double amount;
  final DateTime earnedAt;

  AgentEarning({
    required this.earningId,
    required this.deliveryAgentId,
    required this.orderId,
    required this.amount,
    required this.earnedAt,
  });

  factory AgentEarning.fromJson(Map<String, dynamic> json) {
    return AgentEarning(
      earningId: json['earning_id'] as int,
      deliveryAgentId: json['delivery_agent_id'] as int,
      orderId: json['order_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      earnedAt: DateTime.parse(json['earned_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'earning_id': earningId,
      'delivery_agent_id': deliveryAgentId,
      'order_id': orderId,
      'amount': amount,
      'earned_at': earnedAt.toIso8601String(),
    };
  }
}
