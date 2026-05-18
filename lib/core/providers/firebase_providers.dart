import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_messaging_service.dart';

final firebaseMessagingServiceProvider = Provider<FirebaseMessagingService>((
  ref,
) {
  return FirebaseMessagingService();
});

final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final messagingService = ref.read(firebaseMessagingServiceProvider);
  return await messagingService.getToken();
});
