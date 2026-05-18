import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../injection_container.dart';

// Global variable to store the preloaded locale
Locale? _preloadedLocale;

void setPreloadedLocale(Locale locale) {
  _preloadedLocale = locale;
}

Locale getPreloadedLocale() {
  return _preloadedLocale ?? const Locale('ar');
}

class LocaleNotifier extends StateNotifier<Locale> {
  final FlutterSecureStorage _storage;
  final Ref _ref;

  LocaleNotifier(this._storage, this._ref) : super(getPreloadedLocale()) {
    // Async load might update the state later if needed
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    // Try to load from secure storage first
    final savedLocale = await _storage.read(key: 'locale');
    if (savedLocale != null) {
      state = Locale(savedLocale);
      return;
    }

    // Try to load from user preferences if logged in
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      final userEither = await authRepo.getCurrentUser();
      userEither.fold(
        (failure) {
          // User not logged in or error, keep current state
        },
        (user) async {
          if (user.languagePreference.isNotEmpty) {
            final locale = Locale(user.languagePreference);
            state = locale;
            await _storage.write(key: 'locale', value: user.languagePreference);
          }
        },
      );
    } catch (e) {
      // Error, keep current state
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _storage.write(key: 'locale', value: locale.languageCode);

    // Try to update user preferences on backend
    try {
      final authRepo = _ref.read(authRepositoryProvider);
      await authRepo.updateLanguagePreference(locale.languageCode);
    } catch (e) {
      // Error updating backend, but local preference is saved
      print('Error updating language preference: $e');
    }
  }

  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
    await setLocale(newLocale);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(const FlutterSecureStorage(), ref);
});

/// Preload the user's saved locale before the app runs
/// This ensures the splash screen and app start with the correct language
Future<Locale> preloadLocale() async {
  try {
    const storage = FlutterSecureStorage();
    final savedLocale = await storage.read(key: 'locale');
    if (savedLocale != null) {
      return Locale(savedLocale);
    }
  } catch (e) {
    print('Error preloading locale: $e');
  }
  return const Locale('ar');
}
