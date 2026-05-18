
import 'package:sika_customer/features/wallet/domain/entities/points_transaction_entity.dart';
import 'package:sika_customer/features/wallet/domain/repositories/wallet_repository.dart';

class GetPointsHistoryParams {
  final int page;
  final int pageSize;
  final String? transactionType; // 'earn', 'redeem', 'expire'

  GetPointsHistoryParams({
    this.page = 1,
    this.pageSize = 20,
    this.transactionType,
  });
}

class GetPointsHistoryUseCase {
  final WalletRepository repository;

  GetPointsHistoryUseCase(this.repository);

  /// Gets user's points transaction history
  Future<List<PointsTransactionEntity>> call(GetPointsHistoryParams params) {
    return repository.getPointsHistory(
      page: params.page,
      pageSize: params.pageSize,
      transactionType: params.transactionType,
    );
  }
}
