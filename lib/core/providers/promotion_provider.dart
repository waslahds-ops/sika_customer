import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/promotion_service.dart';

/// Global provider for PromotionService - uses singleton pattern
final promotionServiceProvider = Provider<PromotionService>((ref) {
  return PromotionService(); // Returns singleton instance
});

/// Provider to get unshown promotions
final unshownPromotionsProvider = FutureProvider<List<PromotionalItem>>((
  ref,
) async {
  final service = ref.read(promotionServiceProvider);
  return service.getUnshownPromotions();
});

/// Provider to get all promotions
final promotionsProvider = FutureProvider<List<PromotionalItem>>((ref) async {
  final service = ref.read(promotionServiceProvider);
  return service.getPromotions();
});

/// State notifier to manage promotion UI
class PromotionNotifier extends StateNotifier<PromotionalItem?> {
  final Ref ref;

  PromotionNotifier(this.ref) : super(null);

  Future<void> markPromotionAsShown(String promoId) async {
    final service = ref.read(promotionServiceProvider);
    await service.markAsShown(promoId);
  }

  Future<void> loadNextPromotion() async {
    final unshownPromos = await ref.refresh(unshownPromotionsProvider.future);
    if (unshownPromos.isNotEmpty) {
      state = unshownPromos.first;
    } else {
      state = null;
    }
  }
}

/// Provider to manage current shown promotion
final currentPromotionProvider =
    StateNotifierProvider<PromotionNotifier, PromotionalItem?>((ref) {
      return PromotionNotifier(ref);
    });
