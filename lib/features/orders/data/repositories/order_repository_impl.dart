import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/order_entities.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, OrderEntity>> createOrder({
    required int storeId,
    required int addressId,
    required List<Map<String, dynamic>> items,
    String? specialInstructions,
    String? promoCode,
  }) async {
    try {
      final order = await remoteDataSource.createOrder(
        storeId: storeId,
        addressId: addressId,
        items: items,
        specialInstructions: specialInstructions,
        promoCode: promoCode,
      );
      return Right(order);
    } on ServerException {
      return Left(ServerFailure());
    } on NetworkException {
      return Left(NetworkFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders({String? tab}) async {
    try {
      // Simply return orders from API without enrichment
      // Store names will be fetched on-demand in UI to avoid rate limiting
      final orders = await remoteDataSource.getOrders(tab: tab);
      return Right(orders);
    } on ForbiddenException catch (e) {
      print('❌ Repository: Forbidden - ${e.message}');
      return Left(ForbiddenFailure(e.message));
    } on ServerException catch (e) {
      print('❌ Repository: Server error - ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      print('❌ Repository: Network error - ${e.message}');
      return Left(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      print('❌ Repository: Unauthorized - ${e.message}');
      return Left(UnauthorizedFailure(e.message));
    } catch (e) {
      print('❌ Repository: Unknown error - $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(int orderId) async {
    try {
      final order = await remoteDataSource.getOrderById(orderId);
      return Right(order);
    } on ServerException {
      return Left(ServerFailure());
    } on NetworkException {
      return Left(NetworkFailure());
    } on NotFoundException {
      return Left(NotFoundFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> cancelOrder(int orderId) async {
    try {
      final order = await remoteDataSource.cancelOrder(orderId);
      return Right(order);
    } on ServerException {
      return Left(ServerFailure());
    } on NetworkException {
      return Left(NetworkFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
