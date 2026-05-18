class Address {
  final int addressId;
  final int userId;
  final String label;
  final double latitude;
  final double longitude;
  final String fullAddress;
  final bool isDefault;

  Address({
    required this.addressId,
    required this.userId,
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.fullAddress,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressId: json['address_id'] as int,
      userId: json['user_id'] as int,
      label: json['label'] as String,
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      fullAddress: json['full_address'] as String,
      isDefault: json['is_default'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address_id': addressId,
      'user_id': userId,
      'label': label,
      'latitude': latitude,
      'longitude': longitude,
      'full_address': fullAddress,
      'is_default': isDefault,
    };
  }
}
