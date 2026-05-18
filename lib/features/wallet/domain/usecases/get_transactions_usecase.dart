

import 'package:sika_customer/features/wallet/domain/entities/transaction_entity.dart';
import 'package:sika_customer/features/wallet/domain/repositories/wallet_repository.dart';

class GetTransactionsParams {
  final int page;
  final int pageSize;

  GetTransactionsParams({this.page = 1, this.pageSize = 20});
}

class GetTransactionsUseCase {
  final WalletRepository repository;

  GetTransactionsUseCase(this.repository);

  Future<List<TransactionEntity>> call(GetTransactionsParams params) {
    return repository.getTransactions(
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}
