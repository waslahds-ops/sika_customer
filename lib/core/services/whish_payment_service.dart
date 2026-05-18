import 'package:dio/dio.dart';

class WhishPaymentService {
  final Dio _dio;

  // Configuration
  static const String _liveBaseUrl = 'https://whish.money/itel-service/api';
  static const String _sandboxBaseUrl =
      'https://api.sandbox.whish.money/itel-service/api';

  // Use sandbox for development, live for production
  static const bool _useSandbox = true;
  static String get baseUrl => _useSandbox ? _sandboxBaseUrl : _liveBaseUrl;

  // Credentials (to be provided by Whish)
  static const String _channel = 'YOUR_CHANNEL'; // Replace with actual channel
  static const String _secret = 'YOUR_SECRET'; // Replace with actual secret
  static const String _websiteUrl =
      'YOUR_WEBSITE_URL'; // Replace with actual website URL

  // Singleton pattern
  static final WhishPaymentService _instance = WhishPaymentService._internal();
  factory WhishPaymentService() => _instance;

  WhishPaymentService._internal()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'channel': _channel,
            'secret': _secret,
            'websiteurl': _websiteUrl,
          },
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  /// Get account balance
  /// Returns the real balance of the account (LBP only)
  Future<WhishBalanceResponse> getBalance() async {
    try {
      final response = await _dio.get('/payment/account/balance');
      return WhishBalanceResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw WhishPaymentException(
        message:
            e.response?.data['dialog']?['message'] ?? 'Failed to get balance',
        code: e.response?.data['code'],
      );
    }
  }

  /// Create payment and get payment URL
  /// Returns collectUrl where user will complete the payment
  Future<WhishPaymentResponse> createPayment({
    required double amount,
    required String currency, // LBP, USD
    required String invoice,
    required int externalId,
    required String successCallbackUrl,
    required String failureCallbackUrl,
    required String successRedirectUrl,
    required String failureRedirectUrl,
  }) async {
    try {
      final response = await _dio.post(
        '/payment/whish',
        data: {
          'amount': amount,
          'currency': currency,
          'invoice': invoice,
          'externalId': externalId,
          'successCallbackUrl': successCallbackUrl,
          'failureCallbackUrl': failureCallbackUrl,
          'successRedirectUrl': successRedirectUrl,
          'failureRedirectUrl': failureRedirectUrl,
        },
      );
      return WhishPaymentResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw WhishPaymentException(
        message:
            e.response?.data['dialog']?['message'] ??
            'Failed to create payment',
        code: e.response?.data['code'],
      );
    }
  }

  /// Get payment status
  /// Returns the collect status (success, failed, pending)
  Future<WhishStatusResponse> getPaymentStatus({
    required String currency,
    required int externalId,
  }) async {
    try {
      final response = await _dio.post(
        '/payment/collect/status',
        data: {'currency': currency, 'externalId': externalId},
      );
      return WhishStatusResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw WhishPaymentException(
        message:
            e.response?.data['dialog']?['message'] ??
            'Failed to get payment status',
        code: e.response?.data['code'],
      );
    }
  }
}

// ==================== MODELS ====================

class WhishBalanceResponse {
  final bool status;
  final String? code;
  final WhishDialog? dialog;
  final BalanceDetails? data;

  WhishBalanceResponse({
    required this.status,
    this.code,
    this.dialog,
    this.data,
  });

  factory WhishBalanceResponse.fromJson(Map<String, dynamic> json) {
    return WhishBalanceResponse(
      status: json['status'] ?? false,
      code: json['code'],
      dialog: json['dialog'] != null
          ? WhishDialog.fromJson(json['dialog'])
          : null,
      data: json['data'] != null
          ? BalanceDetails.fromJson(json['data']['balanceDetails'])
          : null,
    );
  }
}

class BalanceDetails {
  final double balance;

  BalanceDetails({required this.balance});

  factory BalanceDetails.fromJson(Map<String, dynamic> json) {
    return BalanceDetails(balance: (json['balance'] ?? 0).toDouble());
  }
}

class WhishPaymentResponse {
  final bool status;
  final String? code;
  final WhishDialog? dialog;
  final String? collectUrl;

  WhishPaymentResponse({
    required this.status,
    this.code,
    this.dialog,
    this.collectUrl,
  });

  factory WhishPaymentResponse.fromJson(Map<String, dynamic> json) {
    return WhishPaymentResponse(
      status: json['status'] ?? false,
      code: json['code'],
      dialog: json['dialog'] != null
          ? WhishDialog.fromJson(json['dialog'])
          : null,
      collectUrl: json['data']?['collectUrl'],
    );
  }
}

class WhishStatusResponse {
  final bool status;
  final String? code;
  final WhishDialog? dialog;
  final String? collectStatus; // success, failed, pending
  final String? payerPhoneNumber;

  WhishStatusResponse({
    required this.status,
    this.code,
    this.dialog,
    this.collectStatus,
    this.payerPhoneNumber,
  });

  factory WhishStatusResponse.fromJson(Map<String, dynamic> json) {
    return WhishStatusResponse(
      status: json['status'] ?? false,
      code: json['code'],
      dialog: json['dialog'] != null
          ? WhishDialog.fromJson(json['dialog'])
          : null,
      collectStatus: json['data']?['collectStatus'],
      payerPhoneNumber: json['data']?['payerPhoneNumber'],
    );
  }
}

class WhishDialog {
  final String? title;
  final String? message;

  WhishDialog({this.title, this.message});

  factory WhishDialog.fromJson(Map<String, dynamic> json) {
    return WhishDialog(title: json['title'], message: json['message']);
  }
}

class WhishPaymentException implements Exception {
  final String message;
  final String? code;

  WhishPaymentException({required this.message, this.code});

  @override
  String toString() => 'WhishPaymentException: $message (Code: $code)';
}

// ==================== HELPER ENUMS ====================

enum WhishCurrency {
  lbp('LBP'),
  usd('USD');

  final String value;
  const WhishCurrency(this.value);
}

enum WhishPaymentStatus {
  success,
  failed,
  pending;

  static WhishPaymentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return WhishPaymentStatus.success;
      case 'failed':
        return WhishPaymentStatus.failed;
      case 'pending':
        return WhishPaymentStatus.pending;
      default:
        return WhishPaymentStatus.pending;
    }
  }
}
