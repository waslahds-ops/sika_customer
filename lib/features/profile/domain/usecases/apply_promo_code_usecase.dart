import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/promo_repository.dart';

class ApplyPromoCodeUseCase {
  final PromoRepository repository;

  ApplyPromoCodeUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required int id,
    required int orderId,
  }) async {
    return await repository.applyPromoCode(id: id, orderId: orderId);
  }
}
