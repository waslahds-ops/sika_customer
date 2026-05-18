import 'package:equatable/equatable.dart';

class StoreEntity extends Equatable {
  final int storeId;
  final int merchantId;
  final int categoryId;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? coverUrl;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double? ratingAvg;
  final double deliveryFee;
  final double minOrderAmount;
  final String? estimatedDeliveryTime;
  final bool isOpen;
  final bool isActive;
  final Map<String, dynamic>? workingHours;
  final int? ordersCount;

  const StoreEntity({
    required this.storeId,
    required this.merchantId,
    required this.categoryId,
    required this.name,
    this.description,
    this.logoUrl,
    this.coverUrl,
    this.address,
    this.latitude,
    this.longitude,
    this.ratingAvg,
    required this.deliveryFee,
    required this.minOrderAmount,
    this.estimatedDeliveryTime,
    required this.isOpen,
    required this.isActive,
    this.workingHours,
    this.ordersCount,
  });

  @override
  List<Object?> get props => [
    storeId,
    merchantId,
    categoryId,
    name,
    description,
    logoUrl,
    coverUrl,
    address,
    latitude,
    longitude,
    ratingAvg,
    deliveryFee,
    minOrderAmount,
    estimatedDeliveryTime,
    isOpen,
    isActive,
    workingHours,
    ordersCount,
  ];
}

class CategoryEntity extends Equatable {
  final int categoryId;
  final String nameAr;
  final String nameEn;
  final String? imageUrl;
  final bool isActive;

  const CategoryEntity({
    required this.categoryId,
    required this.nameAr,
    required this.nameEn,
    this.imageUrl,
    required this.isActive,
  });

  @override
  List<Object?> get props => [categoryId, nameAr, nameEn, imageUrl, isActive];
}

class ProductEntity extends Equatable {
  final int productId;
  final int storeId;
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final double price;
  final String? imageUrl;
  final String? category;
  final bool isAvailable;
  final String? preparationTime;

  const ProductEntity({
    required this.productId,
    required this.storeId,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.price,
    this.imageUrl,
    this.category,
    required this.isAvailable,
    this.preparationTime,
  });

  @override
  List<Object?> get props => [
    productId,
    storeId,
    nameAr,
    nameEn,
    descriptionAr,
    descriptionEn,
    price,
    imageUrl,
    category,
    isAvailable,
    preparationTime,
  ];
}
