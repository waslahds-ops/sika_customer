import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/api_service.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final ApiService apiService;
  final DioClient dioClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.apiService,
    required this.dioClient,
  });

  @override
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
  }) async {
    try {
      final result = await remoteDataSource.register(
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

      // Save access token if present
      if (result['access_token'] != null) {
        final token = result['access_token'] as String;
        await localDataSource.saveToken(token);
        // Set token in both ApiService and DioClient for authenticated requests
        apiService.setAuthToken(token);
        dioClient.setAuthToken(token);
      }

      // Save user data with access token if present
      if (result['user'] != null) {
        final userData = Map<String, dynamic>.from(result['user']);
        // Add access_token to user data
        if (result['access_token'] != null) {
          userData['access_token'] = result['access_token'];
        }
        await localDataSource.saveUserData(userData);
      }

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> login({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );

      // Save access token if present
      if (result['access_token'] != null) {
        final token = result['access_token'] as String;
        await localDataSource.saveToken(token);
        // Set token in both ApiService and DioClient for authenticated requests
        apiService.setAuthToken(token);
        dioClient.setAuthToken(token);
      }

      // Save user data with access token if present
      if (result['user'] != null) {
        final userData = Map<String, dynamic>.from(result['user']);
        // Add access_token to user data
        if (result['access_token'] != null) {
          userData['access_token'] = result['access_token'];
        }
        await localDataSource.saveUserData(userData);
      }

      return Right(result);
    } on UnauthorizedException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(e.message, e.userId));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Try to logout from server, but don't fail if it errors
      try {
        await remoteDataSource.logout();
      } catch (e) {
        print('⚠️ Server logout failed, but continuing with local cleanup: $e');
      }

      // Always clear local data regardless of server response
      await localDataSource.deleteToken();
      await localDataSource.deleteUserData();
      // Remove token from ApiService
      apiService.removeAuthToken();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    return await remoteDataSource.sendOTP(phoneNumber);
  }

  @override
  Future<Map<String, dynamic>> resendOTP(String phoneNumber) async {
    return await remoteDataSource.resendOTP(phoneNumber);
  }

  @override
  Future<Map<String, dynamic>> verifyOTP({
    required String phoneNumber,
    required String otp,
  }) async {
    final result = await remoteDataSource.verifyOTP(
      phoneNumber: phoneNumber,
      otp: otp,
    );

    // Save access token if present
    if (result['data']?['access_token'] != null) {
      final token = result['data']['access_token'] as String;
      await localDataSource.saveToken(token);
      // Set token in both ApiService and DioClient for authenticated requests
      apiService.setAuthToken(token);
      dioClient.setAuthToken(token);
    } else if (result['access_token'] != null) {
      final token = result['access_token'] as String;
      await localDataSource.saveToken(token);
      apiService.setAuthToken(token);
      dioClient.setAuthToken(token);
    }

    // Save user data if present
    if (result['data']?['user'] != null) {
      final userData = Map<String, dynamic>.from(result['data']['user']);
      await localDataSource.saveUserData(userData);
    } else if (result['user'] != null) {
      final userData = Map<String, dynamic>.from(result['user']);
      await localDataSource.saveUserData(userData);
    }

    return result;
  }

  // Legacy methods
  @override
  Future<Either<Failure, void>> sendVerificationCode(int userId) async {
    try {
      await remoteDataSource.sendVerificationCode(userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyCode({
    required int userId,
    required String code,
    bool isPasswordReset = false,
  }) async {
    try {
      final result = await remoteDataSource.verifyCode(
        userId: userId,
        code: code,
        isPasswordReset: isPasswordReset,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(userModel.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? email,
    String? firstName,
    String? lastName,
    String? profileImage,
    File? profileImageFile,
  }) async {
    try {
      final result = await remoteDataSource.updateProfile(
        email: email,
        firstName: firstName,
        lastName: lastName,
        profileImage: profileImage,
        profileImageFile: profileImageFile,
      );

      // Update local storage with new user data
      if (result['user'] != null) {
        final userData = Map<String, dynamic>.from(result['user']);
        // Preserve access_token from current stored data
        final currentData = await localDataSource.getUserData();
        if (currentData?['access_token'] != null) {
          userData['access_token'] = currentData!['access_token'];
        }
        await localDataSource.saveUserData(userData);
      }

      // Return updated user entity
      final userModel = UserModel.fromJson(result['user']);
      return Right(userModel.toEntity());
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message));
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<String?> getStoredToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<void> saveToken(String token) async {
    await localDataSource.saveToken(token);
  }

  @override
  Future<void> deleteToken() async {
    await localDataSource.deleteToken();
  }

  @override
  Future<Map<String, dynamic>?> getStoredUserData() async {
    return await localDataSource.getUserData();
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await localDataSource.saveUserData(userData);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> requestPasswordReset({
    String? email,
    String? phoneNumber,
    String? fcmToken,
  }) async {
    try {
      final result = await remoteDataSource.requestPasswordReset(
        email: email,
        phoneNumber: phoneNumber,
        fcmToken: fcmToken,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required int userId,
    required String password,
    required String verificationCode,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        userId: userId,
        password: password,
        verificationCode: verificationCode,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateLanguagePreference(
    String languageCode,
  ) async {
    try {
      await remoteDataSource.updateLanguagePreference(languageCode);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> saveVerificationCode(String code) async {
    await localDataSource.saveVerificationCode(code);
  }

  @override
  Future<String?> getVerificationCode() async {
    return await localDataSource.getVerificationCode();
  }

  @override
  Future<void> deleteVerificationCode() async {
    await localDataSource.deleteVerificationCode();
  }

  @override
  Future<void> saveVerificationCodeTimestamp(int timestamp) async {
    await localDataSource.saveVerificationCodeTimestamp(timestamp);
  }

  @override
  Future<int?> getVerificationCodeTimestamp() async {
    return await localDataSource.getVerificationCodeTimestamp();
  }
}
