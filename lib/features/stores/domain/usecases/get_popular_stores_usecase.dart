import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/store_entities.dart';
import '../repositories/store_repository.dart';

class GetPopularStoresUseCase implements UseCase<List<StoreEntity>, NoParams> {
  final StoreRepository repository;

  GetPopularStoresUseCase(this.repository);

  @override
  Future<Either<Failure, List<StoreEntity>>> call(NoParams params) async {
    return await repository.getPopularStores();
  }
}
