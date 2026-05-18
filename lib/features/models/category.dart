class Category {
  final int categoryId;
  final String nameAr;
  final String nameEn;
  final String? imageUrl;
  final bool isActive;

  Category({
    required this.categoryId,
    required this.nameAr,
    required this.nameEn,
    this.imageUrl,
    required this.isActive,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['category_id'] as int,
      nameAr: json['name_ar'] as String,
      nameEn: json['name_en'] as String,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'name_ar': nameAr,
      'name_en': nameEn,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }
}
