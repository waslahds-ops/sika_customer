import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile_entities.dart';
import '../repositories/profile_repository.dart';

class SetDefaultAddressUseCase
    implements UseCase<AddressEntity, SetDefaultAddressParams> {
  final ProfileRepository repository;

  SetDefaultAddressUseCase(this.repository);

  @override
  Future<Either<Failure, AddressEntity>> call(
    SetDefaultAddressParams params,
  ) async {
    return await repository.setDefaultAddress(params.addressId);
  }
}

class SetDefaultAddressParams extends Equatable {
  final int addressId;

  const SetDefaultAddressParams({required this.addressId});

  @override
  List<Object> get props => [addressId];
}
