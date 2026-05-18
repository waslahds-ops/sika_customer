

import 'package:sika_customer/features/wallet/domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.walletId,
    required super.type,
    required super.amount,
    required super.description,
    super.referenceId,
    required super.status,
    required super.createdAt,
    required super.balanceAfter,
    super.paymentMethod,
    super.metadata,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      walletId: json['wallet_id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      referenceId: json['reference_id'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      balanceAfter: (json['balance_after'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'type': type,
      'amount': amount,
      'description': description,
      'reference_id': referenceId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'balance_after': balanceAfter,
      'payment_method': paymentMethod,
      'metadata': metadata,
    };
  }
}
