import '../../domain/entities/profile_entities.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.customerId,
    required super.userId,
    super.phoneNumber,
    super.defaultAddressId,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      customerId: json['customer_id'] as int,
      userId: json['user_id'] as int,
      phoneNumber: json['phone_number'] as String?,
      defaultAddressId: json['default_address_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'user_id': userId,
      'phone_number': phoneNumber,
      'default_address_id': defaultAddressId,
    };
  }
}

class AddressModel extends AddressEntity {
  const AddressModel({
    required super.addressId,
    required super.userId,
    required super.label,
    required super.address,
    super.latitude,
    super.longitude,
    required super.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      addressId: json['address_id'] as int,
      userId: json['user_id'] as int,
      label: json['label'] as String,
      // Some APIs return 'full_address', others return 'address'.
      address: (json['full_address'] ?? json['address']) as String,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      isDefault: json['is_default'] == 1 || json['is_default'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address_id': addressId,
      'user_id': userId,
      'label': label,
      'full_address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_default': isDefault ? 1 : 0,
    };
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
