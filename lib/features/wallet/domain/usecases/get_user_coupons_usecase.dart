

import 'package:sika_customer/features/wallet/domain/repositories/wallet_repository.dart';

class GetUserCouponsParams {
  final String? status; // 'active', 'used', 'expired'
  final int page;
  final int pageSize;

  GetUserCouponsParams({this.status, this.page = 1, this.pageSize = 20});
}

class GetUserCouponsUseCase {
  final WalletRepository repository;

  GetUserCouponsUseCase(this.repository);

  /// Gets user's redeemed coupons/rewards
  Future<List<Map<String, dynamic>>> call(GetUserCouponsParams params) {
    return repository.getUserCoupons(
      status: params.status,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}
