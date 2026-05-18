import 'package:equatable/equatable.dart';

/// Represents a transaction in the user's points wallet
/// Tracks earning, redeeming, and expiring of loyalty points
class PointsTransactionEntity extends Equatable {
  final int transactionId;
  final int userId;
  final String transactionType; // 'earn', 'redeem', 'expire', 'admin_adjust'
  final int points; // Can be negative for redeem/expire
  final String description;

  final String? referenceType; // 'order', 'reward', 'admin'
  final String? referenceId;

  final int balanceBefore;
  final int balanceAfter;
  final String status; // 'completed', 'pending', 'failed'

  final DateTime createdAt;
  final DateTime updatedAt;

  const PointsTransactionEntity({
    required this.transactionId,
    required this.userId,
    required this.transactionType,
    required this.points,
    required this.description,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.referenceType,
    this.referenceId,
  });

  @override
  List<Object?> get props => [
    transactionId,
    userId,
    transactionType,
    points,
    description,
    referenceType,
    referenceId,
    balanceBefore,
    balanceAfter,
    status,
    createdAt,
    updatedAt,
  ];

  /// Get human-readable transaction type
  String getTypeLabel() {
    switch (transactionType) {
      case 'earn':
        return '✅ Points Earned';
      case 'redeem':
        return '🎁 Points Redeemed';
      case 'expire':
        return '⏰ Points Expired';
      case 'admin_adjust':
        return '🔧 Admin Adjustment';
      default:
        return 'Transaction';
    }
  }

  /// Get transaction icon based on type
  String getTypeIcon() {
    switch (transactionType) {
      case 'earn':
        return '➕';
      case 'redeem':
        return '➖';
      case 'expire':
        return '❌';
      case 'admin_adjust':
        return '⚙️';
      default:
        return '•';
    }
  }

  /// Format points with sign (+ or -)
  String getFormattedPoints() {
    if (points > 0) {
      return '+$points';
    } else if (points < 0) {
      return '${points}'; // Already has minus sign
    } else {
      return '0';
    }
  }
}
