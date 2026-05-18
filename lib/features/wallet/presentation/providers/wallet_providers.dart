import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sika_customer/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:sika_customer/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:sika_customer/features/wallet/domain/usecases/get_transactions_usecase.dart';
import 'package:sika_customer/features/wallet/domain/usecases/get_wallet_usecase.dart';
import 'package:sika_customer/features/wallet/domain/usecases/pay_with_wallet_usecase.dart';
import 'package:sika_customer/features/wallet/domain/usecases/topup_wallet_usecase.dart';
import 'package:sika_customer/features/wallet/presentation/providers/wallet_notifier.dart';
import 'package:sika_customer/injection_container.dart';

// Repository
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return WalletRepositoryImpl(apiService: apiService);
});

// Use Cases
final getWalletUseCaseProvider = Provider((ref) {
  final repository = ref.watch(walletRepositoryProvider);
  return GetWalletUseCase(repository);
});

final getTransactionsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(walletRepositoryProvider);
  return GetTransactionsUseCase(repository);
});

final topUpWalletUseCaseProvider = Provider((ref) {
  final repository = ref.watch(walletRepositoryProvider);
  return TopUpWalletUseCase(repository);
});

final payWithWalletUseCaseProvider = Provider((ref) {
  final repository = ref.watch(walletRepositoryProvider);
  return PayWithWalletUseCase(repository);
});

// Wallet Notifier Provider
final walletNotifierProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
      return WalletNotifier({
        'getWallet': ref.watch(getWalletUseCaseProvider),
        'getTransactions': ref.watch(getTransactionsUseCaseProvider),
        'topUpWallet': ref.watch(topUpWalletUseCaseProvider),
        'payWithWallet': ref.watch(payWithWalletUseCaseProvider),
      });
    });
