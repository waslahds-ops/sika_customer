import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track whether the app is reloading due to language change
final appReloadingProvider = StateProvider<bool>((ref) => false);

/// Provider to manage app reload logic
final appReloadManagerProvider = Provider((ref) {
  return AppReloadManager(ref);
});

class AppReloadManager {
  final Ref _ref;

  AppReloadManager(this._ref);

  /// Trigger app reload (used when language changes)
  Future<void> triggerReload() async {
    // Set reloading state to true (shows splash screen)
    _ref.read(appReloadingProvider.notifier).state = true;

    // Wait for splash to show
    await Future.delayed(const Duration(milliseconds: 500));

    // Set reloading state to false (hides splash and rebuilds app)
    _ref.read(appReloadingProvider.notifier).state = false;
  }
}
