import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile_entities.dart';
import '../repositories/profile_repository.dart';

class CreateAddressUseCase
    implements UseCase<AddressEntity, CreateAddressParams> {
  final ProfileRepository repository;

  CreateAddressUseCase(this.repository);

  @override
  Future<Either<Failure, AddressEntity>> call(
    CreateAddressParams params,
  ) async {
    return await repository.createAddress(
      label: params.label,
      address: params.address,
      latitude: params.latitude,
      longitude: params.longitude,
      isDefault: params.isDefault,
    );
  }
}

class CreateAddressParams extends Equatable {
  final String label;
  final String address;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const CreateAddressParams({
    required this.label,
    required this.address,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [label, address, latitude, longitude, isDefault];
}
