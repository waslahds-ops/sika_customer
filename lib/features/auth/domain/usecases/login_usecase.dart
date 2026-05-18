import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<Map<String, dynamic>, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(LoginParams params) {
    return repository.login(
      email: params.email,
      phoneNumber: params.phoneNumber,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String? email;
  final String? phoneNumber;
  final String password;

  const LoginParams({this.email, this.phoneNumber, required this.password})
    : assert(
        email != null || phoneNumber != null,
        'Either email or phoneNumber must be provided',
      );

  @override
  List<Object?> get props => [email, phoneNumber, password];
}
