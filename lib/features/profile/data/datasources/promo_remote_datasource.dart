import '../../../../core/network/dio_client.dart';

abstract class PromoRemoteDataSource {
  Future<List<dynamic>> getCustomerPromoCodes();
  Future<List<dynamic>> getUsedPromoCodes();
  Future<Map<String, dynamic>> validatePromoCode({
    required String code,
    double? orderAmount,
  });
  Future<Map<String, dynamic>> applyPromoCode({
    required int id,
    required int orderId,
  });
}

class PromoRemoteDataSourceImpl implements PromoRemoteDataSource {
  final DioClient dioClient;

  PromoRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<dynamic>> getCustomerPromoCodes() async {
    final response = await dioClient.get('/customer/promo-codes');
    // Expect response.data['data'] to be a list
    final data = response.data;
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<dynamic>();
    }
    return [];
  }

  @override
  Future<List<dynamic>> getUsedPromoCodes() async {
    final response = await dioClient.get('/customer/promo-codes/used');
    final data = response.data;
    if (data is Map && data.containsKey('data')) {
      return (data['data'] as List).cast<dynamic>();
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> validatePromoCode({
    required String code,
    double? orderAmount,
  }) async {
    final payload = <String, dynamic>{'code': code};
    if (orderAmount != null) payload['order_amount'] = orderAmount;

    final response = await dioClient.post(
      '/customer/promo-codes/validate',
      data: payload,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return {'success': false, 'message': 'Invalid response'};
  }

  @override
  Future<Map<String, dynamic>> applyPromoCode({
    required int id,
    required int orderId,
  }) async {
    final response = await dioClient.post(
      '/customer/promo-codes/$id/apply',
      data: {'order_id': orderId},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return {'success': false, 'message': 'Invalid response'};
  }
}
