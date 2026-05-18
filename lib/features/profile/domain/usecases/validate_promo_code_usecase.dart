import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/promo_repository.dart';

class ValidatePromoCodeUseCase {
  final PromoRepository repository;

  ValidatePromoCodeUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String code,
    double? orderAmount,
  }) async {
    return await repository.validatePromoCode(
      code: code,
      orderAmount: orderAmount,
    );
  }
}
