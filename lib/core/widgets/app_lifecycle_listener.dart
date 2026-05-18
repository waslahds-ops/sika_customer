import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_messaging_service.dart';

/// Widget that listens to app lifecycle changes and sends FCM token
/// when the app comes to foreground
class FCMLifecycleListener extends ConsumerStatefulWidget {
  final Widget child;

  const FCMLifecycleListener({required this.child, super.key});

  @override
  ConsumerState<FCMLifecycleListener> createState() =>
      _FCMLifecycleListenerState();
}

class _FCMLifecycleListenerState extends ConsumerState<FCMLifecycleListener>
    with WidgetsBindingObserver {
  late final FirebaseMessagingService _fcmService;

  @override
  void initState() {
    super.initState();
    _fcmService = FirebaseMessagingService();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App comes to foreground - send FCM token
        _handleAppResumed();
        break;
      case AppLifecycleState.paused:
        // App goes to background
        print('📱 [Lifecycle] App paused - going to background');
        break;
      case AppLifecycleState.detached:
        // App is detached
        print('📱 [Lifecycle] App detached');
        break;
      case AppLifecycleState.hidden:
        // App is hidden (rarely used on mobile)
        print('📱 [Lifecycle] App hidden');
        break;
      case AppLifecycleState.inactive:
        // App is inactive
        print('📱 [Lifecycle] App inactive');
        break;
    }
  }

  Future<void> _handleAppResumed() async {
    print('📱 [Lifecycle] App resumed - sending FCM token to server');

    try {
      final token = await _fcmService.getToken();
      if (token != null) {
        await _fcmService.sendTokenToServer(token);
        print('✅ [Lifecycle] FCM token sent on app resume: $token');
      } else {
        print('⚠️ [Lifecycle] No FCM token available on resume');
      }
    } catch (e, stackTrace) {
      print('❌ [Lifecycle] Error sending FCM token on resume: $e');
      print('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
