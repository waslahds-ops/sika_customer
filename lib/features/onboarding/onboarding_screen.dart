import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:sika_customer/core/widgets/app_loader.dart';
import 'package:sika_customer/l10n/app_localizations.dart';
import '../../core/services/onboarding_service.dart';

// Define the primary colors based on the image
const Color kPrimaryColor = Color(
  0xFFFEE500,
); // Yellow from the button and logo background
const Color kSecondaryColor = Color(0xFF00B894); // Teal/Green from the logo
const Color kTextColor = Colors.white;
const Color kButtonTextColor = Colors.black;
const Color kPrivacyTextColor = Color(
  0xFFCCCCCC,
); // A light gray for the privacy text

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isLoading = false;

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Request notification permission
      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Initialize local notifications
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Mark onboarding as completed
      final onboardingService = OnboardingService();
      await onboardingService.setOnboardingCompleted();

      // Navigate to main screen (browse mode)
      if (mounted) {
        context.go('/main');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.errorRequestingPermissions} ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Note: In a real application, the image would be loaded from assets.
    // For this example, we'll assume the image is available in the assets folder
    // and named 'burger_background.jpg'.
    const String backgroundImagePath = 'assets/images/burger_background.png';
    // The logo image would also be an asset.
    const String logoImagePath = 'assets/images/sika_logo_back.jpg';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image (Full screen)
          Image.asset(backgroundImagePath, fit: BoxFit.cover),

          // 2. Content Overlay (Logo, Text, Button, Privacy)
          // Using a SafeArea to respect the device's notch and system bars
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo Section (Top Center)
                  Center(
                    child: Image.asset(
                      logoImagePath,
                      height: 50, // Adjust size as needed
                      // In the image, the logo is a combination of yellow and a teal/green shape.
                      // Since we don't have the actual logo file, we'll simulate the look
                      // by using a placeholder and assuming the logo image is transparent
                      // or has the correct shape.
                      // For a better simulation, we can use a custom widget or a Stack,
                      // but for simplicity, we'll use a placeholder image.
                    ),
                  ),

                  // Spacer to push content to the bottom
                  const Spacer(),

                  // Welcome Text
                  Text(
                    AppLocalizations.of(context)!.welcomeToSika,
                    style: TextStyle(
                      color: kTextColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withValues(alpha: 0.5),
                          offset: const Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Always on Time, كرمال ما تنطر',
                    style: TextStyle(
                      color: kTextColor,
                      fontSize: 18,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withValues(alpha: 0.5),
                          offset: const Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _requestPermissions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const AppButtonLoader(size: 24)
                          : Text(
                              AppLocalizations.of(context)!.continueText,
                              style: const TextStyle(
                                color: kButtonTextColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Privacy Text and Disclaimer
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: kPrivacyTextColor,
                        fontSize: 12,
                        height: 1.5,
                        shadows: [
                          Shadow(
                            blurRadius: 5.0,
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      children: [
                        TextSpan(
                          text:
                              '${AppLocalizations.of(context)!.byContinuing}, ',
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context)!.privacyPolicy,
                          style: TextStyle(
                            color: Colors.blue, // Highlight the link color
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              /* navigate to policy */
                            },
                          // In a real app, you would add a recognizer for the tap
                          // recognizer: TapGestureRecognizer()..onTap = () { /* navigate to policy */ },
                        ),
                        TextSpan(
                          style: TextStyle(height: 1.5),
                          text:
                              '\n${AppLocalizations.of(context)!.locationAccessDisclaimer}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

