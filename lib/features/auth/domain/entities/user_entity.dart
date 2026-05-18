import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int userId;
  final String phoneNumber;
  final String? email;
  final String role;
  final String languagePreference;
  final bool isVerified;
  final String? accessToken;
  final String? firstName;
  final String? lastName;
  final String? profileImage;
  final DateTime? createdAt;

  const UserEntity({
    required this.userId,
    required this.phoneNumber,
    this.email,
    required this.role,
    required this.languagePreference,
    required this.isVerified,
    this.accessToken,
    this.firstName,
    this.lastName,
    this.profileImage,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    userId,
    phoneNumber,
    email,
    role,
    languagePreference,
    isVerified,
    accessToken,
    firstName,
    lastName,
    profileImage,
    createdAt,
  ];
}
