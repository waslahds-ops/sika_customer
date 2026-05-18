

import 'package:sika_customer/features/wallet/domain/entities/points_reward_entity.dart';

class PointsRewardModel extends PointsRewardEntity {
  const PointsRewardModel({
    required super.rewardId,
    required super.nameEn,
    required super.nameAr,
    super.descriptionEn,
    super.descriptionAr,
    required super.pointsRequired,
    super.discountAmount,
    super.discountPercentage,
    super.couponCode,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PointsRewardModel.fromJson(Map<String, dynamic> json) {
    return PointsRewardModel(
      rewardId: json['reward_id'] as int,
      nameEn: json['name_en'] as String,
      nameAr: json['name_ar'] as String,
      descriptionEn: json['description_en'] as String?,
      descriptionAr: json['description_ar'] as String?,
      pointsRequired: json['points_required'] as int,
      discountAmount: json['discount_amount'] != null
          ? (json['discount_amount'] as num).toDouble()
          : null,
      discountPercentage: json['discount_percentage'] as int?,
      couponCode: json['coupon_code'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reward_id': rewardId,
      'name_en': nameEn,
      'name_ar': nameAr,
      'description_en': descriptionEn,
      'description_ar': descriptionAr,
      'points_required': pointsRequired,
      'discount_amount': discountAmount,
      'discount_percentage': discountPercentage,
      'coupon_code': couponCode,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
