import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class DeleteAddressUseCase implements UseCase<void, DeleteAddressParams> {
  final ProfileRepository repository;

  DeleteAddressUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteAddressParams params) async {
    return await repository.deleteAddress(params.addressId);
  }
}

class DeleteAddressParams extends Equatable {
  final int addressId;

  const DeleteAddressParams({required this.addressId});

  @override
  List<Object> get props => [addressId];
}
