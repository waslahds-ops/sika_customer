import 'package:flutter/material.dart';

class AppPallete {
  // Primary Brand Colors - Golden Yellow (from SIKA logo)
  static const primaryYellow = Color(0xffFDB714);
  static const primaryYellowDark = Color(0xffD99E00);
  static const primaryYellowLight = Color(0xffFFC850);

  // Secondary Brand Colors - Rich Dark Tones
  static const primaryDark = Color(0xff1C1C1E); // Deep charcoal
  static const primaryDarkLight = Color(0xff2C2C2E);
  static const primaryGrey = Color(0xff48484A);

  // Accent Colors - Warm palette
  static const gold = Color(0xffFFD700);
  static const amber = Color(0xffFFB300); // Complementary warm tone
  static const warmGrey = Color(0xff8E8E93);

  // Legacy colors (mapped for backward compatibility)
  static const primaryTeal = Color(0xff1C1C1E); // Dark backgrounds
  static const primaryTealDark = Color(0xff000000);
  static const primaryTealLight = Color(0xff2C2C2E);
  static const primaryGreen = Color(0xffFDB714); // Yellow for CTAs
  static const primaryGreenDark = Color(0xffD99E00);
  static const primaryGreenLight = Color(0xffFFC850);
  static const lime = Color(0xffFFC850);

  // Background Colors - Clean & Modern
  static const backgroundColor = Color(0xffFFFFFF);
  static const backgroundLight = Color(0xffFAFAFA);
  static const backgroundDark = Color(0xff1C1C1E);
  static const cardBackground = Color(0xffFFFFFF);
  static const surfaceLight = Color(0xffF2F2F7);

  // Text Colors - High Contrast
  static const textPrimary = Color(0xff1C1C1E);
  static const textSecondary = Color(0xff636366);
  static const textTertiary = Color(0xff8E8E93);
  static const textOnDark = Color(0xffFFFFFF);
  static const textOnYellow = Color(0xff1C1C1E);

  // UI Colors
  static const white = Color(0xffFFFFFF);
  static const black = Color(0xff000000);
  static const grey = Color(0xff8E8E93);
  static const greyLight = Color(0xffE5E5EA);
  static const greyDark = Color(0xff48484A);

  // Status Colors
  static const success = Color(0xff34C759);
  static const error = Color(0xffFF3B30);
  static const warning = Color(0xffFF9500);
  static const info = Color(0xff007AFF);

  // Transparent
  static const transparent = Colors.transparent;

  // Gradients - Elegant & Warm
  static const yellowGradient = LinearGradient(
    colors: [Color(0xffFDB714), Color(0xffFFD54F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkGradient = LinearGradient(
    colors: [Color(0xff1C1C1E), Color(0xff2C2C2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const tealGreenGradient = LinearGradient(
    colors: [Color(0xff1C1C1E), Color(0xff2C2C2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const greenGradient = LinearGradient(
    colors: [Color(0xffFDB714), Color(0xffFFC850)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const splashGradient = LinearGradient(
    colors: [Color(0xffFFFFFF), Color(0xffFAFAFA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const warmGradient = LinearGradient(
    colors: [Color(0xffFDB714), Color(0xffFFB300), Color(0xffFFC850)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
