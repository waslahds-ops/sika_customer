import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final String id;
  final String userId;
  final double balance;
  final double totalEarned;
  final double totalSpent;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const WalletEntity({
    required this.id,
    required this.userId,
    required this.balance,
    required this.totalEarned,
    required this.totalSpent,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    balance,
    totalEarned,
    totalSpent,
    createdAt,
    updatedAt,
    isActive,
  ];
}
