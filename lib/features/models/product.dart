import 'keeta_features.dart';

class Product {
  final int productId;
  final int storeId;
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final double price;
  final String? imageUrl;
  final String? category;
  final String? weight;
  final bool isAvailable;
  final String? preparationTime;
  final List<ProductSize>? availableSizes;
  final List<ProductAddon>? availableAddons;

  Product({
    required this.productId,
    required this.storeId,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.price,
    this.imageUrl,
    this.category,
    this.weight,
    required this.isAvailable,
    this.preparationTime,
    this.availableSizes,
    this.availableAddons,
  });

  String get image =>
      imageUrl ??
      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400';

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id'] as int,
      storeId: json['store_id'] as int,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      price: double.parse(json['price'].toString()),
      weight: json['weight'] as String?,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String?,
      isAvailable: json['is_available'] as bool,
      preparationTime: json['preparation_time'] as String?,
      availableSizes: json['available_sizes'] != null
          ? (json['available_sizes'] as List)
                .map((e) => ProductSize.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      availableAddons: json['available_addons'] != null
          ? (json['available_addons'] as List)
                .map((e) => ProductAddon.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
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
      'weight': weight,
      'image_url': imageUrl,
      'category': category,
      'is_available': isAvailable,
      'preparation_time': preparationTime,
      'available_sizes': availableSizes?.map((e) => e.toJson()).toList(),
      'available_addons': availableAddons?.map((e) => e.toJson()).toList(),
    };
  }
}
