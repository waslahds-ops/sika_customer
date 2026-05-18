import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/store_entities.dart';
import '../repositories/store_repository.dart';

class GetStoresUseCase implements UseCase<List<StoreEntity>, GetStoresParams> {
  final StoreRepository repository;

  GetStoresUseCase(this.repository);

  @override
  Future<Either<Failure, List<StoreEntity>>> call(
    GetStoresParams params,
  ) async {
    return await repository.getStores(
      categoryId: params.categoryId,
      latitude: params.latitude,
      longitude: params.longitude,
      search: params.search,
      excludeSpecialCategories: params.excludeSpecialCategories,
    );
  }
}

class GetStoresParams extends Equatable {
  final int? categoryId;
  final double? latitude;
  final double? longitude;
  final String? search;
  final bool excludeSpecialCategories;

  const GetStoresParams({
    this.categoryId,
    this.latitude,
    this.longitude,
    this.search,
    this.excludeSpecialCategories = false,
  });

  @override
  List<Object?> get props =>
      [categoryId, latitude, longitude, search, excludeSpecialCategories];
}
