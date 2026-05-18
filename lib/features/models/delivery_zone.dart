class DeliveryZone {
  final int zoneId;
  final String zoneName;
  final Map<String, dynamic>? geofence;
  final double deliveryFee;
  final bool isActive;

  DeliveryZone({
    required this.zoneId,
    required this.zoneName,
    this.geofence,
    required this.deliveryFee,
    required this.isActive,
  });

  factory DeliveryZone.fromJson(Map<String, dynamic> json) {
    return DeliveryZone(
      zoneId: json['zone_id'] as int,
      zoneName: json['zone_name'] as String,
      geofence: json['geofence'] != null
          ? Map<String, dynamic>.from(json['geofence'] as Map)
          : null,
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zone_id': zoneId,
      'zone_name': zoneName,
      'geofence': geofence,
      'delivery_fee': deliveryFee,
      'is_active': isActive ? 1 : 0,
    };
  }
}
