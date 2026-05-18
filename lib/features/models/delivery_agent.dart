class DeliveryAgent {
  final int agentId;
  final String status;
  final double? currentLat;
  final double? currentLng;
  final String? vehicleType;
  final String? vehiclePlate;
  final String? idDocument;
  final bool isApproved;
  final double totalEarnings;

  DeliveryAgent({
    required this.agentId,
    required this.status,
    this.currentLat,
    this.currentLng,
    this.vehicleType,
    this.vehiclePlate,
    this.idDocument,
    required this.isApproved,
    required this.totalEarnings,
  });

  factory DeliveryAgent.fromJson(Map<String, dynamic> json) {
    return DeliveryAgent(
      agentId: json['agent_id'] as int,
      status: json['status'] as String,
      currentLat: json['current_lat'] != null
          ? double.parse(json['current_lat'].toString())
          : null,
      currentLng: json['current_lng'] != null
          ? double.parse(json['current_lng'].toString())
          : null,
      vehicleType: json['vehicle_type'] as String?,
      vehiclePlate: json['vehicle_plate'] as String?,
      idDocument: json['id_document'] as String?,
      isApproved: json['is_approved'] as bool,
      totalEarnings: double.parse(json['total_earnings'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agent_id': agentId,
      'status': status,
      'current_lat': currentLat,
      'current_lng': currentLng,
      'vehicle_type': vehicleType,
      'vehicle_plate': vehiclePlate,
      'id_document': idDocument,
      'is_approved': isApproved,
      'total_earnings': totalEarnings,
    };
  }
}
