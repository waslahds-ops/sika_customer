import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/store_entities.dart';

abstract class StoreRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories();

  Future<Either<Failure, List<StoreEntity>>> getStores({
    int? categoryId,
    double? latitude,
    double? longitude,
    String? search,
    bool excludeSpecialCategories = false,
  });

  Future<Either<Failure, List<StoreEntity>>> getPopularStores();

  Future<Either<Failure, StoreEntity>> getStoreById(int storeId);

  Future<Either<Failure, List<StoreEntity>>> getNearbyStores({
    required double latitude,
    required double longitude,
    double radius,
  });

  Future<Either<Failure, List<ProductEntity>>> getProductsByStore(int storeId);

  Future<Either<Failure, ProductEntity>> getProductById(int productId);

  Future<Either<Failure, List<ProductEntity>>> searchProducts({
    required String query,
    int? storeId,
    String? category,
  });

  Future<Either<Failure, List<ProductEntity>>> getFlashDeals();
}
