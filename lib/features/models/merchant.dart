class Merchant {
  final int merchantId;
  final String storeName;
  final String? description;
  final String? logoUrl;
  final String? address;
  final Map<String, dynamic>? workingHours;
  final bool isActive;

  Merchant({
    required this.merchantId,
    required this.storeName,
    this.description,
    this.logoUrl,
    this.address,
    this.workingHours,
    required this.isActive,
  });

  factory Merchant.fromJson(Map<String, dynamic> json) {
    return Merchant(
      merchantId: json['merchant_id'] as int,
      storeName: json['store_name'] as String,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      address: json['address'] as String?,
      workingHours: json['working_hours'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchant_id': merchantId,
      'store_name': storeName,
      'description': description,
      'logo_url': logoUrl,
      'address': address,
      'working_hours': workingHours,
      'is_active': isActive,
    };
  }
}
