import '../../domain/entities/order_entities.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.orderId,
    required super.customerId,
    required super.storeId,
    super.storeName,
    super.deliveryAgentId,
    super.promoId,
    required super.orderNumber,
    required super.subtotal,
    required super.deliveryFee,
    required super.discount,
    required super.totalAmount,
    required super.status,
    super.deliveryAddress,
    super.deliveryLatitude,
    super.deliveryLongitude,
    super.specialInstructions,
    super.estimatedDeliveryTime,
    required super.createdAt,
    super.deliveredAt,
    super.agentId,
    super.agentName,
    super.agentPhone,
    super.agentVehicleType,
    super.agentVehiclePlate,
    super.canTrack,
    super.hasQrCode,
    super.qrCodeExpiresAt,
    super.qrCodeUrl,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    try {
      return OrderModel(
        orderId: _parseInt(json['order_id']) ?? 0,
        customerId: _parseInt(json['customer_id']) ?? 0,
        storeId: _parseInt(json['store_id']) ?? 0,
        storeName: json['store_name'] as String? ?? json['store']?['name'] as String?,
        deliveryAgentId: _parseInt(json['delivery_agent_id']),
        promoId: _parseInt(json['promo_id']),
        orderNumber:
            json['order_number'] as String? ??
            'Order #${json['order_id'] ?? 'Unknown'}',
        subtotal: _parseDouble(json['subtotal']) ?? 0.0,
        deliveryFee: _parseDouble(json['delivery_fee']) ?? 0.0,
        discount: _parseDouble(json['discount']) ?? 0.0,
        totalAmount: _parseDouble(json['total_amount']) ?? 0.0,
        status: json['status'] as String? ?? 'pending',
        deliveryAddress: json['delivery_address'] as String?,
        deliveryLatitude: _parseDouble(json['delivery_latitude']),
        deliveryLongitude: _parseDouble(json['delivery_longitude']),
        specialInstructions: json['special_instructions'] as String?,
        estimatedDeliveryTime: json['estimated_delivery_time'] as String?,
        createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
        deliveredAt: _parseDateTime(json['delivered_at']),
        // Agent fields - support nested 'agent' object or flat fields
        agentId: _parseInt(json['agent_id']) ?? _parseInt(json['agent']?['id']),
        agentName:
            json['agent_name'] as String? ?? json['agent']?['name'] as String?,
        agentPhone:
            json['agent_phone'] as String? ??
            json['agent']?['phone'] as String?,
        agentVehicleType:
            json['agent_vehicle_type'] as String? ??
            json['agent']?['vehicle_type'] as String?,
        agentVehiclePlate:
            json['agent_vehicle_plate'] as String? ??
            json['agent']?['vehicle_plate'] as String?,
        canTrack: json['can_track'] as bool? ?? false,
        hasQrCode: json['has_qr_code'] as bool? ?? false,
        qrCodeExpiresAt: _parseDateTime(json['qr_code_expires_at']),
        qrCodeUrl: json['qr_code_url'] as String?,
      );
    } catch (e) {
      print('❌ OrderModel.fromJson error: $e');
      print('   JSON data keys: ${json.keys.toList()}');
      print(
        '   Sample values: ${json.entries.take(5).map((e) => '${e.key}: ${e.value}').join(', ')}',
      );
      rethrow;
    }
  }

  // Helper methods for safe parsing
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is num) return value.toDouble();
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'customer_id': customerId,
      'store_id': storeId,
      'store_name': storeName,
      'delivery_agent_id': deliveryAgentId,
      'promo_id': promoId,
      'order_number': orderNumber,
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'discount': discount,
      'total_amount': totalAmount,
      'status': status,
      'delivery_address': deliveryAddress,
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
      'special_instructions': specialInstructions,
      'estimated_delivery_time': estimatedDeliveryTime,
      'created_at': createdAt.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'can_track': canTrack,
      'has_qr_code': hasQrCode,
      'qr_code_expires_at': qrCodeExpiresAt?.toIso8601String(),
      'qr_code_url': qrCodeUrl,
    };
  }
}

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.orderItemId,
    required super.orderId,
    required super.productId,
    required super.productNameAr,
    required super.productNameEn,
    required super.quantity,
    required super.price,
    required super.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      orderItemId: json['order_item_id'] as int,
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      productNameAr: json['product_name_ar'] as String,
      productNameEn: json['product_name_en'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_item_id': orderItemId,
      'order_id': orderId,
      'product_id': productId,
      'product_name_ar': productNameAr,
      'product_name_en': productNameEn,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
    };
  }
}

class OrderTrackingModel extends OrderTrackingEntity {
  const OrderTrackingModel({
    required super.trackingId,
    required super.orderId,
    required super.status,
    super.location,
    required super.timestamp,
  });

  factory OrderTrackingModel.fromJson(Map<String, dynamic> json) {
    return OrderTrackingModel(
      trackingId: json['tracking_id'] as int,
      orderId: json['order_id'] as int,
      status: json['status'] as String,
      location: json['location'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tracking_id': trackingId,
      'order_id': orderId,
      'status': status,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
