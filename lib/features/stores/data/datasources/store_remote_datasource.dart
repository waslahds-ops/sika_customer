import '../../../../core/network/dio_client.dart';
import '../models/store_models.dart';

abstract class StoreRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<StoreModel>> getStores({
    int? categoryId,
    double? latitude,
    double? longitude,
    String? search,
    bool excludeSpecialCategories = false,
  });
  Future<List<StoreModel>> getPopularStores();
  Future<StoreModel> getStoreById(int storeId);
  Future<List<StoreModel>> getNearbyStores({
    required double latitude,
    required double longitude,
    double radius,
  });
  Future<List<ProductModel>> getProductsByStore(int storeId);
  Future<ProductModel> getProductById(int productId);
  Future<List<ProductModel>> searchProducts({
    required String query,
    int? storeId,
    String? category,
  });
  Future<List<ProductModel>> getFlashDeals();
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final DioClient dioClient;

  StoreRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await dioClient.get('/public/categories/main');
    final List<dynamic> data =
        response.data['categories'] ?? response.data['data'] ?? response.data;
    return data.map((json) => CategoryModel.fromJson(json)).toList();
  }

  @override
  Future<List<StoreModel>> getStores({
    int? categoryId,
    double? latitude,
    double? longitude,
    String? search,
    bool excludeSpecialCategories = false,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (categoryId != null) queryParameters['category_id'] = categoryId;
    if (latitude != null) queryParameters['latitude'] = latitude;
    if (longitude != null) queryParameters['longitude'] = longitude;
    if (search != null) queryParameters['search'] = search;
    if (excludeSpecialCategories) queryParameters['exclude_special'] = 1;

    final response = await dioClient.get(
      '/public/stores',
      queryParameters: queryParameters,
    );
    final List<dynamic> data =
        response.data['stores'] ?? response.data['data'] ?? response.data;

    try {
      final stores = data.map((json) {
        return StoreModel.fromJson(json);
      }).toList();
      return stores;
    } catch (e, stackTrace) {
      print('❌ Error parsing stores: $e');
      print('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<List<StoreModel>> getPopularStores() async {
    try {
      // Fetch from the popular-by-rating endpoint
      final response = await dioClient.get('/public/stores/popular-by-rating');
      final List<dynamic> data =
          response.data['stores'] ?? response.data['data'] ?? response.data;

      try {
        final stores = data.map((json) {
          return StoreModel.fromJson(json);
        }).toList();
        return stores;
      } catch (e, stackTrace) {
        print('❌ Error parsing popular stores: $e');
        print('❌ Stack trace: $stackTrace');
        rethrow;
      }
    } catch (e) {
      // Fallback: If the dedicated endpoint doesn't exist, use regular stores and sort by order count
      print('⚠️ Popular stores endpoint not available, using fallback...');
      try {
        final response = await dioClient.get('/public/stores');
        final List<dynamic> data =
            response.data['stores'] ?? response.data['data'] ?? response.data;

        final stores = data.map((json) => StoreModel.fromJson(json)).toList();

        // Sort by order count (assuming storeId or similar field exists)
        // If the API returns order counts, sort by that; otherwise sort by rating
        stores.sort((a, b) {
          // Try to sort by rating as a proxy for popularity
          final aRating = a.ratingAvg ?? 0.0;
          final bRating = b.ratingAvg ?? 0.0;
          return bRating.compareTo(aRating); // Descending order
        });

        return stores;
      } catch (fallbackError) {
        print('❌ Fallback also failed: $fallbackError');
        rethrow;
      }
    }
  }

  @override
  Future<StoreModel> getStoreById(int storeId) async {
    final response = await dioClient.get('/public/stores/$storeId');
    return StoreModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<List<StoreModel>> getNearbyStores({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  }) async {
    final response = await dioClient.get(
      '/stores/nearby',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      },
    );
    final List<dynamic> data =
        response.data['stores'] ?? response.data['data'] ?? response.data;
    return data.map((json) => StoreModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> getProductsByStore(int storeId) async {
    try {
      print('🔍 [PRODUCTS] Fetching for store: $storeId at ${DateTime.now()}');
      print(
        '🔍 [PRODUCTS] DioClient base URL: ${dioClient.dio.options.baseUrl}',
      );

      print('🔍 [PRODUCTS] About to call API...');

      final response = await dioClient
          .get('/public/stores/$storeId/products')
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('❌ [PRODUCTS] TIMEOUT after 10 seconds for store $storeId');
              throw Exception('API timeout after 10 seconds');
            },
          );

      print(
        '🔍 [PRODUCTS] Response received at ${DateTime.now()}: ${response.statusCode}',
      );

      print('🔍 [PRODUCTS] Full response: ${response.data}');

      final List<dynamic> data =
          response.data['products'] ?? response.data['data'] ?? response.data;

      print('🔍 [PRODUCTS] Data parsed: ${data.length} items');

      if (data.isNotEmpty) {
        print('🔍 [PRODUCTS] First product sample: ${data.first}');
      }

      final products = data
          .map((json) {
            try {
              return ProductModel.fromJson(json);
            } catch (e) {
              print('⚠️ [PRODUCTS] Error parsing product: $e');
              // Skip products that fail to parse
              return null;
            }
          })
          .whereType<ProductModel>()
          .toList();

      print(
        '✅ [PRODUCTS] Loaded ${products.length} products for store $storeId',
      );

      return products;
    } catch (e, stackTrace) {
      print('❌ [PRODUCTS] Error: $e');
      print('❌ [PRODUCTS] Stack: $stackTrace');

      // Check if it's a relationship error from backend
      if (e.toString().contains('relationship') ||
          e.toString().contains('category')) {
        print('⚠️ [PRODUCTS] Backend relationship error detected');
        print(
          '⚠️ [PRODUCTS] This is a backend issue. Fix the Product model relationships',
        );
      }

      rethrow;
    }
  }

  @override
  Future<ProductModel> getProductById(int productId) async {
    final response = await dioClient.get('/public/products/$productId');
    return ProductModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<List<ProductModel>> searchProducts({
    required String query,
    int? storeId,
    String? category,
  }) async {
    final queryParameters = <String, dynamic>{'query': query};
    if (storeId != null) queryParameters['store_id'] = storeId;
    if (category != null) queryParameters['category'] = category;

    final response = await dioClient.get(
      '/products/search',
      queryParameters: queryParameters,
    );
    final List<dynamic> data =
        response.data['products'] ?? response.data['data'] ?? response.data;
    return data.map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> getFlashDeals() async {
    try {
      final response = await dioClient.get('/public/flash-deals');
      final List<dynamic> data =
          response.data['deals'] ?? response.data['data'] ?? response.data;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      print('❌ Error fetching flash deals: $e');
      // Return empty list if no deals available
      return [];
    }
  }
}
