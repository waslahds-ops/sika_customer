import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/order_models.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder({
    required int storeId,
    required int addressId,
    required List<Map<String, dynamic>> items,
    String? specialInstructions,
    String? promoCode,
  });

  Future<List<OrderModel>> getOrders({String? tab});
  Future<OrderModel> getOrderById(int orderId);
  Future<OrderModel> cancelOrder(int orderId);
  Future<String?> getStoreNameById(int storeId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final DioClient dioClient;

  OrderRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<OrderModel> createOrder({
    required int storeId,
    required int addressId,
    required List<Map<String, dynamic>> items,
    String? specialInstructions,
    String? promoCode,
  }) async {
    // Validate items before sending
    if (items.isEmpty) {
      throw ServerException(
        'Cart is empty. Cannot create order without items.',
      );
    }

    // Log items for debugging

    final payload = {
      'store_id': storeId,
      'address_id': addressId,
      'payment_method': 'wallet', // Default payment method
      'items': items,
      if (specialInstructions != null && specialInstructions.isNotEmpty)
        'special_instructions': specialInstructions,
      if (promoCode != null && promoCode.isNotEmpty) 'promo_code': promoCode,
    };

    try {
      print('📤 [ORDER] Creating order with payload: $payload');
      final response = await dioClient.post('/orders', data: payload);
      print('📥 [ORDER] Order created successfully: ${response.statusCode}');
      print('📥 [ORDER] Full response: ${response.data}');

      final orderData = response.data['data'] ?? response.data;
      print('📥 [ORDER] Parsing order data: $orderData');

      return OrderModel.fromJson(orderData);
    } catch (e, st) {
      // Log the exception details for debugging
      print('❌ [ORDER] Error creating order:');
      print('   Exception: $e');
      print('   Stack Trace: $st');
      print('   Payload: $payload');
      rethrow;
    }
  }

  @override
  Future<List<OrderModel>> getOrders({String? tab}) async {
    try {
      final queryParameters = <String, dynamic>{};
      // Don't pass tab parameter - fetch all orders and filter on client side
      // if (tab != null) queryParameters['tab'] = tab;

      print('📤 Fetching all orders');

      final response = await dioClient.get(
        '/orders',
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      print('✅ Orders response received: ${response.statusCode}');
      print('📦 Response type: ${response.data.runtimeType}');

      // Handle different response structures
      dynamic rawData = response.data;

      // If response has 'data' key, use it
      if (rawData is Map && rawData.containsKey('data')) {
        print('ℹ️ Found data key in response');
        rawData = rawData['data'];
      }

      // If rawData is not a list, it might be empty or an error
      if (rawData is! List) {
        print('⚠️ Response data is not a list: ${rawData.runtimeType}');
        // Return empty list if data is null or not a list
        return [];
      }

      final List<dynamic> data = rawData;
      print('✅ Parsed ${data.length} orders');

      final orders = <OrderModel>[];
      for (int i = 0; i < data.length; i++) {
        try {
          final order = OrderModel.fromJson(data[i] as Map<String, dynamic>);
          orders.add(order);
        } catch (e) {
          print('⚠️ Error parsing order $i: $e');
          print('   Order data: ${data[i]}');
          // Skip this order instead of failing completely
          continue;
        }
      }

      print('✅ Successfully parsed ${orders.length}/${data.length} orders');
      return orders;
    } catch (e) {
      print('❌ Remote: Error fetching orders - $e');
      print('   Error type: ${e.runtimeType}');
      print('   Stack trace: $e');
      rethrow;
    }
  }

  @override
  Future<OrderModel> getOrderById(int orderId) async {
    final response = await dioClient.get('/orders/$orderId');
    return OrderModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<OrderModel> cancelOrder(int orderId) async {
    final response = await dioClient.post('/orders/$orderId/cancel');
    return OrderModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<String?> getStoreNameById(int storeId) async {
    try {
      final response = await dioClient.get('/public/stores/$storeId');
      final storeData = response.data['data'] ?? response.data;
      return storeData['name'] as String?;
    } catch (e) {
      print('⚠️ Failed to fetch store name for store $storeId: $e');
      return null;
    }
  }
}
