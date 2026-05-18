import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order_entities.dart';
import '../repositories/order_repository.dart';

class CreateOrderUseCase implements UseCase<OrderEntity, CreateOrderParams> {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(CreateOrderParams params) async {
    return await repository.createOrder(
      storeId: params.storeId,
      addressId: params.addressId,
      items: params.items,
      specialInstructions: params.specialInstructions,
      promoCode: params.promoCode,
    );
  }
}

class CreateOrderParams extends Equatable {
  final int storeId;
  final int addressId;
  final List<Map<String, dynamic>> items;
  final String? specialInstructions;
  final String? promoCode;

  const CreateOrderParams({
    required this.storeId,
    required this.addressId,
    required this.items,
    this.specialInstructions,
    this.promoCode,
  });

  @override
  List<Object?> get props => [
    storeId,
    addressId,
    items,
    specialInstructions,
    promoCode,
  ];
}
