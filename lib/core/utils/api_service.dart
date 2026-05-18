import 'dart:io';
import 'package:dio/dio.dart';
import '../../features/models/models.dart';
import '../config/app_config.dart';
import '../error/exceptions.dart';

class ApiService {
  final Dio _dio;

  // Base URL configuration - loaded from .env file
  static String get baseUrl {
    return AppConfig.apiEndpoint;
  }

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: Duration(seconds: AppConfig.connectionTimeout),
          receiveTimeout: Duration(seconds: AppConfig.receiveTimeout),
          sendTimeout: Duration(seconds: AppConfig.sendTimeout),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    assert(() {
      return true;
    }());
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Only log in debug mode
          assert(() {
            return true;
          }());
          return handler.next(options);
        },
        onResponse: (response, handler) {
          assert(() {
            return true;
          }());
          return handler.next(response);
        },
        onError: (error, handler) {
          // User-friendly error messages
          String message = 'Something went wrong. Please try again.';

          if (error.response != null) {
            final statusCode = error.response!.statusCode;
            final data = error.response!.data;

            // Extract backend error message if available
            if (data is Map && data['message'] != null) {
              message = data['message'];
            } else {
              switch (statusCode) {
                case 400:
                  message = 'Invalid request. Please check your input.';
                  break;
                case 401:
                  message = 'Invalid credentials. Please try again.';
                  break;
                case 403:
                  message = 'Access denied. Please verify your account.';
                  break;
                case 404:
                  message = 'Service not found. Please contact support.';
                  break;
                case 422:
                  message = 'Validation failed. Please check your input.';
                  break;
                case 500:
                  message = 'Server error. Please try again later.';
                  break;
              }
            }
          } else if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout) {
            message = 'Connection timeout. Please check your internet.';
          } else if (error.type == DioExceptionType.connectionError) {
            message = 'No internet connection. Please try again.';
          }

          // Only print detailed errors in debug mode
          assert(() {
            if (error.response != null) {
              print('📋 Error Response Data: ${error.response?.data}');
              print('📋 Error Response Headers: ${error.response?.headers}');
            }
            return true;
          }());

          // Replace error message with user-friendly one
          error = error.copyWith(message: message);
          return handler.next(error);
        },
      ),
    );
  }

  // Set auth token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Remove auth token
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // ==================== AUTH ENDPOINTS ====================

  /// Register a new user
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
    final Map<String, dynamic> data = {
      'phone_number': phoneNumber,
      'password': password,
      'role': role,
    };

    if (email != null && email.isNotEmpty) data['email'] = email;
    if (firstName != null && firstName.isNotEmpty) {
      data['first_name'] = firstName;
    }
    if (lastName != null && lastName.isNotEmpty) data['last_name'] = lastName;
    if (storeName != null && storeName.isNotEmpty) {
      data['store_name'] = storeName;
    }
    if (vehicleType != null && vehicleType.isNotEmpty) {
      data['vehicle_type'] = vehicleType;
    }
    if (fcmToken != null && fcmToken.isNotEmpty) data['fcm_token'] = fcmToken;

    final response = await _dio.post('/auth/register', data: data);
    return response.data;
  }

  /// Login user with email or phone number
  Future<Map<String, dynamic>> login({
    String? email,
    String? phoneNumber,
    required String password,
  }) async {
    assert(
      email != null || phoneNumber != null,
      'Either email or phoneNumber must be provided',
    );

    final Map<String, dynamic> data = {'password': password};
    if (email != null) {
      data['email'] = email;
    } else if (phoneNumber != null) {
      data['phone_number'] = phoneNumber;
    }

    final response = await _dio.post('/auth/login', data: data);
    return response.data;
  }

  /// Logout user
  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  /// Send FCM token to server with device information
  Future<void> sendFCMToken(
    String token, {
    String? deviceName,
    String? deviceType,
  }) async {
    try {
      // Get actual device info if not provided
      final actualDeviceName = deviceName ?? _getDefaultDeviceName();
      final actualDeviceType = deviceType ?? _getDeviceType();

      final response = await _dio.put(
        '/notifications/update-token',
        data: {
          'fcm_token': token,
          'device_name': actualDeviceName,
          'device_type': actualDeviceType,
        },
      );

      // ignore: avoid_print
      print('✅ FCM token sent to server successfully');
      // ignore: avoid_print
      print('   Response: ${response.statusCode}');
      // ignore: avoid_print
      print('   Device: $actualDeviceName ($actualDeviceType)');
      // ignore: avoid_print
      print('   Message: ${response.data}');
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error sending FCM token to server: $e');
      rethrow;
    }
  }

  /// Get default device name based on platform
  String _getDefaultDeviceName() {
    if (Platform.isAndroid) {
      return 'Android Device';
    } else if (Platform.isIOS) {
      return 'iOS Device';
    } else if (Platform.isWindows) {
      return 'Windows Device';
    } else if (Platform.isLinux) {
      return 'Linux Device';
    } else if (Platform.isMacOS) {
      return 'macOS Device';
    }
    return 'Unknown Device';
  }

  /// Get device type (platform)
  String _getDeviceType() {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isLinux) {
      return 'linux';
    } else if (Platform.isMacOS) {
      return 'macos';
    }
    return 'unknown';
  }

  /// Send OTP to phone number
  Future<Map<String, dynamic>> sendOTP(
    String phoneNumber, {
    String purpose = 'login',
  }) async {
    print('📤 Sending OTP to: $phoneNumber (Purpose: $purpose)');
    final response = await _dio.post(
      '/auth/send-otp',
      data: {'phone_number': phoneNumber, 'purpose': purpose},
    );
    print('📥 Send OTP Response: ${response.data}');
    print('📥 Status Code: ${response.statusCode}');

    // Check if backend returns OTP for testing (common in development)
    if (response.data is Map) {
      if (response.data.containsKey('otp')) {
        print('🔐 TEST MODE - OTP Code: ${response.data['otp']}');
      }
      if (response.data.containsKey('code')) {
        print('🔐 TEST MODE - OTP Code: ${response.data['code']}');
      }
      if (response.data.containsKey('verification_code')) {
        print('🔐 TEST MODE - OTP Code: ${response.data['verification_code']}');
      }
    }

    return response.data;
  }

  /// Resend OTP to phone number
  Future<Map<String, dynamic>> resendOTP(
    String phoneNumber, {
    String purpose = 'login',
  }) async {
    print('📤 Resending OTP to: $phoneNumber (Purpose: $purpose)');
    final response = await _dio.post(
      '/auth/resend-otp',
      data: {'phone_number': phoneNumber, 'purpose': purpose},
    );
    return response.data;
  }

  /// Verify OTP code
  Future<Map<String, dynamic>> verifyOTP({
    required String phoneNumber,
    required String otp,
  }) async {
    final requestData = {'phone_number': phoneNumber, 'otp_code': otp};
    print('🔐 Verifying OTP for: $phoneNumber');
    print('📤 Request data: $requestData');
    print('📤 Code value: "$otp" (length: ${otp.length})');

    final response = await _dio.post('/auth/verify-otp', data: requestData);

    print('✅ Verify OTP response: ${response.data}');
    return response.data;
  }

  /// Legacy method for backward compatibility
  @Deprecated('Use sendOTP instead')
  Future<void> sendVerificationCode(int userId) async {
    await _dio.post('/auth/resend-verification', data: {'user_id': userId});
  }

  /// Legacy method for backward compatibility
  @Deprecated('Use verifyOTP instead')
  Future<Map<String, dynamic>> verifyCode({
    required int userId,
    required String code,
    bool isPasswordReset = false,
  }) async {
    print('📤 API Call - Verify Code:');
    print('   Endpoint: POST /auth/verify');
    print('   User ID: $userId');
    print('   Code: $code');
    print('   Is Password Reset: $isPasswordReset');

    try {
      final response = await _dio.post(
        '/auth/verify',
        data: {
          'user_id': userId,
          'code': code,
          'is_password_reset': isPasswordReset,
        },
      );
      print('✅ Verify Code API Response: ${response.data}');
      return response.data;
    } catch (e) {
      print('❌ Verify Code API Error: $e');
      rethrow;
    }
  }

  // ==================== USER ENDPOINTS ====================

  /// Get current user profile
  Future<User> getCurrentUser() async {
    final response = await _dio.get('/auth/profile');
    return User.fromJson(response.data['user']);
  }

  /// Update user profile
  Future<User> updateUserProfile(Map<String, dynamic> data) async {
    final response = await _dio.put('/auth/profile', data: data);
    return User.fromJson(response.data['data']);
  }

  /// Update complete profile (user + customer data)
  Future<Map<String, dynamic>> updateProfile({
    String? email,
    String? firstName,
    String? lastName,
    String? profileImage,
    File? profileImageFile,
  }) async {
    try {
      // If image file is provided, use multipart form data
      if (profileImageFile != null) {
        final fileName = profileImageFile.path.split('/').last;
        final formData = FormData.fromMap({
          if (email != null) 'email': email,
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          'profile_image': await MultipartFile.fromFile(
            profileImageFile.path,
            filename: fileName,
          ),
        });
        final response = await _dio.put('/auth/profile', data: formData);

        // Check if response has error status
        if (response.data is Map) {
          if (response.data['status'] == 'error' ||
              response.data['error'] != null) {
            throw ValidationException(
              response.data['message'] ??
                  response.data['error'] ??
                  'Profile update failed',
            );
          }
        }
        return response.data;
      }

      // Otherwise use regular JSON
      final response = await _dio.put(
        '/auth/profile',
        data: {
          if (email != null) 'email': email,
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          if (profileImage != null) 'profile_image': profileImage,
        },
      );

      // Check if response has error status
      if (response.data is Map) {
        if (response.data['status'] == 'error' ||
            response.data['error'] != null) {
          throw ValidationException(
            response.data['message'] ??
                response.data['error'] ??
                'Profile update failed',
          );
        }
      }
      return response.data;
    } on DioException catch (e) {
      // Re-throw as custom exception for proper handling
      if (e.response?.statusCode == 422) {
        throw ValidationException(
          e.response?.data?['message'] ?? 'Validation failed',
        );
      }
      rethrow;
    }
  }

  /// Upload profile image (uses PUT /auth/profile endpoint)
  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    final fileName = imageFile.path.split('/').last;
    final formData = FormData.fromMap({
      'profile_image': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });

    final response = await _dio.put('/auth/profile', data: formData);
    return response.data;
  }

  /// Request password reset - sends verification code
  Future<Map<String, dynamic>> requestPasswordReset({
    String? email,
    String? phoneNumber,
  }) async {
    final Map<String, dynamic> data = {};
    if (email != null) {
      data['email'] = email;
    } else if (phoneNumber != null) {
      data['phone_number'] = phoneNumber;
    }

    final response = await _dio.post('/auth/forgot-password', data: data);
    return response.data;
  }

  /// Verify reset code - DEPRECATED: Endpoint removed from backend
  /// Now verification happens automatically during forgot-password
  /// This method is kept for backward compatibility but does nothing
  Future<Map<String, dynamic>> verifyResetCode({
    required String identifier,
    required String code,
  }) async {
    print('ℹ️ verifyResetCode is deprecated - backend no longer requires verification step');
    return {'status': 'success', 'message': 'Code verified (deprecated method)'};
  }

  /// Reset password with new password
  Future<void> resetPassword({
    required int userId,
    required String password,
    required String passwordConfirmation,
    required String verificationCode,
  }) async {
    await _dio.post(
      '/auth/reset-password',
      data: {
        'user_id': userId,
        'password': password,
      },
    );
  }

  // ==================== STORE ENDPOINTS ====================

  /// Get all stores (public endpoint)
  Future<List<Store>> getStores({
    int? categoryId,
    double? latitude,
    double? longitude,
    String? search,
  }) async {
    final response = await _dio.get(
      '/customer/stores',
      queryParameters: {
        if (categoryId != null) 'category_id': categoryId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (search != null) 'search': search,
      },
    );
    return (response.data['data'] as List)
        .map((json) => Store.fromJson(json))
        .toList();
  }

  /// Get store by ID (public endpoint)
  Future<Store> getStore(int storeId) async {
    final response = await _dio.get('/stores/$storeId');
    return Store.fromJson(response.data['data']);
  }

  // ==================== PRODUCT ENDPOINTS ====================

  /// Get products by store ID (public endpoint)
  Future<List<Product>> getProductsByStore(int storeId) async {
    final response = await _dio.get('/stores/$storeId/products');
    return (response.data['data'] as List)
        .map((json) => Product.fromJson(json))
        .toList();
  }

  /// Get aisles (categories) for a store with products grouped by category
  /// Used specifically for Sika Fresh stores
  Future<Map<String, dynamic>> getStoreAisles(int storeId) async {
    final response = await _dio.get('/stores/$storeId/aisles');
    return response.data;
  }

  /// Get special offers for a Sika Fresh store
  /// Returns list of products with discounts
  Future<Map<String, dynamic>> getStoreOffers(int storeId) async {
    final response = await _dio.get('/stores/$storeId/offers');
    return response.data;
  }

  /// Get buy-again items (previous order items) for a Sika Fresh store
  /// Returns items from customer's order history
  Future<Map<String, dynamic>> getStoreBuyAgain(int storeId) async {
    final response = await _dio.get('/stores/$storeId/buy-again');
    return response.data;
  }

  // ==================== ORDER ENDPOINTS ====================

  /// Create new order (requires isVerified)
  Future<Order> createOrder({
    required int storeId,
    required int addressId,
    required List<Map<String, dynamic>> items,
    String? specialInstructions,
    String? promoCode,
  }) async {
    final response = await _dio.post(
      '/orders',
      data: {
        'store_id': storeId,
        'address_id': addressId,
        'items': items,
        if (specialInstructions != null)
          'special_instructions': specialInstructions,
        if (promoCode != null) 'promo_code': promoCode,
      },
    );
    return Order.fromJson(response.data['data']);
  }

  /// Get all orders for current customer
  Future<List<Order>> getOrders({String? tab}) async {
    final response = await _dio.get(
      '/orders',
      queryParameters: {if (tab != null) 'tab': tab},
    );
    return (response.data['data'] as List)
        .map((json) => Order.fromJson(json))
        .toList();
  }

  /// Get order by ID
  Future<Order> getOrder(int orderId) async {
    final response = await _dio.get('/orders/$orderId');
    return Order.fromJson(response.data['data']);
  }

  /// Cancel order
  Future<void> cancelOrder(int orderId) async {
    await _dio.post('/orders/$orderId/cancel');
  }

  /// Track order location
  Future<Map<String, dynamic>> trackOrder(int orderId) async {
    final response = await _dio.get('/orders/$orderId/track');
    return response.data['data'] as Map<String, dynamic>;
  }

  /// Get QR code for order
  Future<Map<String, dynamic>> getOrderQrCode(int orderId) async {
    final response = await _dio.get('/orders/$orderId/qr-code');
    return response.data['data'] as Map<String, dynamic>;
  }

  /// Submit order review
  Future<void> submitOrderReview(
    int orderId, {
    required int rating,
    String? comment,
  }) async {
    await _dio.post(
      '/orders/$orderId/reviews',
      data: {'rating': rating, 'comment': comment},
    );
  }

  /// Get order reviews
  Future<List<Map<String, dynamic>>> getOrderReviews(int orderId) async {
    final response = await _dio.get('/orders/$orderId/reviews');
    return (response.data['data'] as List).cast<Map<String, dynamic>>();
  }

  // ==================== NOTIFICATION ENDPOINTS ====================

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _dio.post('/notifications/subscribe', data: {'topic': topic});
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _dio.post('/notifications/unsubscribe', data: {'topic': topic});
  }

  // ==================== DELIVERY AGENT ENDPOINTS ====================

  /// Apply as delivery agent (public route)
  Future<Map<String, dynamic>> applyAsDeliveryAgent({
    required String name,
    required String email,
    required String phoneNumber,
    required String vehicleType,
    String? licenseNumber,
  }) async {
    final response = await _dio.post(
      '/delivery-agent/apply',
      data: {
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'vehicle_type': vehicleType,
        if (licenseNumber != null) 'license_number': licenseNumber,
      },
    );
    return response.data;
  }

  /// Get delivery agent profile
  Future<DeliveryAgent> getAgentProfile() async {
    final response = await _dio.get('/agent/profile');
    return DeliveryAgent.fromJson(response.data['data']);
  }

  /// Update agent location
  Future<void> updateAgentLocation({
    required double latitude,
    required double longitude,
  }) async {
    await _dio.put(
      '/agent/location',
      data: {'latitude': latitude, 'longitude': longitude},
    );
  }

  /// Update agent status
  Future<void> updateAgentStatus(String status) async {
    await _dio.put('/agent/status', data: {'status': status});
  }

  /// Get available orders for agent
  Future<List<Order>> getAvailableOrders() async {
    final response = await _dio.get('/agent/available-orders');
    return (response.data['data'] as List)
        .map((json) => Order.fromJson(json))
        .toList();
  }

  /// Accept order (for delivery agent)
  Future<Order> acceptOrder(int orderId) async {
    final response = await _dio.post('/agent/orders/$orderId/accept');
    return Order.fromJson(response.data['data']);
  }

  /// Generic GET method for other modules
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      print('GET Error: $path - ${e.message}');
      rethrow;
    }
  }

  /// Generic POST method for other modules
  Future<dynamic> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      print('POST Error: $path - ${e.message}');
      rethrow;
    }
  }

  /// Get all active promotions/deals/discounts
  Future<List<Map<String, dynamic>>> getPromotions() async {
    try {
      final response = await _dio.get('/promotions');
      final data = response.data;

      // Handle different response formats
      if (data is Map<String, dynamic>) {
        if (data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else if (data['promotions'] is List) {
          return List<Map<String, dynamic>>.from(data['promotions']);
        }
      } else if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }

      return [];
    } on DioException catch (e) {
      print('GET Promotions Error: ${e.message}');
      return []; // Return empty list on error
    }
  }

  // ==================== PAYMENT ENDPOINTS ====================

  /// Store a new payment method (add card)
  Future<Map<String, dynamic>> storePaymentMethod({
    required String cardNumber,
    required String expiryDate, // MM/YY format
    required String cvv,
    required String cardholderName,
  }) async {
    final response = await _dio.post(
      '/customer/payments',
      data: {
        'card_number': cardNumber,
        'expiry_date': expiryDate,
        'cvv': cvv,
        'cardholder_name': cardholderName,
      },
    );
    return response.data;
  }

  /// Get all payment methods for current user
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    final response = await _dio.get('/customer/payments');

    if (response.data is Map<String, dynamic>) {
      final data = response.data['data'];
      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      }
    }

    return [];
  }

  /// Get payment method by ID
  Future<Map<String, dynamic>> getPaymentMethod(int paymentId) async {
    final response = await _dio.get('/customer/payments/$paymentId');
    return response.data['data'] ?? response.data;
  }

  /// Delete payment method
  Future<void> deletePaymentMethod(int paymentId) async {
    await _dio.delete('/customer/payments/$paymentId');
  }

  /// Verify payment method (for testing)
  Future<Map<String, dynamic>> verifyPaymentMethod(int paymentId) async {
    final response = await _dio.post('/customer/payments/$paymentId/verify');
    return response.data;
  }
}
