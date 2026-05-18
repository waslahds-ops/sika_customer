import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order_entities.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase implements UseCase<List<OrderEntity>, GetOrdersParams> {
  final OrderRepository repository;

  GetOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(
    GetOrdersParams params,
  ) async {
    return await repository.getOrders(tab: params.tab);
  }
}

class GetOrdersParams extends Equatable {
  final String? tab;

  const GetOrdersParams({this.tab});

  @override
  List<Object?> get props => [tab];
}
