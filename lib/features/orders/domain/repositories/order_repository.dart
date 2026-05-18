import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/order_entities.dart';

abstract class OrderRepository {
  Future<Either<Failure, OrderEntity>> createOrder({
    required int storeId,
    required int addressId,
    required List<Map<String, dynamic>> items,
    String? specialInstructions,
    String? promoCode,
  });

  Future<Either<Failure, List<OrderEntity>>> getOrders({String? tab});

  Future<Either<Failure, OrderEntity>> getOrderById(int orderId);

  Future<Either<Failure, OrderEntity>> cancelOrder(int orderId);
}
