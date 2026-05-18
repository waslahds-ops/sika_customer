import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile_entities.dart';
import '../repositories/profile_repository.dart';

class GetAddressesUseCase implements UseCase<List<AddressEntity>, NoParams> {
  final ProfileRepository repository;

  GetAddressesUseCase(this.repository);

  @override
  Future<Either<Failure, List<AddressEntity>>> call(NoParams params) async {
    return await repository.getAddresses();
  }
}
