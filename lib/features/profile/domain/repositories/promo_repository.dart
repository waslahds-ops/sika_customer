import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';

abstract class PromoRepository {
  Future<Either<Failure, List<dynamic>>> getCustomerPromoCodes();

  Future<Either<Failure, List<dynamic>>> getUsedPromoCodes();

  Future<Either<Failure, Map<String, dynamic>>> validatePromoCode({
    required String code,
    double? orderAmount,
  });

  Future<Either<Failure, Map<String, dynamic>>> applyPromoCode({
    required int id,
    required int orderId,
  });
}
