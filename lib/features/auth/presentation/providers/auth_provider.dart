import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sika_customer/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/firebase_messaging_service.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/send_verification_code_usecase.dart';
import '../../domain/usecases/verify_code_usecase.dart';

class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? errorMessage;
  final bool isAuthenticated;
  final String? verificationId;
  final String? pendingPhoneNumber;
  final String? pendingEmail;
  final int? pendingUserId;
  final String? pendingVerificationCode;

  AuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
    this.isAuthenticated = false,
    this.verificationId,
    this.pendingPhoneNumber,
    this.pendingEmail,
    this.pendingUserId,
    this.pendingVerificationCode,
  });

  AuthState copyWith({
    bool? isLoading,
    UserEntity? user,
    String? errorMessage,
    bool? isAuthenticated,
    String? verificationId,
    String? pendingPhoneNumber,
    String? pendingEmail,
    int? pendingUserId,
    String? pendingVerificationCode,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      verificationId: verificationId ?? this.verificationId,
      pendingPhoneNumber: pendingPhoneNumber ?? this.pendingPhoneNumber,
      pendingEmail: pendingEmail ?? this.pendingEmail,
      pendingUserId: pendingUserId ?? this.pendingUserId,
      pendingVerificationCode:
          pendingVerificationCode ?? this.pendingVerificationCode,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final SendVerificationCodeUseCase sendVerificationCodeUseCase;
  final VerifyCodeUseCase verifyCodeUseCase;
  final AuthRepository authRepository;

  AuthNotifier({
    required this.ref,
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.updateProfileUseCase,
    required this.sendVerificationCodeUseCase,
    required this.verifyCodeUseCase,
    required this.authRepository,
  }) : super(AuthState());

  Future<void> login({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await loginUseCase(
      LoginParams(email: email, phoneNumber: phoneNumber, password: password),
    );

    result.fold(
      (failure) {
        // If it's a forbidden failure with userId, store it for verification
        int? userId;
        if (failure is ForbiddenFailure && failure.userId != null) {
          userId = failure.userId;
        }

        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
          isAuthenticated: false,
          pendingUserId: userId,
        );
      },
      (data) async {
        // Get current user after login
        await getCurrentUser();

        // Send FCM token to server
        await _sendFCMTokenToServer();

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> register({
    required String phoneNumber,
    String? email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
    String? storeName,
    String? vehicleType,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Get FCM token before registration
    final fcmService = FirebaseMessagingService();
    final fcmToken = await fcmService.getToken();

    final result = await registerUseCase(
      RegisterParams(
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        role: role,
        firstName: firstName,
        lastName: lastName,
        storeName: storeName,
        vehicleType: vehicleType,
        fcmToken: fcmToken,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
          isAuthenticated: false,
        );
      },
      (data) async {
        // Extract user_id from registration response

        // Try multiple possible paths for user_id
        dynamic userIdValue =
            data['user']?['user_id'] ??
            data['data']?['user_id'] ??
            data['user_id'];

        // Convert to int if it's a string
        int? userId;
        if (userIdValue != null) {
          if (userIdValue is int) {
            userId = userIdValue;
          } else if (userIdValue is String) {
            userId = int.tryParse(userIdValue);
          }
        }

        if (userId == null) {
          print(
            '⚠️ WARNING: Could not extract user_id from registration response',
          );
          print('📦 Full Response: $data');
        }

        // Check if token was provided (already saved by repository)
        final hasToken = data['access_token'] != null;
        if (hasToken) {
          print('🔑 Token was provided in registration response');
        }

        // TODO: Remove in production - Show OTP code for testing
        final verificationCode = data['verification_code'];
        if (verificationCode != null) {
          print('🔐 VERIFICATION CODE: $verificationCode');
        }

        // If token exists, get current user data
        if (hasToken) {
          await getCurrentUser();
          print('✅ User data loaded after registration');
        }

        // Store pending user_id for verification flow
        print('💾 Storing pending user ID: $userId');
        state = state.copyWith(
          isLoading: false,
          pendingUserId: userId,
          isAuthenticated: hasToken, // Authenticate if backend returned token
          errorMessage: null,
        );
        print('✅ State updated with pending user ID: ${state.pendingUserId}');
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    final result = await logoutUseCase(const NoParams());

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
      },
      (_) {
        state = AuthState(isAuthenticated: false);
        // Clear auth state without closing app - navigation handled by caller
      },
    );
  }

  Future<void> getCurrentUser() async {
    final wasAuthenticated = state.isAuthenticated;
    final result = await getCurrentUserUseCase(const NoParams());

    result.fold(
      (failure) {
        // Only mark as unauthenticated if this is a 401/403 (auth failure)
        // Otherwise keep the existing auth state
        if (failure.message.contains('401') ||
            failure.message.contains('403') ||
            failure.message.contains('Unauthenticated')) {
          state = state.copyWith(user: null, isAuthenticated: false);
        } else {
          // Keep authenticated state but clear user data
          state = state.copyWith(
            user: null,
            isAuthenticated: wasAuthenticated,
            errorMessage: failure.message,
          );
        }
      },
      (user) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          errorMessage: null,
        );
      },
    );
  }

  Future<bool> updateProfile({
    String? email,
    String? firstName,
    String? lastName,
    String? profileImage,
    File? profileImageFile,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await updateProfileUseCase(
      UpdateProfileParams(
        email: email,
        firstName: firstName,
        lastName: lastName,
        profileImage: profileImage,
        profileImageFile: profileImageFile,
      ),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    // First, try to load user from local storage
    final storedUserData = await authRepository.getStoredUserData();
    final storedToken = await authRepository.getStoredToken();

    if (storedUserData != null) {
      try {
        // Ensure we have a proper Map<String, dynamic>
        final userData = Map<String, dynamic>.from(storedUserData);

        // Extract customer data if it exists
        final customerData = userData['customer'];
        final customer = customerData != null
            ? Map<String, dynamic>.from(customerData as Map)
            : null;
        // Convert stored data to UserEntity
        final user = UserEntity(
          userId: userData['id'] ?? userData['user_id'] ?? 0,
          phoneNumber: userData['phone_number']?.toString() ?? '',
          email: userData['email'] as String?,
          role: userData['role']?.toString() ?? 'customer',
          languagePreference:
              userData['language_preference']?.toString() ?? 'en',
          isVerified: userData['is_verified'] ?? false,
          accessToken: storedToken ?? userData['access_token'] as String?,
          firstName: customer?['first_name'] as String?,
          lastName: customer?['last_name'] as String?,
          profileImage: customer?['profile_image'] as String?,
          createdAt: userData['created_at'] != null
              ? DateTime.tryParse(userData['created_at'].toString())
              : null,
        );

        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
        return;
      } catch (e) {
        // If parsing fails, try to get from API
        print('Error parsing stored user data: $e');
      }
    }

    // If no stored user or parsing failed, try to get from API
    await getCurrentUser();
    state = state.copyWith(isLoading: false);
  }

  /// Send FCM token to server after authentication
  Future<void> _sendFCMTokenToServer() async {
    try {
      final fcmService = FirebaseMessagingService();
      final token = await fcmService.getToken();

      if (token != null) {
        await fcmService.sendTokenToServer(token);
      } else {
        print('⚠️ [AuthProvider] FCM Token is NULL - cannot send');
      }
    } catch (e, stackTrace) {
      print('❌ [AuthProvider] Failed to send FCM token to server: $e');
      print('Stack trace: $stackTrace');
      // Don't fail authentication if FCM token fails
    }
  }

  /// Send OTP to phone number
  Future<void> sendOTP(String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await authRepository.sendOTP(phoneNumber);
      // Ensure phone number starts with '+' for database consistency
      final normalizedPhone = phoneNumber.startsWith('+')
          ? phoneNumber
          : '+' + phoneNumber;

      state = state.copyWith(
        isLoading: false,
        pendingPhoneNumber: normalizedPhone, // Store phone for verification
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to send OTP: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Resend OTP to phone number
  Future<void> resendOTP(String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await authRepository.resendOTP(phoneNumber);
      // Ensure phone number starts with '+' for database consistency
      final normalizedPhone = phoneNumber.startsWith('+')
          ? phoneNumber
          : '+' + phoneNumber;

      state = state.copyWith(
        isLoading: false,
        pendingPhoneNumber: normalizedPhone,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to resend OTP: ${e.toString()}',
      );
      print('❌ Resend OTP error: $e');
      rethrow;
    }
  }

  /// Verify OTP code
  Future<void> verifyOTP({
    required String phoneNumber,
    required String otp,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      print('🔐 Verifying OTP for: $phoneNumber');

      // First, always try to register the user (POST to /auth/register)
      // This ensures new users are created before verification
      try {
        final registerResult = await registerUseCase(
          RegisterParams(
            phoneNumber: phoneNumber,
            password:
                'otp_verified_${phoneNumber}_${DateTime.now().millisecondsSinceEpoch}',
            role: 'customer',
            firstName: null,
            lastName: null,
            email: null,
            storeName: null,
            vehicleType: null,
            fcmToken: null,
          ),
        );

        registerResult.fold(
          (failure) {
            print('ℹ️ Registration result: ${failure.message}');
          },
          (response) {
            print('✅ User registered successfully');
            print('📦 Registration response: $response');
          },
        );
      } catch (e) {
        print('⚠️ Registration attempt error: $e');
        // Continue anyway - user might already exist
      }

      // ⭐ STEP 2: Verify OTP and get token from backend
      print('📤 Step 2: Verifying OTP with backend...');
      final otpResponse = await authRepository.verifyOTP(
        phoneNumber: phoneNumber,
        otp: otp,
      );

      // Extract user_id from OTP response
      int? userId;
      print('📋 Full OTP response: $otpResponse');

      if (otpResponse['data']?['user']?['id'] != null) {
        userId = otpResponse['data']['user']['id'] as int;
        print('✅ User ID extracted from otpResponse[data][user][id]: $userId');
      } else if (otpResponse['user']?['id'] != null) {
        userId = otpResponse['user']['id'] as int;
        print('✅ User ID extracted from otpResponse[user][id]: $userId');
      } else if (otpResponse['data']?['id'] != null) {
        userId = otpResponse['data']['id'] as int;
        print('✅ User ID extracted from otpResponse[data][id]: $userId');
      } else if (otpResponse['id'] != null) {
        userId = otpResponse['id'] as int;
        print('✅ User ID extracted from otpResponse[id]: $userId');
      } else {
        print('⚠️ User ID not found in OTP response');
        print('📋 Available keys in response: ${otpResponse.keys}');
        if (otpResponse['data'] is Map) {
          print(
            '📋 Available keys in response.data: ${(otpResponse['data'] as Map).keys}',
          );
        }
      }

      // ⭐ Token is automatically set by authRepository.verifyOTP
      final savedToken = await authRepository.getStoredToken();
      if (savedToken != null && savedToken.isNotEmpty) {
        print('✅ Token retrieved: ${savedToken.substring(0, 20)}...');
      } else {
        print('⚠️ Token not found after verification');
      }

      // ⭐ STEP 3: Get real Firebase token from Firebase Messaging
      print('🔥 Step 3: Getting real Firebase token...');
      final fcmService = FirebaseMessagingService();
      final realFcmToken = await fcmService.getToken();
      if (realFcmToken != null && realFcmToken.isNotEmpty) {
        print(
          '✅ Real FCM Token: ${realFcmToken.substring(0, 30)}... (length: ${realFcmToken.length})',
        );
      } else {
        print('⚠️ Firebase FCM Token is NULL');
      }

      // Fetch the updated user data with is_verified = true
      await getCurrentUser();

      // ⭐ STEP 4: Send FCM token with device info to backend
      print('📤 Step 4: Sending FCM token to server...');
      await _sendFCMTokenToServer();

      // Store verification details for password setup flow
      // Ensure phone number starts with '+' for database consistency
      final normalizedPhone = phoneNumber.startsWith('+')
          ? phoneNumber
          : '+' + phoneNumber;

      // If userId wasn't in OTP response, get it from the authenticated user
      if (userId == null && state.user?.userId != null) {
        userId = state.user!.userId;
        print('✅ Using User ID from getCurrentUser: $userId');
      }

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        errorMessage: null,
        pendingPhoneNumber: normalizedPhone,
        pendingUserId: userId,
        pendingVerificationCode: otp,
      );

      print('✅ OTP verification complete!');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Verification failed: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Send verification code using stored user ID (legacy)
  @Deprecated('Use sendOTP instead')
  Future<bool> sendVerificationCode() async {
    // Get user ID from either pendingUserId or current authenticated user
    int? userId = state.pendingUserId ?? state.user?.userId;

    if (userId == null) {
      state = state.copyWith(
        errorMessage: 'No user ID available for verification',
        isLoading: false,
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await sendVerificationCodeUseCase(
      SendVerificationCodeParams(userId: userId),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  /// Verify OTP code
  Future<bool> verifyCode(String code, {bool isPasswordReset = false}) async {
    // Get user ID from either pendingUserId or current authenticated user
    int? userId = state.pendingUserId ?? state.user?.userId;

    if (userId == null) {
      state = state.copyWith(
        errorMessage: 'No user found. Please try registering again.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    print('🔐 Verifying Code:');
    print('   User ID: $userId');
    print('   Code: $code');
    print('   Is Password Reset: $isPasswordReset');
    print('   Pending Phone: ${state.pendingPhoneNumber}');

    // For password reset flows the backend exposes a dedicated endpoint
    // `/auth/verify-reset-code`. Use it to verify the identifier (phone/email)
    // rather than the legacy `/auth/verify` endpoint used for registration.
    if (isPasswordReset) {
      try {
        final apiService = ref.read(apiServiceProvider);

        // Prefer phone, then email, then fallback to userId string
        final identifier = state.pendingPhoneNumber ?? state.pendingEmail ?? userId.toString();
        print('📤 Calling verify-reset-code with identifier: $identifier');

        final response = await apiService.verifyResetCode(
          identifier: identifier!,
          code: code,
        );

        print('✅ verify-reset-code response: $response');

        // Persist the verified code for use during resetPassword
        await authRepository.saveVerificationCode(code);
        await authRepository.saveVerificationCodeTimestamp(
          DateTime.now().millisecondsSinceEpoch,
        );

        state = state.copyWith(
          pendingVerificationCode: code,
          isLoading: false,
          errorMessage: null,
        );

        print('🔑 Password Reset Flow - Code verified and stored securely');
        return true;
      } catch (e) {
        print('❌ verify-reset-code failed: $e');
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Verification failed: ${e.toString()}',
        );
        return false;
      }
    }

    // Legacy verification path (registration / account verification)
    final result = await verifyCodeUseCase(
      VerifyCodeParams(
        userId: userId,
        code: code,
        isPasswordReset: isPasswordReset,
      ),
    );

    return result.fold(
      (failure) {
        print('❌ Verification Failed: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
        return false;
      },
      (data) async {
        print('✅ Verification Successful!');
        print('📦 Verification Response: $data');

        // Store verification code persistently for password reset flow
        // This ensures the code survives app restarts
        await authRepository.saveVerificationCode(code);
        await authRepository.saveVerificationCodeTimestamp(
          DateTime.now().millisecondsSinceEpoch,
        );

        state = state.copyWith(pendingVerificationCode: code);

        if (isPasswordReset) {
          // For password reset: don't authenticate, just verify code
          print('🔑 Password Reset Flow - Code verified and stored securely');
          print('💾 Verification code will persist even if app is closed');
          state = state.copyWith(isLoading: false, errorMessage: null);
          return true;
        }

        // For normal registration: authenticate user
        // Save token if provided
        if (data['access_token'] != null) {
          await authRepository.saveToken(data['access_token']);
        }

        // Get current user after verification
        await getCurrentUser();

        // Send FCM token to server
        await _sendFCMTokenToServer();

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          errorMessage: null,
          verificationId: null,
          pendingPhoneNumber: null,
          pendingEmail: null,
        );
        return true;
      },
    );
  }

  /// Skip verification and allow user to use app with limited features
  Future<void> skipVerification() async {
    // Try to get current user data
    await getCurrentUser();

    // Send FCM token
    await _sendFCMTokenToServer();

    // Mark as authenticated but user.is_verified will be false
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      errorMessage: null,
      verificationId: null,
      pendingPhoneNumber: null,
      pendingEmail: null,
    );
  }

  /// Request password reset - sends OTP code
  Future<void> requestPasswordReset({
    String? email,
    String? phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Get FCM token before requesting password reset
    final fcmService = FirebaseMessagingService();
    final fcmToken = await fcmService.getToken();

    final result = await authRepository.requestPasswordReset(
      email: email,
      phoneNumber: phoneNumber,
      fcmToken: fcmToken,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
      },
      (response) {
        // Extract user_id from response
        final userId = response['user_id'] as int?;

        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
          pendingUserId: userId,
          pendingEmail: email,
          pendingPhoneNumber: phoneNumber,
        );

        // Send verification code
        if (userId != null) {
          sendVerificationCode();
        }
      },
    );
  }

  /// Check if the stored verification code has expired
  /// Code expires after 10 minutes
  Future<bool> isVerificationCodeExpired() async {
    final timestamp = await authRepository.getVerificationCodeTimestamp();
    if (timestamp == null) {
      return true; // No timestamp, code is expired
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final ageInMinutes = (now - timestamp) / (1000 * 60);
    final isExpired = ageInMinutes > 10;

    if (isExpired) {
      print(
        '⏰ Verification code expired (age: ${ageInMinutes.toStringAsFixed(1)} minutes)',
      );
      await authRepository.deleteVerificationCode();
    } else {
      print(
        '✅ Verification code still valid (age: ${ageInMinutes.toStringAsFixed(1)} minutes, expires in: ${(10 - ageInMinutes).toStringAsFixed(1)} minutes)',
      );
    }

    return isExpired;
  }

  /// Reset password with new password
  /// Backend no longer requires verification code verification step.
  /// Just need user ID from the forgot-password flow.
  Future<void> resetPassword({required String newPassword, int? userId, String? verificationCode}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Get user ID (from forgot-password flow)
    final effectiveUserId = userId ?? state.pendingUserId;

    print('🔑 Reset Password Debug:');
    print('   User ID: $effectiveUserId');
    print('   Password length: ${newPassword.length}');
    print('   Note: Verification code is no longer needed by backend');

    if (effectiveUserId == null) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Session expired. Please request password reset again.',
      );
      return;
    }

    final result = await authRepository.resetPassword(
      userId: effectiveUserId,
      password: newPassword,
      verificationCode: '', // Backend no longer needs this
    );

    result.fold(
      (failure) {
        print('❌ Reset Password Failed: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          errorMessage: _mapFailureToMessage(failure),
        );
      },
      (_) {
        print(
          '✅ Reset Password Successful',
        );
        // Clear pendingUserId and pendingVerificationCode after successful reset
        authRepository.deleteVerificationCode();

        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
          pendingUserId: null,
          pendingEmail: null,
          pendingPhoneNumber: null,
          pendingVerificationCode: null,
        );
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.message;
  }
}
