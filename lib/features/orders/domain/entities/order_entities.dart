import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  final int orderId;
  final int customerId;
  final int storeId;
  final String? storeName;
  final int? deliveryAgentId;
  final int? promoId;
  final String orderNumber;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double totalAmount;
  final String status;
  final String? deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String? specialInstructions;
  final String? estimatedDeliveryTime;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  // Agent details (optional)
  final int? agentId;
  final String? agentName;
  final String? agentPhone;
  final String? agentVehicleType;
  final String? agentVehiclePlate;
  // New tracking and QR fields
  final bool canTrack;
  final bool hasQrCode;
  final DateTime? qrCodeExpiresAt;
  final String? qrCodeUrl;

  const OrderEntity({
    required this.orderId,
    required this.customerId,
    required this.storeId,
    this.storeName,
    this.deliveryAgentId,
    this.promoId,
    required this.orderNumber,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.totalAmount,
    required this.status,
    this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.specialInstructions,
    this.estimatedDeliveryTime,
    required this.createdAt,
    this.deliveredAt,
    this.agentId,
    this.agentName,
    this.agentPhone,
    this.agentVehicleType,
    this.agentVehiclePlate,
    this.canTrack = false,
    this.hasQrCode = false,
    this.qrCodeExpiresAt,
    this.qrCodeUrl,
  });

  @override
  List<Object?> get props => [
    orderId,
    customerId,
    storeId,
    storeName,
    deliveryAgentId,
    promoId,
    orderNumber,
    subtotal,
    deliveryFee,
    discount,
    totalAmount,
    status,
    deliveryAddress,
    deliveryLatitude,
    deliveryLongitude,
    specialInstructions,
    estimatedDeliveryTime,
    createdAt,
    deliveredAt,
    agentId,
    agentName,
    agentPhone,
    agentVehicleType,
    agentVehiclePlate,
    canTrack,
    hasQrCode,
    qrCodeExpiresAt,
  ];

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'customerId': customerId,
      'storeId': storeId,
      'deliveryAgentId': deliveryAgentId,
      'promoId': promoId,
      'orderNumber': orderNumber,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'totalAmount': totalAmount,
      'status': status,
      'deliveryAddress': deliveryAddress,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
      'specialInstructions': specialInstructions,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'createdAt': createdAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'agentId': agentId,
      'agentName': agentName,
      'agentPhone': agentPhone,
      'agentVehicleType': agentVehicleType,
      'agentVehiclePlate': agentVehiclePlate,
      'canTrack': canTrack,
      'hasQrCode': hasQrCode,
      'qrCodeExpiresAt': qrCodeExpiresAt?.toIso8601String(),
      'qrCodeUrl': qrCodeUrl,
    };
  }

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    return OrderEntity(
      orderId: json['orderId'] as int,
      customerId: json['customerId'] as int,
      storeId: json['storeId'] as int,
      deliveryAgentId: json['deliveryAgentId'] as int?,
      promoId: json['promoId'] as int?,
      orderNumber: json['orderNumber'] as String,
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      deliveryAddress: json['deliveryAddress'] as String?,
      deliveryLatitude: json['deliveryLatitude'] as double?,
      deliveryLongitude: json['deliveryLongitude'] as double?,
      specialInstructions: json['specialInstructions'] as String?,
      estimatedDeliveryTime: json['estimatedDeliveryTime'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
      agentId: json['agentId'] as int?,
      agentName: json['agentName'] as String?,
      agentPhone: json['agentPhone'] as String?,
      agentVehicleType: json['agentVehicleType'] as String?,
      agentVehiclePlate: json['agentVehiclePlate'] as String?,
      canTrack: json['canTrack'] as bool? ?? false,
      hasQrCode: json['hasQrCode'] as bool? ?? false,
      qrCodeExpiresAt: json['qrCodeExpiresAt'] != null
          ? DateTime.parse(json['qrCodeExpiresAt'] as String)
          : null,
      qrCodeUrl: json['qrCodeUrl'] as String?,
    );
  }

  bool get isCompleted {
    return status.toLowerCase() == 'delivered' ||
        status.toLowerCase() == 'completed';
  }
}

class OrderItemEntity extends Equatable {
  final int orderItemId;
  final int orderId;
  final int productId;
  final String productNameAr;
  final String productNameEn;
  final int quantity;
  final double price;
  final double subtotal;

  const OrderItemEntity({
    required this.orderItemId,
    required this.orderId,
    required this.productId,
    required this.productNameAr,
    required this.productNameEn,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  @override
  List<Object?> get props => [
    orderItemId,
    orderId,
    productId,
    productNameAr,
    productNameEn,
    quantity,
    price,
    subtotal,
  ];
}

class OrderTrackingEntity extends Equatable {
  final int trackingId;
  final int orderId;
  final String status;
  final String? location;
  final DateTime timestamp;

  const OrderTrackingEntity({
    required this.trackingId,
    required this.orderId,
    required this.status,
    this.location,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [trackingId, orderId, status, location, timestamp];
}
