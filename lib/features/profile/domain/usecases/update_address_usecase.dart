import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile_entities.dart';
import '../repositories/profile_repository.dart';

class UpdateAddressUseCase
    implements UseCase<AddressEntity, UpdateAddressParams> {
  final ProfileRepository repository;

  UpdateAddressUseCase(this.repository);

  @override
  Future<Either<Failure, AddressEntity>> call(
    UpdateAddressParams params,
  ) async {
    return await repository.updateAddress(
      addressId: params.addressId,
      label: params.label,
      address: params.address,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}

class UpdateAddressParams extends Equatable {
  final int addressId;
  final String? label;
  final String? address;
  final double? latitude;
  final double? longitude;

  const UpdateAddressParams({
    required this.addressId,
    this.label,
    this.address,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [addressId, label, address, latitude, longitude];
}
