import '../../domain/entities/store_entities.dart';

class StoreModel extends StoreEntity {
  const StoreModel({
    required super.storeId,
    required super.merchantId,
    required super.categoryId,
    required super.name,
    super.description,
    super.logoUrl,
    super.coverUrl,
    super.address,
    super.latitude,
    super.longitude,
    super.ratingAvg,
    required super.deliveryFee,
    required super.minOrderAmount,
    super.estimatedDeliveryTime,
    required super.isOpen,
    required super.isActive,
    super.workingHours,
    super.ordersCount,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      storeId: json['store_id'] as int? ?? 0,
      merchantId: json['merchant_id'] as int? ?? 0,
      categoryId: json['category_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      ratingAvg: json['rating_avg'] != null
          ? double.tryParse(json['rating_avg'].toString())
          : null,
      deliveryFee: double.tryParse(json['delivery_fee'].toString()) ?? 0.0,
      minOrderAmount:
          double.tryParse(json['min_order_amount'].toString()) ?? 0.0,
      estimatedDeliveryTime: json['estimated_delivery_time']?.toString(),
      isOpen: json['is_open'] == 1 || json['is_open'] == true,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      workingHours: json['working_hours'] != null
          ? Map<String, dynamic>.from(json['working_hours'] as Map)
          : null,
      ordersCount: (json['orders_count'] ?? json['order_count']) as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'merchant_id': merchantId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'cover_url': coverUrl,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'rating_avg': ratingAvg,
      'delivery_fee': deliveryFee,
      'min_order_amount': minOrderAmount,
      'estimated_delivery_time': estimatedDeliveryTime,
      'is_open': isOpen ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'working_hours': workingHours,
      'orders_count': ordersCount,
    };
  }
}

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    required super.categoryId,
    required super.nameAr,
    required super.nameEn,
    super.imageUrl,
    required super.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['category_id'] as int,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'name_ar': nameAr,
      'name_en': nameEn,
      'image_url': imageUrl,
      'is_active': isActive ? 1 : 0,
    };
  }
}

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.productId,
    required super.storeId,
    required super.nameAr,
    required super.nameEn,
    super.descriptionAr,
    super.descriptionEn,
    required super.price,
    super.imageUrl,
    super.category,
    required super.isAvailable,
    super.preparationTime,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      // Helper function to parse price from any type (string or number)
      double parsePrice(dynamic priceValue) {
        if (priceValue == null) return 0.0;
        if (priceValue is double) return priceValue;
        if (priceValue is int) return priceValue.toDouble();
        if (priceValue is String) {
          return double.tryParse(priceValue) ?? 0.0;
        }
        return 0.0;
      }

      return ProductModel(
        productId: json['product_id'] as int? ?? json['id'] as int? ?? 0,
        storeId: json['store_id'] as int? ?? 0,
        nameAr: json['name_ar'] as String? ?? json['name'] as String? ?? 'N/A',
        nameEn: json['name_en'] as String? ?? json['name'] as String? ?? 'N/A',
        descriptionAr: json['description_ar'] as String?,
        descriptionEn: json['description_en'] as String?,
        price: parsePrice(json['price'] ?? json['amount']),
        imageUrl: json['image_url'] as String? ?? json['image'] as String?,
        category: json['category'] as String?,
        isAvailable:
            (json['is_available'] ?? json['available'] ?? true) == 1 ||
            (json['is_available'] ?? true) == true,
        preparationTime: json['preparation_time'] != null
            ? json['preparation_time'].toString()
            : null,
      );
    } catch (e, stackTrace) {
      print('❌ [PRODUCTS] Error parsing product: $e');
      print('❌ [PRODUCTS] JSON: $json');
      print('❌ [PRODUCTS] Stack: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'store_id': storeId,
      'name_ar': nameAr,
      'name_en': nameEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'is_available': isAvailable ? 1 : 0,
      'preparation_time': preparationTime,
    };
  }
}
