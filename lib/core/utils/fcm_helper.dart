import '../services/firebase_messaging_service.dart';
import 'api_service.dart';

/// Helper to send FCM token to server after login
Future<void> sendFCMTokenToServer() async {
  try {
    final messagingService = FirebaseMessagingService();
    final token = await messagingService.getToken();

    if (token != null) {
      final apiService = ApiService();
      await apiService.sendFCMToken(token);
      print('✅ FCM token registered with server');
    } else {
      print('⚠️ FCM token not available');
    }
  } catch (e) {
    print('❌ Error registering FCM token: $e');
  }
}

/// Delete FCM token on logout
Future<void> deleteFCMToken() async {
  try {
    final messagingService = FirebaseMessagingService();
    await messagingService.deleteToken();
    print('✅ FCM token deleted');
  } catch (e) {
    print('❌ Error deleting FCM token: $e');
  }
}
