class Order {
  final int orderId;
  final int customerId;
  final int? agentId;
  final String? agentName;
  final String? agentPhone;
  final String? agentVehicleType;
  final String? agentVehiclePlate;
  final int storeId;
  final String status;
  final double totalAmount;
  final double deliveryFee;
  final double? commissionFee;
  final int customerAddressId;
  final String? specialInstructions;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? preparedAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;

  Order({
    required this.orderId,
    required this.customerId,
    this.agentId,
    this.agentName,
    this.agentPhone,
    this.agentVehicleType,
    this.agentVehiclePlate,
    required this.storeId,
    required this.status,
    required this.totalAmount,
    required this.deliveryFee,
    this.commissionFee,
    required this.customerAddressId,
    this.specialInstructions,
    required this.createdAt,
    this.acceptedAt,
    this.preparedAt,
    this.pickedUpAt,
    this.deliveredAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'] as int,
      customerId: json['customer_id'] as int,
      agentId: json['agent_id'] as int?,
      agentName:
          json['agent_name'] as String? ?? json['agent']?['name'] as String?,
      agentPhone:
          json['agent_phone'] as String? ?? json['agent']?['phone'] as String?,
      agentVehicleType:
          json['agent_vehicle_type'] as String? ??
          json['agent']?['vehicle_type'] as String?,
      agentVehiclePlate:
          json['agent_vehicle_plate'] as String? ??
          json['agent']?['vehicle_plate'] as String?,
      storeId: json['store_id'] as int,
      status: json['status'] as String,
      totalAmount: double.parse(json['total_amount'].toString()),
      deliveryFee: double.parse(json['delivery_fee'].toString()),
      commissionFee: json['commission_fee'] != null
          ? double.parse(json['commission_fee'].toString())
          : null,
      customerAddressId: json['customer_address_id'] as int,
      specialInstructions: json['special_instructions'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      preparedAt: json['prepared_at'] != null
          ? DateTime.parse(json['prepared_at'] as String)
          : null,
      pickedUpAt: json['picked_up_at'] != null
          ? DateTime.parse(json['picked_up_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'customer_id': customerId,
      'agent_id': agentId,
      'agent_name': agentName,
      'agent_phone': agentPhone,
      'agent_vehicle_type': agentVehicleType,
      'agent_vehicle_plate': agentVehiclePlate,
      'store_id': storeId,
      'status': status,
      'total_amount': totalAmount,
      'delivery_fee': deliveryFee,
      'commission_fee': commissionFee,
      'customer_address_id': customerAddressId,
      'special_instructions': specialInstructions,
      'created_at': createdAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'prepared_at': preparedAt?.toIso8601String(),
      'picked_up_at': pickedUpAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }
}
