
import 'package:sika_customer/core/utils/api_service.dart';
import 'package:sika_customer/features/wallet/data/models/points_reward_model.dart';
import 'package:sika_customer/features/wallet/data/models/points_transaction_model.dart';
import 'package:sika_customer/features/wallet/data/models/transaction_model.dart';
import 'package:sika_customer/features/wallet/data/models/wallet_model.dart';
import 'package:sika_customer/features/wallet/domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final ApiService apiService;

  WalletRepositoryImpl({required this.apiService});

  @override
  Future<WalletModel> getWallet() async {
    try {
      final response = await apiService.get('/wallet');
      return WalletModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TransactionModel>> getTransactions({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await apiService.get(
        '/wallet/transactions',
        queryParameters: {'page': page, 'page_size': pageSize},
      );

      final data = response as Map<String, dynamic>;
      final transactions = (data['data'] as List)
          .map((t) => TransactionModel.fromJson(t as Map<String, dynamic>))
          .toList();

      return transactions;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TransactionModel> topUpWallet({
    required double amount,
    required String paymentMethodId,
  }) async {
    try {
      final response = await apiService.post(
        '/wallet/top-up',
        data: {'amount': amount, 'payment_method_id': paymentMethodId},
      );
      return TransactionModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TransactionModel> payWithWallet({
    required double amount,
    required String orderId,
  }) async {
    try {
      final response = await apiService.post(
        '/wallet/pay',
        data: {'amount': amount, 'order_id': orderId},
      );
      return TransactionModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TransactionModel> getTransactionDetails(String transactionId) async {
    try {
      final response = await apiService.get(
        '/wallet/transactions/$transactionId',
      );
      return TransactionModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TransactionModel> refundToWallet({
    required double amount,
    required String orderId,
    required String reason,
  }) async {
    try {
      final response = await apiService.post(
        '/wallet/refund',
        data: {'amount': amount, 'order_id': orderId, 'reason': reason},
      );
      return TransactionModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<double> getBalance() async {
    try {
      final wallet = await getWallet();
      return wallet.balance;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> hasSufficientBalance(double amount) async {
    try {
      final balance = await getBalance();
      return balance >= amount;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getWalletStats() async {
    try {
      final response = await apiService.get('/wallet/stats');
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // ============ LOYALTY POINTS METHODS ============

  @override
  Future<List<PointsRewardModel>> getAvailableRewards({
    String? language,
    bool onlyAffordable = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (language != null) 'lang': language,
        if (onlyAffordable) 'only_affordable': onlyAffordable,
      };

      final response = await apiService.get(
        '/wallet/loyalty/rewards',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response as Map<String, dynamic>;
      final rewards = (data['data'] as List)
          .map((r) => PointsRewardModel.fromJson(r as Map<String, dynamic>))
          .toList();

      return rewards;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> redeemReward({required int rewardId}) async {
    try {
      final response = await apiService.post(
        '/wallet/loyalty/redeem',
        data: {'reward_id': rewardId},
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PointsTransactionModel>> getPointsHistory({
    int page = 1,
    int pageSize = 20,
    String? transactionType,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': pageSize,
        if (transactionType != null) 'type': transactionType,
      };

      final response = await apiService.get(
        '/wallet/loyalty/transactions',
        queryParameters: queryParams,
      );

      final data = response as Map<String, dynamic>;
      final transactions = (data['data'] as List)
          .map(
            (t) => PointsTransactionModel.fromJson(t as Map<String, dynamic>),
          )
          .toList();

      return transactions;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserCoupons({
    String? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': pageSize,
        if (status != null) 'status': status,
      };

      final response = await apiService.get(
        '/wallet/loyalty/my-coupons',
        queryParameters: queryParams,
      );

      final data = response as Map<String, dynamic>;
      final coupons = (data['data'] as List)
          .map((c) => c as Map<String, dynamic>)
          .toList();

      return coupons;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> applyCoupon({
    required String couponCode,
    required int orderId,
  }) async {
    try {
      final response = await apiService.post(
        '/orders/apply-coupon',
        data: {'coupon_code': couponCode, 'order_id': orderId},
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
