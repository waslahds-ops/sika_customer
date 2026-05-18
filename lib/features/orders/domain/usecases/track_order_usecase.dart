// NOT AVAILABLE IN CUSTOMER API - Order tracking is handled by admin/merchant endpoints
// This usecase is commented out until tracking endpoints are implemented for customers

// import 'package:dartz/dartz.dart';
// import '../../../../core/error/failures.dart';
// import '../../../../core/usecases/usecase.dart';
// import '../entities/order_entities.dart';
// import '../repositories/order_repository.dart';
//
// class TrackOrderUseCase implements UseCase<List<OrderTrackingEntity>, int> {
//   final OrderRepository repository;
//
//   TrackOrderUseCase(this.repository);
//
//   @override
//   Future<Either<Failure, List<OrderTrackingEntity>>> call(int orderId) async {
//     return await repository.trackOrder(orderId);
//   }
// }
