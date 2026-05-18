import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, Map<String, dynamic>>> register({
    required String phoneNumber,
    String? email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
    String? storeName,
    String? vehicleType,
    String? fcmToken,
  });

  Future<Either<Failure, Map<String, dynamic>>> login({
    String? email,
    String? phoneNumber,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Map<String, dynamic>> sendOTP(String phoneNumber);

  Future<Map<String, dynamic>> resendOTP(String phoneNumber);

  Future<Map<String, dynamic>> verifyOTP({
    required String phoneNumber,
    required String otp,
  });

  // Legacy methods
  @Deprecated('Use sendOTP instead')
  Future<Either<Failure, void>> sendVerificationCode(int userId);

  @Deprecated('Use verifyOTP instead')
  Future<Either<Failure, Map<String, dynamic>>> verifyCode({
    required int userId,
    required String code,
    bool isPasswordReset = false,
  });

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, UserEntity>> updateProfile({
    String? email,
    String? firstName,
    String? lastName,
    String? profileImage,
    File? profileImageFile,
  });

  Future<String?> getStoredToken();

  Future<void> saveToken(String token);

  Future<void> deleteToken();

  Future<Map<String, dynamic>?> getStoredUserData();

  Future<void> saveUserData(Map<String, dynamic> userData);

  Future<void> saveVerificationCode(String code);

  Future<String?> getVerificationCode();

  Future<void> deleteVerificationCode();

  Future<void> saveVerificationCodeTimestamp(int timestamp);

  Future<int?> getVerificationCodeTimestamp();

  Future<Either<Failure, Map<String, dynamic>>> requestPasswordReset({
    String? email,
    String? phoneNumber,
    String? fcmToken,
  });

  Future<Either<Failure, void>> resetPassword({
    required int userId,
    required String password,
    required String verificationCode,
  });

  Future<Either<Failure, void>> updateLanguagePreference(String languageCode);
}
