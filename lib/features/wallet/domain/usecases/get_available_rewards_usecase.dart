

import 'package:sika_customer/features/wallet/domain/entities/points_reward_entity.dart';
import 'package:sika_customer/features/wallet/domain/repositories/wallet_repository.dart';

class GetAvailableRewardsParams {
  final String? language;
  final bool onlyAffordable;

  GetAvailableRewardsParams({this.language, this.onlyAffordable = false});
}

class GetAvailableRewardsUseCase {
  final WalletRepository repository;

  GetAvailableRewardsUseCase(this.repository);

  Future<List<PointsRewardEntity>> call(GetAvailableRewardsParams params) {
    return repository.getAvailableRewards(
      language: params.language,
      onlyAffordable: params.onlyAffordable,
    );
  }
}
