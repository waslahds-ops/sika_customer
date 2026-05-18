class Customer {
  final int customerId;
  final String firstName;
  final String lastName;
  final String? profileImage;

  Customer({
    required this.customerId,
    required this.firstName,
    required this.lastName,
    this.profileImage,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customer_id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      profileImage: json['profile_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'first_name': firstName,
      'last_name': lastName,
      'profile_image': profileImage,
    };
  }
}
