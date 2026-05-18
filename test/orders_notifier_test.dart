import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:sika_customer/core/error/failures.dart';
import 'package:sika_customer/features/orders/domain/entities/order_entities.dart';
import 'package:sika_customer/features/orders/domain/repositories/order_repository.dart';
import 'package:sika_customer/features/orders/domain/usecases/create_order_usecase.dart';
import 'package:sika_customer/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:sika_customer/features/orders/presentation/providers/orders_provider.dart';


class FakeCreateOrderSuccess implements CreateOrderUseCase {
  @override
  OrderRepository get repository => throw UnimplementedError();
  @override
  Future<Either<Failure, OrderEntity>> call(CreateOrderParams params) async {
    final order = OrderEntity(
      orderId: 1,
      customerId: 1,
      storeId: params.storeId,
      orderNumber: '#0001',
      subtotal: 10.0,
      deliveryFee: 5.0,
      discount: 0.0,
      totalAmount: 15.0,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    return Right(order);
  }
}

class FakeCreateOrderFailure implements CreateOrderUseCase {
  @override
  OrderRepository get repository => throw UnimplementedError();
  @override
  Future<Either<Failure, OrderEntity>> call(CreateOrderParams params) async {
    return Left(const ServerFailure('Server failed'));
  }
}

class FakeGetOrders implements GetOrdersUseCase {
  @override
  OrderRepository get repository => throw UnimplementedError();
  @override
  Future<Either<Failure, List<OrderEntity>>> call(
    GetOrdersParams params,
  ) async {
    return Right([]);
  }
}

void main() {
  group('OrdersNotifier.createOrder', () {
    test('returns created order and updates state on success', () async {
      final notifier = OrdersNotifier(
        createOrderUseCase: FakeCreateOrderSuccess(),
        getOrdersUseCase: FakeGetOrders(),
      );

      final created = await notifier.createOrder(
        storeId: 2,
        addressId: 10,
        items: [
          {'product_id': 1, 'quantity': 1},
        ],
      );

      expect(created, isNotNull);
      expect(notifier.state.selectedOrder, equals(created));
      expect(notifier.state.successMessage, isNotNull);
    });

    test('returns null and sets errorMessage on failure', () async {
      final notifier = OrdersNotifier(
        createOrderUseCase: FakeCreateOrderFailure(),
        getOrdersUseCase: FakeGetOrders(),
      );

      final created = await notifier.createOrder(
        storeId: 2,
        addressId: 10,
        items: [
          {'product_id': 1, 'quantity': 1},
        ],
      );

      expect(created, isNull);
      expect(notifier.state.selectedOrder, isNull);
      expect(notifier.state.errorMessage, isNotNull);
    });
  });
}
