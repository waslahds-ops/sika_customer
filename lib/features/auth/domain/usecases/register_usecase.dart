import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<Map<String, dynamic>, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    RegisterParams params,
  ) async {
    return await repository.register(
      phoneNumber: params.phoneNumber,
      email: params.email,
      password: params.password,
      role: params.role,
      firstName: params.firstName,
      lastName: params.lastName,
      storeName: params.storeName,
      vehicleType: params.vehicleType,
      fcmToken: params.fcmToken,
    );
  }
}

class RegisterParams extends Equatable {
  final String phoneNumber;
  final String? email;
  final String password;
  final String role;
  final String? firstName;
  final String? lastName;
  final String? storeName;
  final String? vehicleType;
  final String? fcmToken;

  const RegisterParams({
    required this.phoneNumber,
    this.email,
    required this.password,
    required this.role,
    this.firstName,
    this.lastName,
    this.storeName,
    this.vehicleType,
    this.fcmToken,
  });

  @override
  List<Object?> get props => [
    phoneNumber,
    email,
    password,
    role,
    firstName,
    lastName,
    storeName,
    vehicleType,
    fcmToken,
  ];
}
