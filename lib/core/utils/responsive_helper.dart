import 'package:flutter/material.dart';

/// Helper class for responsive design using MediaQuery
class ResponsiveHelper {
  /// Get screen size
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Get screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 600) {
      return DeviceType.mobile;
    } else if (width < 1024) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 600) {
      return const EdgeInsets.all(16);
    } else if (width < 1024) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobileSize,
    double? tabletSize,
    double? desktopSize,
  }) {
    final width = getScreenWidth(context);
    if (width < 600) {
      return mobileSize;
    } else if (width < 1024) {
      return tabletSize ?? mobileSize * 1.2;
    } else {
      return desktopSize ?? mobileSize * 1.4;
    }
  }

  /// Get responsive grid count
  static int getGridCount(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 600) {
      return 2;
    } else if (width < 1024) {
      return 3;
    } else {
      return 4;
    }
  }

  /// Get responsive aspect ratio for grid items
  static double getGridAspectRatio(BuildContext context) {
    final width = getScreenWidth(context);
    if (width < 600) {
      return 0.9;
    } else if (width < 1024) {
      return 1.0;
    } else {
      return 1.2;
    }
  }

  /// Get responsive width constraint
  static double getMaxWidth(BuildContext context, {double maxPercent = 0.9}) {
    return getScreenWidth(context) * maxPercent;
  }
}

enum DeviceType { mobile, tablet, desktop }
