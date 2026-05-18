import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase implements UseCase<UserEntity, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) {
    return repository.updateProfile(
      email: params.email,
      firstName: params.firstName,
      lastName: params.lastName,
      profileImage: params.profileImage,
      profileImageFile: params.profileImageFile,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? profileImage;
  final File? profileImageFile;

  const UpdateProfileParams({
    this.email,
    this.firstName,
    this.lastName,
    this.profileImage,
    this.profileImageFile,
  });

  @override
  List<Object?> get props => [
    email,
    firstName,
    lastName,
    profileImage,
    profileImageFile,
  ];
}
