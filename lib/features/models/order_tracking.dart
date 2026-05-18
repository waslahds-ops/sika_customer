class OrderTracking {
  final int trackId;
  final int orderId;
  final int agentId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  OrderTracking({
    required this.trackId,
    required this.orderId,
    required this.agentId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      trackId: json['track_id'] as int,
      orderId: json['order_id'] as int,
      agentId: json['agent_id'] as int,
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'track_id': trackId,
      'order_id': orderId,
      'agent_id': agentId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
