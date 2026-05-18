class User {
  final int userId;
  final String phoneNumber;
  final String? email;
  final String role;
  final String languagePreference;
  final bool isVerified;
  final DateTime? createdAt;
  final String? firstName;
  final String? lastName;
  final String? profileImage;

  User({
    required this.userId,
    required this.phoneNumber,
    this.email,
    required this.role,
    required this.languagePreference,
    required this.isVerified,
    this.createdAt,
    this.firstName,
    this.lastName,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as int,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
      role: json['role'] as String,
      languagePreference: json['language_preference'] as String,
      isVerified: json['is_verified'] as bool,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      profileImage: json['profile_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'phone_number': phoneNumber,
      'email': email,
      'role': role,
      'language_preference': languagePreference,
      'is_verified': isVerified,
      'created_at': createdAt?.toIso8601String(),
      'first_name': firstName,
      'last_name': lastName,
      'profile_image': profileImage,
    };
  }
}
