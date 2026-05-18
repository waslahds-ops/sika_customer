

import 'package:sika_customer/features/wallet/domain/entities/transaction_entity.dart';
import 'package:sika_customer/features/wallet/domain/repositories/wallet_repository.dart';

class TopUpWalletParams {
  final double amount;
  final String paymentMethodId;

  TopUpWalletParams({required this.amount, required this.paymentMethodId});
}

class TopUpWalletUseCase {
  final WalletRepository repository;

  TopUpWalletUseCase(this.repository);

  Future<TransactionEntity> call(TopUpWalletParams params) {
    return repository.topUpWallet(
      amount: params.amount,
      paymentMethodId: params.paymentMethodId,
    );
  }
}
