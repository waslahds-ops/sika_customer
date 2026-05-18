import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/promo_repository.dart';

class GetUsedPromoCodesUseCase {
  final PromoRepository repository;

  GetUsedPromoCodesUseCase(this.repository);

  Future<Either<Failure, List<dynamic>>> call() async {
    return await repository.getUsedPromoCodes();
  }
}
