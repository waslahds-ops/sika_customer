import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile_entities.dart';

abstract class ProfileRepository {
  Future<Either<Failure, CustomerEntity>> getCustomerProfile();

  Future<Either<Failure, CustomerEntity>> updateCustomerProfile({
    String? phoneNumber,
  });

  Future<Either<Failure, List<AddressEntity>>> getAddresses();

  Future<Either<Failure, AddressEntity>> getAddressById(int addressId);

  Future<Either<Failure, AddressEntity>> createAddress({
    required String label,
    required String address,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  });

  Future<Either<Failure, AddressEntity>> updateAddress({
    required int addressId,
    String? label,
    String? address,
    double? latitude,
    double? longitude,
  });

  Future<Either<Failure, void>> deleteAddress(int addressId);

  Future<Either<Failure, AddressEntity>> setDefaultAddress(int addressId);
}
