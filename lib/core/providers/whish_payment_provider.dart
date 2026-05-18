import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/whish_payment_service.dart';

// Provider for Whish Payment Service
final whishPaymentServiceProvider = Provider<WhishPaymentService>((ref) {
  return WhishPaymentService();
});

// State for Whish Payment
class WhishPaymentState {
  final bool isLoading;
  final String? errorMessage;
  final double? balance;
  final String? paymentUrl;
  final WhishPaymentStatus? paymentStatus;

  WhishPaymentState({
    this.isLoading = false,
    this.errorMessage,
    this.balance,
    this.paymentUrl,
    this.paymentStatus,
  });

  WhishPaymentState copyWith({
    bool? isLoading,
    String? errorMessage,
    double? balance,
    String? paymentUrl,
    WhishPaymentStatus? paymentStatus,
  }) {
    return WhishPaymentState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      balance: balance ?? this.balance,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
}

// Notifier for Whish Payment
class WhishPaymentNotifier extends StateNotifier<WhishPaymentState> {
  final WhishPaymentService _service;

  WhishPaymentNotifier(this._service) : super(WhishPaymentState());

  /// Get account balance
  Future<void> getBalance() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _service.getBalance();
      if (response.status && response.data != null) {
        state = state.copyWith(
          isLoading: false,
          balance: response.data!.balance,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.dialog?.message ?? 'Failed to get balance',
        );
      }
    } on WhishPaymentException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  /// Create payment and get payment URL
  Future<bool> createPayment({
    required double amount,
    required WhishCurrency currency,
    required String invoice,
    required int orderId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // TODO: Replace with your actual callback and redirect URLs
      const baseUrl = 'YOUR_APP_BASE_URL'; // Replace with actual URL

      final response = await _service.createPayment(
        amount: amount,
        currency: currency.value,
        invoice: invoice,
        externalId: orderId,
        successCallbackUrl: '$baseUrl/payment/success',
        failureCallbackUrl: '$baseUrl/payment/failure',
        successRedirectUrl: '$baseUrl/payment/success',
        failureRedirectUrl: '$baseUrl/payment/failure',
      );

      if (response.status && response.collectUrl != null) {
        state = state.copyWith(
          isLoading: false,
          paymentUrl: response.collectUrl,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.dialog?.message ?? 'Failed to create payment',
        );
        return false;
      }
    } on WhishPaymentException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred',
      );
      return false;
    }
  }

  /// Check payment status
  Future<void> checkPaymentStatus({
    required WhishCurrency currency,
    required int orderId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _service.getPaymentStatus(
        currency: currency.value,
        externalId: orderId,
      );

      if (response.status && response.collectStatus != null) {
        state = state.copyWith(
          isLoading: false,
          paymentStatus: WhishPaymentStatus.fromString(response.collectStatus!),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              response.dialog?.message ?? 'Failed to check payment status',
        );
      }
    } on WhishPaymentException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Reset state
  void reset() {
    state = WhishPaymentState();
  }
}

// Provider for Whish Payment Notifier
final whishPaymentProvider =
    StateNotifierProvider<WhishPaymentNotifier, WhishPaymentState>((ref) {
      final service = ref.read(whishPaymentServiceProvider);
      return WhishPaymentNotifier(service);
    });
