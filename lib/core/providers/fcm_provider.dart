import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_messaging_service.dart';
import '../utils/api_service.dart';
import '../../injection_container.dart';

/// Provider that sends FCM token on app startup
/// This ensures the token is always sent to the backend when app opens
final fcmTokenInitializerProvider = FutureProvider<void>((ref) async {
  try {
    // IMPORTANT: Restore auth token BEFORE sending FCM token
    // The FCM token endpoint requires authentication
    final authRepository = ref.read(authRepositoryProvider);
    final apiService = ref.read(apiServiceProvider);

    final storedToken = await authRepository.getStoredToken();
    if (storedToken != null && storedToken.isNotEmpty) {
      apiService.setAuthToken(storedToken);
      print(
        '🔐 [FCM Provider] Auth token restored from storage: ${storedToken.substring(0, 20)}...',
      );
    } else {
      print('⚠️ [FCM Provider] No stored auth token found');
      // Continue anyway - some tokens might still be sent if user is not logged in
    }

    // Get the FCM service instance (singleton pattern - pass apiService to update it if needed)
    final fcmService = FirebaseMessagingService(apiService: apiService);

    // Initialize Firebase Messaging (request permissions, setup listeners, etc.)
    await fcmService.initialize();

    // Get current token
    final token = await fcmService.getToken();

    if (token != null) {
      // Send token to server (now with auth token in headers)
      await fcmService.sendTokenToServer(token);
      print('✅ [FCM Provider] Token sent on app startup: $token');
    } else {
      print('⚠️ [FCM Provider] No FCM token available');
    }
  } catch (e, stackTrace) {
    print('❌ [FCM Provider] Error initializing FCM: $e');
    print('Stack trace: $stackTrace');
    // Don't rethrow - we want app to continue even if FCM fails
  }
});

/// Provider to handle FCM token refresh
/// Call this when you need to force a token update
final fcmTokenRefreshProvider = FutureProvider<void>((ref) async {
  try {
    final fcmService = FirebaseMessagingService();
    final token = await fcmService.getToken();

    if (token != null) {
      final apiService = ApiService();
      await apiService.sendFCMToken(token);
      print('✅ [FCM Refresh] Token refreshed: $token');
    }
  } catch (e, stackTrace) {
    print('❌ [FCM Refresh] Error refreshing FCM token: $e');
    print('Stack trace: $stackTrace');
  }
});
