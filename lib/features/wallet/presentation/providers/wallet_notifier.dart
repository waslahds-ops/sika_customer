import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sika_customer/features/wallet/domain/entities/transaction_entity.dart';
import 'package:sika_customer/features/wallet/domain/entities/wallet_entity.dart';
import 'package:sika_customer/features/wallet/domain/usecases/get_transactions_usecase.dart';
import 'package:sika_customer/features/wallet/domain/usecases/pay_with_wallet_usecase.dart';
import 'package:sika_customer/features/wallet/domain/usecases/topup_wallet_usecase.dart';


/// Wallet State
class WalletState {
  final WalletEntity? wallet;
  final List<TransactionEntity> transactions;
  final bool isLoading;
  final String? error;
  final bool isRefreshing;

  WalletState({
    this.wallet,
    this.transactions = const [],
    this.isLoading = false,
    this.error,
    this.isRefreshing = false,
  });

  WalletState copyWith({
    WalletEntity? wallet,
    List<TransactionEntity>? transactions,
    bool? isLoading,
    String? error,
    bool? isRefreshing,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// Wallet Notifier
class WalletNotifier extends StateNotifier<WalletState> {
  final dynamic walletUseCases;

  WalletNotifier(this.walletUseCases) : super(WalletState());

  Future<void> getWallet() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final wallet = await walletUseCases['getWallet'].call();
      state = state.copyWith(wallet: wallet, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> getTransactions({int page = 1, int pageSize = 20}) async {
    state = state.copyWith(isRefreshing: true, error: null);
    try {
      final transactions = await walletUseCases['getTransactions'].call(
        GetTransactionsParams(page: page, pageSize: pageSize),
      );
      state = state.copyWith(transactions: transactions, isRefreshing: false);
    } catch (e) {
      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }

  Future<void> topUpWallet({
    required double amount,
    required String paymentMethodId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final transaction = await walletUseCases['topUpWallet'].call(
        TopUpWalletParams(amount: amount, paymentMethodId: paymentMethodId),
      );

      // Update wallet balance after successful top-up
      if (state.wallet != null) {
        final updatedWallet = state.wallet!;
        final newWallet = WalletEntity(
          id: updatedWallet.id,
          userId: updatedWallet.userId,
          balance: updatedWallet.balance + amount,
          totalEarned: updatedWallet.totalEarned + amount,
          totalSpent: updatedWallet.totalSpent,
          createdAt: updatedWallet.createdAt,
          updatedAt: DateTime.now(),
          isActive: updatedWallet.isActive,
        );

        state = state.copyWith(
          wallet: newWallet,
          transactions: [transaction, ...state.transactions],
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> payWithWallet({
    required double amount,
    required String orderId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final transaction = await walletUseCases['payWithWallet'].call(
        PayWithWalletParams(amount: amount, orderId: orderId),
      );

      // Update wallet balance after successful payment
      if (state.wallet != null) {
        final updatedWallet = state.wallet!;
        final newWallet = WalletEntity(
          id: updatedWallet.id,
          userId: updatedWallet.userId,
          balance: updatedWallet.balance - amount,
          totalEarned: updatedWallet.totalEarned,
          totalSpent: updatedWallet.totalSpent + amount,
          createdAt: updatedWallet.createdAt,
          updatedAt: DateTime.now(),
          isActive: updatedWallet.isActive,
        );

        state = state.copyWith(
          wallet: newWallet,
          transactions: [transaction, ...state.transactions],
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = WalletState();
  }
}
