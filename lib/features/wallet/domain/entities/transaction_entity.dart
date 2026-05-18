import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String walletId;
  final String type; // 'credit', 'debit'
  final double amount;
  final String description;
  final String? referenceId; // orderId, refundId, etc.
  final String status; // 'completed', 'pending', 'failed'
  final DateTime createdAt;
  final double balanceAfter;
  final String? paymentMethod;
  final Map<String, dynamic>? metadata;

  const TransactionEntity({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.description,
    this.referenceId,
    required this.status,
    required this.createdAt,
    required this.balanceAfter,
    this.paymentMethod,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    walletId,
    type,
    amount,
    description,
    referenceId,
    status,
    createdAt,
    balanceAfter,
    paymentMethod,
    metadata,
  ];
}
