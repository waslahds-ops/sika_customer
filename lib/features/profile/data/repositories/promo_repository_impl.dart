import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/promo_repository.dart';
import '../datasources/promo_remote_datasource.dart';

class PromoRepositoryImpl implements PromoRepository {
  final PromoRemoteDataSource remoteDataSource;

  PromoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<dynamic>>> getCustomerPromoCodes() async {
    try {
      final res = await remoteDataSource.getCustomerPromoCodes();
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> getUsedPromoCodes() async {
    try {
      final res = await remoteDataSource.getUsedPromoCodes();
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> validatePromoCode({
    required String code,
    double? orderAmount,
  }) async {
    try {
      final res = await remoteDataSource.validatePromoCode(
        code: code,
        orderAmount: orderAmount,
      );
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> applyPromoCode({
    required int id,
    required int orderId,
  }) async {
    try {
      final res = await remoteDataSource.applyPromoCode(
        id: id,
        orderId: orderId,
      );
      return Right(res);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
