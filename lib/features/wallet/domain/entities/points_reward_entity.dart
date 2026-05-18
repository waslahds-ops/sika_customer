import 'package:equatable/equatable.dart';

/// Points reward that users can redeem
class PointsRewardEntity extends Equatable {
  final int rewardId;
  final String nameEn;
  final String nameAr;
  final String? descriptionEn;
  final String? descriptionAr;
  final int pointsRequired;
  final double? discountAmount;
  final int? discountPercentage;
  final String? couponCode;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PointsRewardEntity({
    required this.rewardId,
    required this.nameEn,
    required this.nameAr,
    this.descriptionEn,
    this.descriptionAr,
    required this.pointsRequired,
    this.discountAmount,
    this.discountPercentage,
    this.couponCode,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    rewardId,
    nameEn,
    nameAr,
    descriptionEn,
    descriptionAr,
    pointsRequired,
    discountAmount,
    discountPercentage,
    couponCode,
    isActive,
    createdAt,
    updatedAt,
  ];
}
