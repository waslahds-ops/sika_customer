import '../../../../core/utils/api_service.dart';
import '../../../../features/models/models.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentMethod> storePaymentMethod({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
  });

  Future<List<PaymentMethod>> getPaymentMethods();
  Future<PaymentMethod> getPaymentMethod(int paymentMethodId);
  Future<void> deletePaymentMethod(int paymentMethodId);
  Future<PaymentMethod> verifyPaymentMethod(int paymentMethodId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiService apiService;

  PaymentRemoteDataSourceImpl({required this.apiService});

  @override
  Future<PaymentMethod> storePaymentMethod({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String cardholderName,
  }) async {
    final response = await apiService.storePaymentMethod(
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      cvv: cvv,
      cardholderName: cardholderName,
    );

    // Handle both response formats: {data: {...}} or {...}
    final data = response['data'] ?? response;
    return PaymentMethod.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods() async {
    final response = await apiService.getPaymentMethods();

    return response.map((json) => PaymentMethod.fromJson(json)).toList();
  }

  @override
  Future<PaymentMethod> getPaymentMethod(int paymentMethodId) async {
    final response = await apiService.getPaymentMethod(paymentMethodId);

    final data = response['data'] ?? response;
    return PaymentMethod.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deletePaymentMethod(int paymentMethodId) async {
    await apiService.deletePaymentMethod(paymentMethodId);
  }

  @override
  Future<PaymentMethod> verifyPaymentMethod(int paymentMethodId) async {
    final response = await apiService.verifyPaymentMethod(paymentMethodId);

    final data = response['data'] ?? response;
    return PaymentMethod.fromJson(data as Map<String, dynamic>);
  }
}
