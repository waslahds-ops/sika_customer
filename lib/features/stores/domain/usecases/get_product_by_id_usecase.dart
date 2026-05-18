import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/store_entities.dart';
import '../repositories/store_repository.dart';

class GetProductByIdUseCase implements UseCase<ProductEntity, int> {
  final StoreRepository repository;

  GetProductByIdUseCase(this.repository);

  @override
  Future<Either<Failure, ProductEntity>> call(int params) async {
    return await repository.getProductById(params);
  }
}
