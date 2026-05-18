import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Debug utility for Maps and Location services
class MapsDebug {
  static Future<void> checkMapsSetup() async {
    // Check location services
    await Geolocator.isLocationServiceEnabled();

    // Check permission status
    LocationPermission permission = await Geolocator.checkPermission();

    // List permission details

    // Try to get position if permissions allow
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        debugPrint(
          '✅ Current Position: ${position.latitude}, ${position.longitude}',
        );
      } catch (e) {
        debugPrint('❌ Error getting position: $e');
      }
    } else {
      debugPrint('⚠️  Cannot get position - permission not granted');
    }

    // Check Google Maps API key
    debugPrint('🗺️  Google Maps API Key configured in:');
    debugPrint(
      '   - Android: AndroidManifest.xml (com.google.android.geo.API_KEY)',
    );
    debugPrint('   - iOS: Info.plist (com.google.ios.maps.API_KEY)');

    debugPrint('=== END DEBUG ===');
  }
}
