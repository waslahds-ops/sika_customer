import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class FavoritesNotifier extends StateNotifier<Set<int>> {
  static const String _boxName = 'favorites';
  static const String _favoritesKey = 'favorite_stores';

  FavoritesNotifier() : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final box = await Hive.openBox(_boxName);
      final favoritesList = box.get(_favoritesKey, defaultValue: <int>[]);
      if (favoritesList is List) {
        state = favoritesList.cast<int>().toSet();
        debugPrint(
          '✅ [Favorites] Loaded ${state.length} favorites from local storage',
        );
      } else {
        state = {};
        debugPrint('⚠️ [Favorites] No previous favorites found');
      }
    } catch (e) {
      // If loading fails, start with empty set
      state = {};
      debugPrint('❌ [Favorites] Error loading from storage: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(_favoritesKey, state.toList());
      debugPrint(
        '💾 [Favorites] Saved ${state.length} favorites to local storage',
      );
    } catch (e) {
      debugPrint('❌ [Favorites] Error saving to storage: $e');
    }
  }

  void toggleFavorite(int storeId) {
    if (state.contains(storeId)) {
      state = {...state}..remove(storeId);
      debugPrint('❌ [Favorites] Removed store $storeId from favorites');
    } else {
      state = {...state, storeId};
      debugPrint('❤️ [Favorites] Added store $storeId to favorites');
    }
    _saveFavorites();
  }

  bool isFavorite(int storeId) {
    return state.contains(storeId);
  }

  void addFavorite(int storeId) {
    if (!state.contains(storeId)) {
      state = {...state, storeId};
      debugPrint('❤️ [Favorites] Added store $storeId to favorites');
      _saveFavorites();
    }
  }

  void removeFavorite(int storeId) {
    if (state.contains(storeId)) {
      state = {...state}..remove(storeId);
      debugPrint('❌ [Favorites] Removed store $storeId from favorites');
      _saveFavorites();
    }
  }

  void clearAll() {
    state = {};
    debugPrint('🗑️ [Favorites] Cleared all favorites');
    _saveFavorites();
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<int>>((
  ref,
) {
  return FavoritesNotifier();
});
