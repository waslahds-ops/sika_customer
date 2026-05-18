

import 'package:sika_customer/features/wallet/domain/entities/transaction_entity.dart';
import 'package:sika_customer/features/wallet/domain/repositories/wallet_repository.dart';

class PayWithWalletParams {
  final double amount;
  final String orderId;

  PayWithWalletParams({required this.amount, required this.orderId});
}

class PayWithWalletUseCase {
  final WalletRepository repository;

  PayWithWalletUseCase(this.repository);

  Future<TransactionEntity> call(PayWithWalletParams params) {
    return repository.payWithWallet(
      amount: params.amount,
      orderId: params.orderId,
    );
  }
}
