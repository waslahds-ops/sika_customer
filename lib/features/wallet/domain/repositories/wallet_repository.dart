
import 'package:sika_customer/features/wallet/domain/entities/points_reward_entity.dart';
import 'package:sika_customer/features/wallet/domain/entities/points_transaction_entity.dart';
import 'package:sika_customer/features/wallet/domain/entities/transaction_entity.dart';
import 'package:sika_customer/features/wallet/domain/entities/wallet_entity.dart';

abstract class WalletRepository {
  /// Get user's wallet details
  Future<WalletEntity> getWallet();

  /// Get wallet transaction history
  Future<List<TransactionEntity>> getTransactions({
    int page = 1,
    int pageSize = 20,
  });

  /// Add money to wallet (top-up)
  Future<TransactionEntity> topUpWallet({
    required double amount,
    required String paymentMethodId,
  });

  /// Use wallet balance to pay
  Future<TransactionEntity> payWithWallet({
    required double amount,
    required String orderId,
  });

  /// Get transaction details
  Future<TransactionEntity> getTransactionDetails(String transactionId);

  /// Refund money to wallet
  Future<TransactionEntity> refundToWallet({
    required double amount,
    required String orderId,
    required String reason,
  });

  /// Get wallet balance
  Future<double> getBalance();

  /// Check if wallet has sufficient balance
  Future<bool> hasSufficientBalance(double amount);

  /// Get transaction statistics
  Future<Map<String, dynamic>> getWalletStats();

  // ============ LOYALTY POINTS METHODS ============

  /// Get available rewards for points redemption
  Future<List<PointsRewardEntity>> getAvailableRewards({
    String? language,
    bool onlyAffordable = false,
  });

  /// Redeem a reward (convert points to coupon)
  Future<Map<String, dynamic>> redeemReward({required int rewardId});

  /// Get loyalty points transaction history
  Future<List<PointsTransactionEntity>> getPointsHistory({
    int page = 1,
    int pageSize = 20,
    String? transactionType,
  });

  /// Get user's redeemed coupons
  Future<List<Map<String, dynamic>>> getUserCoupons({
    String? status,
    int page = 1,
    int pageSize = 20,
  });

  /// Apply coupon to order
  Future<Map<String, dynamic>> applyCoupon({
    required String couponCode,
    required int orderId,
  });
}
