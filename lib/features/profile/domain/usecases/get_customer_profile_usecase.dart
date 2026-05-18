import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile_entities.dart';
import '../repositories/profile_repository.dart';

class GetCustomerProfileUseCase implements UseCase<CustomerEntity, NoParams> {
  final ProfileRepository repository;

  GetCustomerProfileUseCase(this.repository);

  @override
  Future<Either<Failure, CustomerEntity>> call(NoParams params) async {
    return await repository.getCustomerProfile();
  }
}
