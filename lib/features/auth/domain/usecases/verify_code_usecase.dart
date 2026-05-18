import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyCodeParams {
  final int userId;
  final String code;
  final bool isPasswordReset;

  VerifyCodeParams({
    required this.userId,
    required this.code,
    this.isPasswordReset = false,
  });
}

class VerifyCodeUseCase
    implements UseCase<Map<String, dynamic>, VerifyCodeParams> {
  final AuthRepository repository;

  VerifyCodeUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    VerifyCodeParams params,
  ) async {
    return await repository.verifyCode(
      userId: params.userId,
      code: params.code,
      isPasswordReset: params.isPasswordReset,
    );
  }
}
