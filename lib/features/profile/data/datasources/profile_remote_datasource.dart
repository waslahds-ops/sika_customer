import '../../../../core/network/dio_client.dart';
import '../models/profile_models.dart';

abstract class ProfileRemoteDataSource {
  Future<CustomerModel> getCustomerProfile();
  Future<CustomerModel> updateCustomerProfile({String? phoneNumber});
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> getAddressById(int addressId);
  Future<AddressModel> createAddress({
    required String label,
    required String address,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  });
  Future<AddressModel> updateAddress({
    required int addressId,
    String? label,
    String? address,
    double? latitude,
    double? longitude,
  });
  Future<void> deleteAddress(int addressId);
  Future<AddressModel> setDefaultAddress(int addressId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient dioClient;

  ProfileRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<CustomerModel> getCustomerProfile() async {
    final response = await dioClient.get('/customer/profile');
    return CustomerModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<CustomerModel> updateCustomerProfile({String? phoneNumber}) async {
    final response = await dioClient.put(
      '/customer/profile',
      data: {'phone_number': phoneNumber},
    );
    return CustomerModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<List<AddressModel>> getAddresses() async {
    try {
      final response = await dioClient.get('/customer/addresses');

      // Normalize response into a List<Map<String, dynamic>>
      dynamic raw = response.data['data'] ?? response.data;

      List<dynamic> listData;

      if (raw is List) {
        listData = raw;
      } else if (raw is Map<String, dynamic>) {
        // Sometimes the API returns a single item wrapped as a map
        // or an object with a nested list under different keys.
        // Try common keys first, otherwise wrap the map as a single-item list.
        if (raw['addresses'] is List) {
          listData = raw['addresses'];
        } else if (raw['data'] is List) {
          listData = raw['data'];
        } else {
          listData = [raw];
        }
      } else {
        // Unexpected shape: try to convert to list or return empty
        listData = [];
      }

      final addresses = <AddressModel>[];
      for (var i = 0; i < listData.length; i++) {
        try {
          final item = listData[i];
          if (item is Map<String, dynamic>) {
            final address = AddressModel.fromJson(item);
            addresses.add(address);
          } else {
            print('⚠️ Skipping non-map address item at $i: $item');
          }
        } catch (e) {
          print('❌ Failed to parse address $i: $e');
          // Continue parsing other items rather than rethrowing
        }
      }

      return addresses;
    } catch (e, stackTrace) {
      print('❌ DataSource error: $e');
      ('Stack: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<AddressModel> getAddressById(int addressId) async {
    final response = await dioClient.get('/customer/addresses/$addressId');
    return AddressModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<AddressModel> createAddress({
    required String label,
    required String address,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    final payload = {
      'label': label,
      'full_address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault ? 1 : 0,
    };

    try {
      final response = await dioClient.post(
        '/customer/addresses',
        data: payload,
      );
      return AddressModel.fromJson(response.data['data'] ?? response.data);
    } catch (e, st) {
      print('❌ DataSource createAddress failed: $e');
      print('Stack: $st');

      // Try a fallback payload if backend expects 'address' instead of 'full_address'
      final altPayload = {
        'label': label,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'is_default': isDefault ? 1 : 0,
      };
      try {
        final altResponse = await dioClient.post(
          '/customer/addresses',
          data: altPayload,
        );
        return AddressModel.fromJson(
          altResponse.data['data'] ?? altResponse.data,
        );
      } catch (e2, st2) {
        print('❌ DataSource createAddress fallback failed: $e2');
        print('Stack: $st2');
        rethrow;
      }
    }
  }

  @override
  Future<AddressModel> updateAddress({
    required int addressId,
    String? label,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    final response = await dioClient.put(
      '/customer/addresses/$addressId',
      data: {
        if (label != null) 'label': label,
        if (address != null) 'full_address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
    return AddressModel.fromJson(response.data['data'] ?? response.data);
  }

  @override
  Future<void> deleteAddress(int addressId) async {
    await dioClient.delete('/customer/addresses/$addressId');
  }

  @override
  Future<AddressModel> setDefaultAddress(int addressId) async {
    final response = await dioClient.post(
      '/customer/addresses/$addressId/set-default',
    );
    return AddressModel.fromJson(response.data['data'] ?? response.data);
  }
}
