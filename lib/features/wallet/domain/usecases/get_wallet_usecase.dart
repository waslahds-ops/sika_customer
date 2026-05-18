

import 'package:sika_customer/features/wallet/domain/entities/wallet_entity.dart';
import 'package:sika_customer/features/wallet/domain/repositories/wallet_repository.dart';

class GetWalletUseCase {
  final WalletRepository repository;

  GetWalletUseCase(this.repository);

  Future<WalletEntity> call() {
    return repository.getWallet();
  }
}
