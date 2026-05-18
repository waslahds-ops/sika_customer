import 'package:equatable/equatable.dart';

class VoucherModel extends Equatable {
  final int id;
  final String code;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final String discountType;
  final double discountValue;
  final double? maxDiscountAmount;
  final double minOrderAmount;
  final DateTime validFrom;
  final DateTime validUntil;
  final int? usageLimit;
  final int usageCount;
  final bool isActive;
  final String imageUrl;
  final String imagePath;
  final bool showAsPopup;

  const VoucherModel({
    required this.id,
    required this.code,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.discountType,
    required this.discountValue,
    this.maxDiscountAmount,
    required this.minOrderAmount,
    required this.validFrom,
    required this.validUntil,
    this.usageLimit,
    required this.usageCount,
    required this.isActive,
    required this.imageUrl,
    required this.imagePath,
    required this.showAsPopup,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'] as int,
      code: json['code'] as String,
      nameEn: json['name_en'] as String,
      nameAr: json['name_ar'] as String,
      descriptionEn: json['description_en'] as String,
      descriptionAr: json['description_ar'] as String,
      discountType: json['discount_type'] as String,
      discountValue: double.parse(json['discount_value'].toString()),
      maxDiscountAmount: json['max_discount_amount'] != null
          ? double.parse(json['max_discount_amount'].toString())
          : null,
      minOrderAmount: double.parse(json['min_order_amount'].toString()),
      validFrom: DateTime.parse(json['valid_from'] as String),
      validUntil: DateTime.parse(json['valid_until'] as String),
      usageLimit: json['usage_limit'] as int?,
      usageCount: json['usage_count'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      imageUrl: json['image_url'] as String,
      imagePath: json['image_path'] as String? ?? '',
      showAsPopup: json['show_as_popup'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name_en': nameEn,
      'name_ar': nameAr,
      'description_en': descriptionEn,
      'description_ar': descriptionAr,
      'discount_type': discountType,
      'discount_value': discountValue,
      'max_discount_amount': maxDiscountAmount,
      'min_order_amount': minOrderAmount,
      'valid_from': validFrom.toIso8601String(),
      'valid_until': validUntil.toIso8601String(),
      'usage_limit': usageLimit,
      'usage_count': usageCount,
      'is_active': isActive,
      'image_url': imageUrl,
      'image_path': imagePath,
      'show_as_popup': showAsPopup,
    };
  }

  @override
  List<Object?> get props => [
    id,
    code,
    nameEn,
    nameAr,
    descriptionEn,
    descriptionAr,
    discountType,
    discountValue,
    maxDiscountAmount,
    minOrderAmount,
    validFrom,
    validUntil,
    usageLimit,
    usageCount,
    isActive,
    imageUrl,
    imagePath,
    showAsPopup,
  ];
}
