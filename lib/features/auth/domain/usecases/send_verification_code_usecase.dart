import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SendVerificationCodeParams {
  final int userId;

  SendVerificationCodeParams({required this.userId});
}

class SendVerificationCodeUseCase
    implements UseCase<void, SendVerificationCodeParams> {
  final AuthRepository repository;

  SendVerificationCodeUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SendVerificationCodeParams params) async {
    return await repository.sendVerificationCode(params.userId);
  }
}
