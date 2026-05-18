import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/store_entities.dart';
import '../repositories/store_repository.dart';

class GetProductsByStoreUseCase implements UseCase<List<ProductEntity>, int> {
  final StoreRepository repository;

  GetProductsByStoreUseCase(this.repository);

  @override
  Future<Either<Failure, List<ProductEntity>>> call(int storeId) async {
    return await repository.getProductsByStore(storeId);
  }
}
