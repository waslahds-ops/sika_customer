import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

/// Configuration helper class that reads environment variables from .env file
class AppConfig {
  // Cache the values to avoid repeated lookups
  static String? _cachedApiBaseUrl;
  static String? _cachedImageServerUrl;

  /// Get the API base URL based on platform
  static String get apiBaseUrl {
    // Return cached value if available
    if (_cachedApiBaseUrl != null) {
      return _cachedApiBaseUrl!;
    }

    try {
      try {
        final baseUrl = Platform.isAndroid
            ? dotenv.env['API_BASE_URL_ANDROID']
            : dotenv.env['API_BASE_URL_IOS'];

        if (baseUrl == null || baseUrl.isEmpty) {
          debugPrint('⚠️ API_BASE_URL not configured in .env file');
          _cachedApiBaseUrl = 'http://127.0.0.1:8000';
          return _cachedApiBaseUrl!;
        }

        _cachedApiBaseUrl = baseUrl;
        return baseUrl;
      } catch (dotenvError) {
        // dotenv.env not initialized yet - use fallback
        debugPrint('⚠️ dotenv not ready yet, using fallback for API_BASE_URL');
        _cachedApiBaseUrl = 'http://127.0.0.1:8000';
        return _cachedApiBaseUrl!;
      }
    } catch (e) {
      debugPrint('❌ Error getting API_BASE_URL: $e');
      _cachedApiBaseUrl = 'http://127.0.0.1:8000';
      return _cachedApiBaseUrl!;
    }
  }

  /// Get the full API endpoint URL (base URL + API path)
  static String get apiEndpoint {
    try {
      try {
        final basePath = dotenv.env['API_BASE_PATH'] ?? '/api';
        return '$apiBaseUrl$basePath';
      } catch (dotenvError) {
        // dotenv.env not initialized yet
        return '$apiBaseUrl/api';
      }
    } catch (e) {
      debugPrint('❌ Error getting API_ENDPOINT: $e');
      return 'http://127.0.0.1:8000/api'; // Fallback
    }
  }

  /// Get the image server URL based on platform
  static String get imageServerUrl {
    // Return cached value if available
    if (_cachedImageServerUrl != null) {
      return _cachedImageServerUrl!;
    }

    try {
      try {
        final baseUrl = Platform.isAndroid
            ? dotenv.env['IMAGE_SERVER_URL_ANDROID']
            : dotenv.env['IMAGE_SERVER_URL_IOS'];

        if (baseUrl == null || baseUrl.isEmpty) {
          debugPrint('⚠️ IMAGE_SERVER_URL not configured in .env file');
          _cachedImageServerUrl = apiBaseUrl;
          return _cachedImageServerUrl!;
        }

        _cachedImageServerUrl = baseUrl;
        return baseUrl;
      } catch (dotenvError) {
        // dotenv.env not initialized yet
        debugPrint('⚠️ dotenv not ready yet, using API base URL for images');
        _cachedImageServerUrl = apiBaseUrl;
        return _cachedImageServerUrl!;
      }
    } catch (e) {
      debugPrint('❌ Error getting IMAGE_SERVER_URL: $e');
      _cachedImageServerUrl = apiBaseUrl;
      return _cachedImageServerUrl!;
    }
  }

  /// Get connection timeout in seconds
  static int get connectionTimeout {
    try {
      try {
        final timeout = dotenv.env['CONNECTION_TIMEOUT'] ?? '30';
        return int.tryParse(timeout) ?? 30;
      } catch (dotenvError) {
        return 30;
      }
    } catch (e) {
      debugPrint('❌ Error getting CONNECTION_TIMEOUT: $e');
      return 30;
    }
  }

  /// Get receive timeout in seconds
  static int get receiveTimeout {
    try {
      try {
        final timeout = dotenv.env['RECEIVE_TIMEOUT'] ?? '30';
        return int.tryParse(timeout) ?? 30;
      } catch (dotenvError) {
        return 30;
      }
    } catch (e) {
      debugPrint('❌ Error getting RECEIVE_TIMEOUT: $e');
      return 30;
    }
  }

  /// Get send timeout in seconds
  static int get sendTimeout {
    try {
      try {
        final timeout = dotenv.env['SEND_TIMEOUT'] ?? '30';
        return int.tryParse(timeout) ?? 30;
      } catch (dotenvError) {
        return 30;
      }
    } catch (e) {
      debugPrint('❌ Error getting SEND_TIMEOUT: $e');
      return 30;
    }
  }

  /// Get app name
  static String get appName {
    try {
      try {
        return dotenv.env['APP_NAME'] ?? 'Sika';
      } catch (dotenvError) {
        return 'Sika';
      }
    } catch (e) {
      return 'Sika';
    }
  }

  /// Get app version
  static String get appVersion {
    try {
      try {
        return dotenv.env['APP_VERSION'] ?? '1.0.0';
      } catch (dotenvError) {
        return '1.0.0';
      }
    } catch (e) {
      return '1.0.0';
    }
  }

  /// Get environment (development/staging/production)
  static String get environment {
    try {
      try {
        return dotenv.env['ENVIRONMENT'] ?? 'development';
      } catch (dotenvError) {
        return 'development';
      }
    } catch (e) {
      return 'development';
    }
  }

  /// Check if running in development mode
  static bool get isDevelopment {
    return environment == 'development';
  }

  /// Check if running in production mode
  static bool get isProduction {
    return environment == 'production';
  }
}
