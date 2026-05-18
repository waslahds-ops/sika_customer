class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double priceAtTime;
  final String? specialInstructions;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.priceAtTime,
    this.specialInstructions,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      priceAtTime: double.parse(json['price_at_time'].toString()),
      specialInstructions: json['special_instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price_at_time': priceAtTime,
      'special_instructions': specialInstructions,
    };
  }
}
