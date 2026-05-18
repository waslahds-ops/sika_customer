import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'firebase_options.dart';
import 'core/constants/app_pallete.dart';
import 'core/config/app_config.dart';
import 'core/router/app_router.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/services/promotion_service.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/fcm_provider.dart';
import 'core/providers/app_reload_provider.dart';
import 'core/widgets/app_lifecycle_listener.dart' as fcm_listener;
import 'core/widgets/app_reload_splash.dart';
import 'features/cart/presentation/providers/cart_provider.dart';
import 'l10n/app_localizations.dart';
import 'l10n/app_localizations_en.dart';

// Global flag to track if first-launch popups have been shown
bool _hasShownFirstLaunchPopups = false;
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
  print('✅ Environment variables loaded');

  try {
    print('   API Base URL: ${AppConfig.apiEndpoint}');
    print('   Environment: ${AppConfig.environment}');
  } catch (e) {
    print('⚠️ Could not print config: $e');
  }

  // Dismiss native splash screen immediately to show custom splash loader
  FlutterNativeSplash.remove();

  // Enable edge-to-edge display
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('authBox');
  await Hive.openBox('appStateBox');
  await Hive.openBox('cart_preferences');
  await Hive.openBox('settingsBox');
  await Hive.openBox('ordersBox');

  // Initialize Promotion Service for showing deals/discounts
  final promotionService = PromotionService();
  await promotionService.initialize();

  // Fetch promotions from API (with cache fallback)
  try {
    print('📱 [INIT] Loading promotions...');
    final promotions = await promotionService.getPromotions();
    print('✅ [INIT] Loaded ${promotions.length} promotions');
  } catch (e) {
    print('❌ [INIT] Error loading promotions: $e');
  }

  // Initialize Firebase with auto-generated options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      print('⚠️ Firebase already initialized (likely from hot reload)');
    } else {
      rethrow;
    }
  }

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 🔥 CRITICAL: Set up foreground message listener IMMEDIATELY after Firebase init
  // This ensures notifications are captured even while app is opening/resuming
  try {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
        '📬 [Main] Foreground notification received: ${message.notification?.title}',
      );
      // The FirebaseMessagingService will handle showing the notification
      // This listener just ensures it's active from startup
    });
    print('✅ [Main] Foreground message listener registered');
  } catch (e) {
    print('❌ [Main] Error setting up foreground message listener: $e');
  }

  // Preload the user's saved locale before the app runs
  final initialLocale = await preloadLocale();
  setPreloadedLocale(initialLocale);

  // Check if popups have been shown before in this session
  final appStateBox = Hive.box('appStateBox');
  _hasShownFirstLaunchPopups =
      appStateBox.get('popupsShown', defaultValue: false) ?? false;

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _routerListenerRegistered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_routerListenerRegistered) {
        final router = ref.read(goRouterProvider);
        router.routeInformationProvider.addListener(_handleRouterChange);
        _routerListenerRegistered = true;
      }
    });
  }

  void _handleRouterChange() {
    final cartState = ref.read(cartProvider);
    if (cartState.itemCount > 0) {
      _handleCartSnackBar(cartState);
    } else {
      rootScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    }
  }

  void _handleCartSnackBar(CartState next) {
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _handleCartSnackBar(next));
      return;
    }
    final router = ref.read(goRouterProvider);
    final currentLocation = router.routeInformationProvider.value.uri.path;
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    if (next.itemCount <= 0 || currentLocation == '/cart') {
      messenger.hideCurrentSnackBar();
      return;
    }
    final bottomMargin = MediaQuery.of(context).padding.bottom + 4;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          l10n.cartOrdersMessage(next.itemCount),
          style: const TextStyle(color: Colors.black),
        ),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 0, 16, bottomMargin),
        duration: const Duration(days: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        action: SnackBarAction(
          label: l10n.viewCart,
          textColor: Colors.black,
          onPressed: () => router.go('/cart'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize FCM token on app startup
    ref.watch(fcmTokenInitializerProvider);

    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(localeProvider);
    final isReloading = ref.watch(appReloadingProvider);

    ref.listen<CartState>(cartProvider, (previous, next) {
      _handleCartSnackBar(next);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleCartSnackBar(ref.read(cartProvider));
    });

    // Show splash screen during app reload
    if (isReloading) {
      return const MaterialApp(home: Scaffold(body: AppReloadSplash()));
    }

    // Mark popups as shown on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasShownFirstLaunchPopups) {
        _hasShownFirstLaunchPopups = true;
        final appStateBox = Hive.box('appStateBox');
        appStateBox.put('popupsShown', true);
      }
    });

    final materialApp = MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Sika App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppPallete.primaryTeal),
        useMaterial3: true,
      ),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      routerConfig: router,
    );

    // Wrap with Directionality for RTL support based on locale
    // This applies RTL layout for UI elements when language is Arabic
    final directionality = Directionality(
      textDirection: locale.languageCode == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: materialApp,
    );

    // Wrap with lifecycle listener to send FCM token on app resume
    return fcm_listener.FCMLifecycleListener(child: directionality);
  }
}
