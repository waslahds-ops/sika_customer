import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/store_entities.dart';
import '../../domain/repositories/store_repository.dart';
import '../datasources/store_remote_datasource.dart';

class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource remoteDataSource;

  StoreRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return Right(categories);
    } on ServerException {
      return Left(ServerFailure());
    } on NetworkException {
      return Left(NetworkFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<StoreEntity>>> getStores({
    int? categoryId,
    double? latitude,
    double? longitude,
    String? search,
    bool excludeSpecialCategories = false,
  }) async {
    try {
      final stores = await remoteDataSource.getStores(
        categoryId: categoryId,
        latitude: latitude,
        longitude: longitude,
        search: search,
        excludeSpecialCategories: excludeSpecialCategories,
      );
      return Right(stores);
    } on ServerException {
      return Left(ServerFailure());
    } on NetworkException {
      return Left(NetworkFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, StoreEntity>> getStoreById(int storeId) async {
    try {
      final store = await remoteDataSource.getStoreById(storeId);
      return Right(store);
    } on ServerException {
      return Left(ServerFailure());
    } on NetworkException {
      return Left(NetworkFailure());
    } on NotFoundException {
      return Left(NotFoundFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<StoreEntity>>> getNearbyStores({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  }) async {
    try {
      final stores = await remoteDataSource.getNearbyStores(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      return Right(stores);
    } on ServerException {
      return Left(ServerFailure());
    } on NetworkException {
      return Left(NetworkFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<StoreEntity>>> getPopularStores() async {
    try {
      final stores = await remoteDataSource.getPopularStores();
      return Right(stores);
    } on ServerException {
      return Left(ServerFailure());
    } on NetworkException {
      return Left(NetworkFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByStore(
    int storeId,
  ) async {
    try {
      print('🏪 [PRODUCTS] Repository: Getting for store $storeId');
      final products = await remoteDataSource.getProductsByStore(storeId);
      print('🏪 [PRODUCTS] Repository: Got ${products.length} products');
      return Right(products);
    } on ServerException catch (e) {
      print('❌ [PRODUCTS] ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      print('❌ [PRODUCTS] NetworkException: ${e.message}');
      return Left(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      print('❌ [PRODUCTS] UnauthorizedException: ${e.message}');
      return Left(UnauthorizedFailure(e.message));
    } catch (e) {
      print('❌ [PRODUCTS] Unknown error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(int productId) async {
    try {
      final product = await remoteDataSource.getProductById(productId);
      return Right(product);
    } on ServerException {
      return Left(ServerFailure());
    } on NetworkException {
      return Left(NetworkFailure());
    } on NotFoundException {
      return Left(NotFoundFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts({
    required String query,
    int? storeId,
    String? category,
  }) async {
    try {
      final products = await remoteDataSource.searchProducts(
        query: query,
        storeId: storeId,
        category: category,
      );
      return Right(products);
    } on ServerException {
      return Left(ServerFailure());
    } on NetworkException {
      return Left(NetworkFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFlashDeals() async {
    try {
      final deals = await remoteDataSource.getFlashDeals();
      return Right(deals);
    } on ServerException {
      return Left(ServerFailure());
    } on NetworkException {
      return Left(NetworkFailure());
    } on UnauthorizedException {
      return Left(UnauthorizedFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
