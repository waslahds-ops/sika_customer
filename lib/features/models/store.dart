class Store {
  final int storeId;
  final int merchantId;
  final int categoryId;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? coverUrl;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double? ratingAvg;
  final double deliveryFee;
  final double minOrderAmount;
  final String? estimatedDeliveryTime;
  final bool isOpen;
  final bool isActive;
  final Map<String, dynamic>? workingHours;

  Store({
    required this.storeId,
    required this.merchantId,
    required this.categoryId,
    required this.name,
    this.description,
    this.logoUrl,
    this.coverUrl,
    this.address,
    this.latitude,
    this.longitude,
    this.ratingAvg,
    required this.deliveryFee,
    required this.minOrderAmount,
    this.estimatedDeliveryTime,
    required this.isOpen,
    required this.isActive,
    this.workingHours,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      storeId: json['store_id'] as int,
      merchantId: json['merchant_id'] as int,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude'] != null
          ? double.parse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.parse(json['longitude'].toString())
          : null,
      ratingAvg: json['rating_avg'] != null
          ? double.parse(json['rating_avg'].toString())
          : null,
      deliveryFee: double.parse(json['delivery_fee'].toString()),
      minOrderAmount: double.parse(json['min_order_amount'].toString()),
      estimatedDeliveryTime: json['estimated_delivery_time'] as String?,
      isOpen: json['is_open'] as bool,
      isActive: json['is_active'] as bool,
      workingHours: json['working_hours'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'merchant_id': merchantId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'cover_url': coverUrl,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating_avg': ratingAvg,
      'delivery_fee': deliveryFee,
      'min_order_amount': minOrderAmount,
      'estimated_delivery_time': estimatedDeliveryTime,
      'is_open': isOpen,
      'is_active': isActive,
      'working_hours': workingHours,
    };
  }
}
