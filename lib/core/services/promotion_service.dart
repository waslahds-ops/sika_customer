import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dio/dio.dart';
import '../config/app_config.dart';

/// Model for promotional items (deals, discounts, ideas)
class PromotionalItem {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? code;
  final double? discountPercentage;
  final String? promoType; // 'deal', 'discount', 'idea', 'flash_sale'
  final DateTime expiryDate;
  final String? callToAction; // e.g., "Shop Now", "Get Code", "Apply"
  final Map<String, dynamic>? metadata; // Additional data

  PromotionalItem({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.code,
    this.discountPercentage,
    this.promoType = 'deal',
    required this.expiryDate,
    this.callToAction = 'View',
    this.metadata,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  factory PromotionalItem.fromJson(Map<String, dynamic> json) {
    return PromotionalItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'],
      code: json['code'],
      discountPercentage: json['discount_percentage'] != null
          ? double.tryParse(json['discount_percentage'].toString())
          : null,
      promoType: json['promo_type'] ?? json['type'] ?? 'deal',
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'].toString())
          : DateTime.now().add(const Duration(days: 30)),
      callToAction: json['call_to_action'] ?? 'View',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'code': code,
      'discount_percentage': discountPercentage,
      'promo_type': promoType,
      'expiry_date': expiryDate.toIso8601String(),
      'call_to_action': callToAction,
      'metadata': metadata,
    };
  }
}

/// Service to manage promotional items and popups
class PromotionService {
  static const String _promotionsBoxName = 'promotions';
  static const String _shownPromosKey = 'shown_promos';
  static const String _lastCheckKey = 'last_promo_check';

  static PromotionService? _instance;
  late Box _promotionsBox;
  bool _isInitialized = false;

  factory PromotionService() {
    _instance ??= PromotionService._internal();
    return _instance!;
  }

  PromotionService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;
    _promotionsBox = await Hive.openBox(_promotionsBoxName);
    _isInitialized = true;
  }

  Future<List<PromotionalItem>> getPromotions() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      
      // First, try to load from API
      print('📱 [PROMOTIONS] Fetching from API...');
      final dio = Dio();
      final response = await dio.get(
        '${AppConfig.apiEndpoint}/promotions',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> promoList = data['data'] ?? [];
        
        final promotions = promoList
            .map((json) => PromotionalItem.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // Cache to Hive for offline access
        await _promotionsBox.put('promotions', 
            promotions.map((p) => p.toJson()).toList());
        
        print('✅ [PROMOTIONS] Fetched ${promotions.length} promotions from API');
        return promotions;
      }
    } catch (e) {
      print('⚠️ [PROMOTIONS] API error: $e');
    }
    
    // Fallback: Load from cache if API fails
    try {
      final cachedPromoList = 
          _promotionsBox.get('promotions', defaultValue: []) as List?;
      if (cachedPromoList != null && cachedPromoList.isNotEmpty) {
        final promotions = (cachedPromoList)
            .map((json) => PromotionalItem.fromJson(json as Map<String, dynamic>))
            .toList();
        print('✅ [PROMOTIONS] Loaded ${promotions.length} promotions from cache');
        return promotions;
      }
    } catch (e) {
      print('⚠️ [PROMOTIONS] Cache error: $e');
    }
    
    // Final fallback: Return empty list (UI can show placeholder)
    print('⚠️ [PROMOTIONS] No promotions available - returning empty list');
    return [];
  }

  /// Save promotions to local cache
  Future<void> savePromotions(List<PromotionalItem> promotions) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      await _promotionsBox.put(
        'promotions',
        promotions.map((p) => p.toJson()).toList(),
      );
      await _promotionsBox.put(_lastCheckKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('❌ Error saving promotions: $e');
    }
  }

  /// Get promotions that haven't been shown yet
  Future<List<PromotionalItem>> getUnshownPromotions() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      final allPromos = await getPromotions();
      final shownPromoIds =
          _promotionsBox.get(_shownPromosKey, defaultValue: <String>[])
              as List?;

      return allPromos
          .where((p) => !(shownPromoIds?.contains(p.id) ?? false))
          .toList();
    } catch (e) {
      debugPrint('❌ Error getting unshown promotions: $e');
      return [];
    }
  }

  /// Mark a promotion as shown
  Future<void> markAsShown(String promoId) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      final shownPromoIds =
          _promotionsBox.get(_shownPromosKey, defaultValue: <String>[])
              as List?;
      final updatedList = [...?shownPromoIds, promoId];
      await _promotionsBox.put(_shownPromosKey, updatedList);
    } catch (e) {
      debugPrint('❌ Error marking promo as shown: $e');
    }
  }

  /// Clear all shown promotions to show them again
  Future<void> clearShownPromotions() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }
      await _promotionsBox.put(_shownPromosKey, <String>[]);
    } catch (e) {
      debugPrint('❌ Error clearing shown promotions: $e');
    }
  }

  /// Check if promotions need to be refreshed (older than 6 hours)
  bool shouldRefreshPromotions() {
    try {
      if (!_isInitialized) {
        return true; // Force refresh if not initialized
      }
      final lastCheckStr = _promotionsBox.get(_lastCheckKey) as String?;
      if (lastCheckStr == null) return true;

      final lastCheck = DateTime.parse(lastCheckStr);
      final sixHoursAgo = DateTime.now().subtract(const Duration(hours: 6));
      return lastCheck.isBefore(sixHoursAgo);
    } catch (e) {
      return true;
    }
  }

  /// Create mock promotional items for testing
  static List<PromotionalItem> getMockPromotions() {
    return [
      PromotionalItem(
        id: 'promo_1',
        title: '🎉 Welcome to Sika!',
        description: 'Get 20% off your first order using code WELCOME20',
        code: 'WELCOME20',
        discountPercentage: 20,
        promoType: 'deal',
        imageUrl: null,
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        callToAction: 'Claim Now',
      ),
      PromotionalItem(
        id: 'promo_2',
        title: '⚡ Flash Sale Today!',
        description:
            'Up to 50% off on selected restaurants. Limited time only!',
        discountPercentage: 50,
        promoType: 'flash_sale',
        expiryDate: DateTime.now().add(const Duration(hours: 6)),
        callToAction: 'Shop Now',
      ),
      PromotionalItem(
        id: 'promo_3',
        title: '🎁 Free Delivery',
        description: 'Free delivery on orders above \$20. Valid for 7 days.',
        promoType: 'idea',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        callToAction: 'Browse',
      ),
      PromotionalItem(
        id: 'promo_4',
        title: '💰 Save More Weekdays',
        description: 'Monday to Friday: Extra 15% off using code WEEKDAY15',
        code: 'WEEKDAY15',
        discountPercentage: 15,
        promoType: 'discount',
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        callToAction: 'Apply Code',
      ),
    ];
  }
}
