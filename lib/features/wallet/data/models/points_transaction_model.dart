

import 'package:sika_customer/features/wallet/domain/entities/points_transaction_entity.dart';

/// Data layer model for PointsTransaction with JSON serialization
class PointsTransactionModel extends PointsTransactionEntity {
  const PointsTransactionModel({
    required super.transactionId,
    required super.userId,
    required super.transactionType,
    required super.points,
    required super.description,
    required super.balanceBefore,
    required super.balanceAfter,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.referenceType,
    super.referenceId,
  });

  /// Create from JSON response
  factory PointsTransactionModel.fromJson(Map<String, dynamic> json) {
    return PointsTransactionModel(
      transactionId: json['id'] as int,
      userId: json['user_id'] as int,
      transactionType: json['transaction_type'] as String,
      points: json['points'] as int,
      description: json['description'] as String,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      balanceBefore: json['balance_before'] as int,
      balanceAfter: json['balance_after'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': transactionId,
      'user_id': userId,
      'transaction_type': transactionType,
      'points': points,
      'description': description,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'balance_before': balanceBefore,
      'balance_after': balanceAfter,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from entity
  factory PointsTransactionModel.fromEntity(PointsTransactionEntity entity) {
    return PointsTransactionModel(
      transactionId: entity.transactionId,
      userId: entity.userId,
      transactionType: entity.transactionType,
      points: entity.points,
      description: entity.description,
      referenceType: entity.referenceType,
      referenceId: entity.referenceId,
      balanceBefore: entity.balanceBefore,
      balanceAfter: entity.balanceAfter,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
