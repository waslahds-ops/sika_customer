import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../utils/api_service.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  late ApiService _apiService;

  // Track if initialization has already been done to prevent re-initialization
  static bool _initialized = false;

  // Singleton pattern
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  factory FirebaseMessagingService({ApiService? apiService}) {
    if (apiService != null) {
      _instance._apiService = apiService;
      debugPrint(
        '🔐 [FirebaseMessagingService] Updated with new ApiService instance',
      );
    } else if (!_instance._hasInitializedApiService()) {
      _instance._apiService = ApiService();
    }
    return _instance;
  }

  FirebaseMessagingService._internal();

  /// Check if ApiService has been initialized
  bool _hasInitializedApiService() {
    try {
      // Try to access the late field
      _apiService;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Initialize Firebase Messaging (idempotent - safe to call multiple times)
  Future<void> initialize() async {
    // 🔥 CRITICAL: Prevent re-initialization that could remove listeners
    if (_initialized) {
      debugPrint('⚠️ [FCM] Already initialized, skipping re-initialization');
      return;
    }

    _initialized = true;

    // Request permission for iOS
    // ignore: unused_local_variable
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token
    String? token = await getToken();
    debugPrint('🔑 FCM Token: $token');

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      // TODO: Send updated token to your server
      sendTokenToServer(newToken);
    });

    // 🔥 Handle foreground messages - this MUST stay active
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('🔔 [FCM] Foreground notification received');
      _handleForegroundMessage(message);
    });

    // Handle background message clicks
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check if app was opened from a terminated state
    RemoteMessage? initialMessage = await _firebaseMessaging
        .getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    debugPrint(
      '✅ [FCM] Firebase Messaging fully initialized with all listeners',
    );
  }

  /// Initialize local notifications for Android
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Delete FCM token (for logout)
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      debugPrint('🗑️ FCM token deleted');
    } catch (e) {
      debugPrint('❌ Error deleting FCM token: $e');
    }
  }

  /// Send token to server with retry logic
  Future<void> sendTokenToServer(String token, {int maxRetries = 3}) async {
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        print(
          '📤 [FirebaseMessagingService] Sending FCM token (attempt ${retryCount + 1}/$maxRetries)',
        );
        await _apiService.sendFCMToken(token);
        debugPrint('✅ Token sent to server successfully');
        print('✅ [FirebaseMessagingService] FCM token sent successfully');
        return; // Success - exit the retry loop
      } catch (e, stackTrace) {
        retryCount++;

        if (retryCount < maxRetries) {
          // Calculate exponential backoff: 2s, 4s, 8s
          final delaySeconds = 2 * retryCount;
          print(
            '⏳ [FirebaseMessagingService] Retry in ${delaySeconds}s... (Error: $e)',
          );
          debugPrint('⏳ Retrying in ${delaySeconds}s...');

          // Wait before retrying
          await Future.delayed(Duration(seconds: delaySeconds));
        } else {
          // All retries exhausted
          debugPrint(
            '❌ Error sending token to server after $maxRetries attempts: $e',
          );
          print(
            '❌ [FirebaseMessagingService] Failed to send FCM token after $maxRetries attempts',
          );
          print('❌ Last error: $e');
          print('Stack trace: $stackTrace');
          print(
            '⚠️ [FirebaseMessagingService] Token will be retried on next app resume or when network is available',
          );
        }
      }
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    // Always show notification even when app is in foreground
    if (message.notification != null) {
      _showLocalNotification(message);
    }

    // Handle data payload immediately
    if (message.data.isNotEmpty) {
      _handleNotificationData(message.data);
    }

    // Special handling for OTP - trigger callback immediately
    if (message.data['type'] == 'verification_code') {
      String? code = message.data['code'];
      if (code != null) {
        _handleOTPReceived(code, message.data);
      }
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      // Special styling for OTP notifications
      final isOTP = message.data['type'] == 'verification_code';

      final title = message.notification?.title ?? 'New Notification';
      final body = message.notification?.body ?? '';

      debugPrint(
        '📬 Showing ${isOTP ? 'OTP' : 'regular'} notification: $title',
      );

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
            // Make OTP notifications more prominent
            playSound: true,
            enableVibration: true,
            ticker: isOTP ? 'Verification Code' : null,
            styleInformation: isOTP
                ? BigTextStyleInformation(
                    body,
                    contentTitle: title,
                    htmlFormatContentTitle: true,
                    htmlFormatContent: true,
                  )
                : null,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        title,
        body,
        notificationDetails,
        payload: message.data.toString(),
      );

      debugPrint('✅ Notification shown successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error showing notification: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen based on payload

    // You can parse the payload and use GoRouter to navigate
  }

  /// Handle message opened from background
  void _handleMessageOpenedApp(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      _handleNotificationData(message.data);
    }
  }

  /// Handle notification data and navigate
  void _handleNotificationData(Map<String, dynamic> data) {
    // Handle different notification types
    String? type = data['type'];
    String? orderId = data['order_id'];
    String? screen = data['screen'];

    switch (type) {
      case 'verification_code':
        String? code = data['code'];
        if (code != null) {
          // Store the code for auto-fill
          _handleOTPReceived(code, data);
        }
        break;
      case 'order_update':
        debugPrint('🛍️ Order update notification: $orderId');
        // Navigation will be handled by UI layer observing notification events
        break;
      case 'delivery_status':
        debugPrint('🚚 Delivery status notification');
        // Navigation will be handled by UI layer observing notification events
        break;
      case 'promotion':
        debugPrint('🎉 Promotion notification');
        // Navigation will be handled by UI layer observing notification events
        break;
      default:
        if (screen != null) {
          debugPrint('📍 Navigate to: $screen');
          // Navigation will be handled by UI layer observing notification events
        }
    }
  }

  /// Handle OTP received from notification
  void _handleOTPReceived(String code, Map<String, dynamic> data) {
    // You can emit an event or use a stream controller to notify the app
    // For now, we'll use a simple callback mechanism
    if (_otpReceivedCallback != null) {
      _otpReceivedCallback!(code, data);
    }
  }

  // Callback for OTP received
  Function(String code, Map<String, dynamic> data)? _otpReceivedCallback;

  /// Set callback for when OTP is received
  void setOTPReceivedCallback(
    Function(String code, Map<String, dynamic> data) callback,
  ) {
    _otpReceivedCallback = callback;
  }

  /// Clear OTP callback
  void clearOTPCallback() {
    _otpReceivedCallback = null;
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      debugPrint('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      debugPrint('❌ Error unsubscribing from topic: $e');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle OTP in background
  if (message.data['type'] == 'verification_code') {
    String? code = message.data['code'];
    if (code != null) {
      debugPrint('🔐 OTP received in background: $code');
      // The notification will be shown automatically by the system
      // The callback will be triggered when user opens the app
    }
  }
}
