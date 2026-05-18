import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile_entities.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CustomerEntity>> getCustomerProfile() async {
    try {
      final customer = await remoteDataSource.getCustomerProfile();
      return Right(customer);
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
  Future<Either<Failure, CustomerEntity>> updateCustomerProfile({
    String? phoneNumber,
  }) async {
    try {
      final customer = await remoteDataSource.updateCustomerProfile(
        phoneNumber: phoneNumber,
      );
      return Right(customer);
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
  Future<Either<Failure, List<AddressEntity>>> getAddresses() async {
    try {
      final addresses = await remoteDataSource.getAddresses();
      return Right(addresses);
    } on ServerException catch (e) {
      print('❌ Repository: ServerException - $e');
      return Left(ServerFailure());
    } on NetworkException catch (e) {
      print('❌ Repository: NetworkException - $e');
      return Left(NetworkFailure());
    } on UnauthorizedException catch (e) {
      print('❌ Repository: UnauthorizedException - $e');
      return Left(UnauthorizedFailure());
    } catch (e, stackTrace) {
      print('❌ Repository: Unknown error - $e');
      print('Stack trace: $stackTrace');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AddressEntity>> getAddressById(int addressId) async {
    try {
      final address = await remoteDataSource.getAddressById(addressId);
      return Right(address);
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
  Future<Either<Failure, AddressEntity>> createAddress({
    required String label,
    required String address,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    try {
      final createdAddress = await remoteDataSource.createAddress(
        label: label,
        address: address,
        latitude: latitude,
        longitude: longitude,
        isDefault: isDefault,
      );
      return Right(createdAddress);
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
  Future<Either<Failure, AddressEntity>> updateAddress({
    required int addressId,
    String? label,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final updatedAddress = await remoteDataSource.updateAddress(
        addressId: addressId,
        label: label,
        address: address,
        latitude: latitude,
        longitude: longitude,
      );
      return Right(updatedAddress);
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
  Future<Either<Failure, void>> deleteAddress(int addressId) async {
    try {
      await remoteDataSource.deleteAddress(addressId);
      return const Right(null);
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
  Future<Either<Failure, AddressEntity>> setDefaultAddress(
    int addressId,
  ) async {
    try {
      final address = await remoteDataSource.setDefaultAddress(addressId);
      return Right(address);
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
