import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.userId,
    required super.phoneNumber,
    super.email,
    required super.role,
    required super.languagePreference,
    required super.isVerified,
    super.accessToken,
    super.firstName,
    super.lastName,
    super.profileImage,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Extract customer data if it exists
    final customer = json['customer'] as Map<String, dynamic>?;

    return UserModel(
      userId: json['user_id'] as int,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
      role: json['role'] as String,
      languagePreference: json['language_preference'] as String,
      isVerified: json['is_verified'] as bool,
      accessToken: json['access_token'] as String?,
      // Try to get from customer object first, then fall back to direct fields
      firstName:
          customer?['first_name'] as String? ?? json['first_name'] as String?,
      lastName:
          customer?['last_name'] as String? ?? json['last_name'] as String?,
      profileImage:
          customer?['profile_image'] as String? ??
          json['profile_image'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
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
      'access_token': accessToken,
      'created_at': createdAt?.toIso8601String(),
      if (firstName != null || lastName != null || profileImage != null)
        'customer': {
          'first_name': firstName,
          'last_name': lastName,
          'profile_image': profileImage,
        },
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      phoneNumber: phoneNumber,
      email: email,
      role: role,
      languagePreference: languagePreference,
      isVerified: isVerified,
      accessToken: accessToken,
      firstName: firstName,
      lastName: lastName,
      profileImage: profileImage,
      createdAt: createdAt,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      userId: entity.userId,
      phoneNumber: entity.phoneNumber,
      email: entity.email,
      role: entity.role,
      languagePreference: entity.languagePreference,
      isVerified: entity.isVerified,
      accessToken: entity.accessToken,
      firstName: entity.firstName,
      lastName: entity.lastName,
      profileImage: entity.profileImage,
      createdAt: entity.createdAt,
    );
  }
}
