import 'dart:io';
import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/api_service.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> register({
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

  Future<Map<String, dynamic>> login({
    String? email,
    String? phoneNumber,
    required String password,
  });

  Future<void> logout();

  Future<Map<String, dynamic>> sendOTP(String phoneNumber);

  Future<Map<String, dynamic>> resendOTP(String phoneNumber);

  Future<Map<String, dynamic>> verifyOTP({
    required String phoneNumber,
    required String otp,
  });

  // Legacy methods for backward compatibility
  @Deprecated('Use sendOTP instead')
  Future<void> sendVerificationCode(int userId);

  @Deprecated('Use verifyOTP instead')
  Future<Map<String, dynamic>> verifyCode({
    required int userId,
    required String code,
    bool isPasswordReset = false,
  });

  Future<UserModel> getCurrentUser();

  Future<Map<String, dynamic>> updateProfile({
    String? email,
    String? firstName,
    String? lastName,
    String? profileImage,
    File? profileImageFile,
  });

  Future<Map<String, dynamic>> requestPasswordReset({
    String? email,
    String? phoneNumber,
    String? fcmToken,
  });

  Future<void> resetPassword({
    required int userId,
    required String password,
    required String verificationCode,
  });

  Future<void> updateLanguagePreference(String languageCode);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSourceImpl(this.apiService);

  @override
  Future<Map<String, dynamic>> register({
    required String phoneNumber,
    String? email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
    String? storeName,
    String? vehicleType,
    String? fcmToken,
  }) async {
    try {
      return await apiService.register(
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        role: role,
        firstName: firstName,
        lastName: lastName,
        storeName: storeName,
        vehicleType: vehicleType,
        fcmToken: fcmToken,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final data = e.response?.data;
        final message = (data is Map && data['message'] != null)
            ? data['message'] as String
            : 'Validation failed';
        final errors = (data is Map && data['errors'] != null)
            ? data['errors'] as Map<String, dynamic>
            : null;

        throw ValidationException(message, errors);
      }
      throw ServerException(e.toString());
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> login({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    try {
      return await apiService.login(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
    } on DioException catch (e) {
      // Extract user_id from 403 response if available
      if (e.response?.statusCode == 403) {
        final data = e.response?.data;
        final userId = (data is Map && data['user_id'] != null)
            ? data['user_id'] as int
            : null;
        final message = (data is Map && data['message'] != null)
            ? data['message'] as String
            : 'Access denied. Please verify your account.';
        throw ForbiddenException(message, userId);
      }
      throw ServerException(e.toString());
    } catch (e) {
      if (e is ForbiddenException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await apiService.logout();
  }

  @override
  Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    // Normalize phone number - remove '+' prefix if present for API compatibility
    final normalizedPhone = phoneNumber.startsWith('+')
        ? phoneNumber.substring(1)
        : phoneNumber;
    print('📱 Sending OTP to: $normalizedPhone (original: $phoneNumber)');
    return await apiService.sendOTP(normalizedPhone);
  }

  @override
  Future<Map<String, dynamic>> resendOTP(String phoneNumber) async {
    // Normalize phone number - remove '+' prefix if present for API compatibility
    final normalizedPhone = phoneNumber.startsWith('+')
        ? phoneNumber.substring(1)
        : phoneNumber;
    print('📱 Resending OTP to: $normalizedPhone (original: $phoneNumber)');
    return await apiService.resendOTP(normalizedPhone);
  }

  @override
  Future<Map<String, dynamic>> verifyOTP({
    required String phoneNumber,
    required String otp,
  }) async {
    // Normalize phone number - remove '+' prefix if present for API compatibility
    final normalizedPhone = phoneNumber.startsWith('+')
        ? phoneNumber.substring(1)
        : phoneNumber;

    print('📱 Verifying OTP:');
    print('   Original: $phoneNumber');
    print('   Normalized: $normalizedPhone');
    print('   OTP: $otp');

    return await apiService.verifyOTP(phoneNumber: normalizedPhone, otp: otp);
  }

  // Legacy methods
  @override
  Future<void> sendVerificationCode(int userId) async {
    await apiService.sendVerificationCode(userId);
  }

  @override
  Future<Map<String, dynamic>> verifyCode({
    required int userId,
    required String code,
    bool isPasswordReset = false,
  }) async {
    return await apiService.verifyCode(
      userId: userId,
      code: code,
      isPasswordReset: isPasswordReset,
    );
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final user = await apiService.getCurrentUser();
    return UserModel.fromJson({
      'user_id': user.userId,
      'phone_number': user.phoneNumber,
      'email': user.email,
      'role': user.role,
      'language_preference': user.languagePreference,
      'is_verified': user.isVerified,
      'created_at': user.createdAt?.toIso8601String(),
      'first_name': user.firstName,
      'last_name': user.lastName,
      'profile_image': user.profileImage,
    });
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    String? email,
    String? firstName,
    String? lastName,
    String? profileImage,
    File? profileImageFile,
  }) async {
    return await apiService.updateProfile(
      email: email,
      firstName: firstName,
      lastName: lastName,
      profileImage: profileImage,
      profileImageFile: profileImageFile,
    );
  }

  @override
  Future<Map<String, dynamic>> requestPasswordReset({
    String? email,
    String? phoneNumber,
    String? fcmToken,
  }) async {
    return await apiService.requestPasswordReset(
      email: email,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<void> resetPassword({
    required int userId,
    required String password,
    required String verificationCode,
  }) async {
    try {
      print('📤 Sending reset password:');
      print('   User ID: $userId');
      print('   Password confirmation: $password');
      print('   Verification Code: $verificationCode');

      await apiService.resetPassword(
        userId: userId,
        password: password,
        passwordConfirmation: password,
        verificationCode: verificationCode,
      );
      print('✅ Reset password API call successful');
    } on DioException catch (e) {
      print('🔴 Reset Password Error: ${e.response?.statusCode}');
      print('🔴 Response Data: ${e.response?.data}');

      if (e.response?.statusCode == 404) {
        throw ServerException(
          e.response?.data['message'] ??
              'User not found with provided identifier',
        );
      } else if (e.response?.statusCode == 422) {
        // Validation error from backend
        final responseData = e.response?.data;
        String errorMessage = 'Password validation failed';

        // Try to extract detailed validation errors from backend
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('message')) {
            errorMessage = responseData['message'] as String;
          } else if (responseData.containsKey('errors')) {
            final errors = responseData['errors'] as Map<String, dynamic>;
            // Check all error fields
            final allErrors = <String>[];
            errors.forEach((field, fieldErrors) {
              if (fieldErrors is List && fieldErrors.isNotEmpty) {
                allErrors.add('$field: ${fieldErrors.first}');
              }
            });
            if (allErrors.isNotEmpty) {
              errorMessage = allErrors.join(', ');
            }
          }
        }
        throw ValidationException(errorMessage);
      } else if (e.response?.statusCode == 400) {
        throw ValidationException(
          e.response?.data['message'] ?? 'Invalid request',
        );
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          e.response?.data['message'] ?? 'Unauthorized',
        );
      } else if (e.response?.statusCode == 500) {
        throw ServerException(e.response?.data['message'] ?? 'Server error');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else {
        throw ServerException(e.message ?? 'Unknown error occurred');
      }
    }
  }

  @override
  Future<void> updateLanguagePreference(String languageCode) async {
    try {
      await apiService.updateUserProfile({'languagePreference': languageCode});
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw ValidationException(
          e.response?.data['message'] ?? 'Validation error',
        );
      } else if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          e.response?.data['message'] ?? 'Unauthorized',
        );
      } else if (e.response?.statusCode == 500) {
        throw ServerException(e.response?.data['message'] ?? 'Server error');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else {
        throw ServerException(e.message ?? 'Unknown error occurred');
      }
    }
  }
}
