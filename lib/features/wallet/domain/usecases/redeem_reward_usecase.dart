

import 'package:sika_customer/features/wallet/domain/repositories/wallet_repository.dart';

class RedeemRewardParams {
  final int rewardId;

  RedeemRewardParams({required this.rewardId});
}

class RedeemRewardUseCase {
  final WalletRepository repository;

  RedeemRewardUseCase(this.repository);

  /// Redeems a reward (converts points to coupon)
  /// Returns the redemption details including coupon code
  Future<Map<String, dynamic>> call(RedeemRewardParams params) {
    return repository.redeemReward(rewardId: params.rewardId);
  }
}
