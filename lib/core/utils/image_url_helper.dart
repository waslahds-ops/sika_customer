import '../config/app_config.dart';

/// Helper class to manage image URLs from the backend
class ImageUrlHelper {
  // Base URL configuration - loaded from .env file
  static String get baseUrl {
    try {
      return AppConfig.imageServerUrl;
    } catch (e) {
      // Silently use fallback if AppConfig is not ready (NotInitializedError)
      // This is normal during app startup
      return 'http://127.0.0.1:8000'; // Fallback
    }
  }

  static String? toFullUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    // If it's already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    try {
      // If it starts with /, remove it first
      String cleanPath = imagePath.startsWith('/')
          ? imagePath.substring(1)
          : imagePath;

      // Combine base URL with path
      final fullUrl = '$baseUrl/$cleanPath';
      // Silently return the full URL without logging every conversion
      return fullUrl;
    } catch (e) {
      // Silently use fallback if conversion fails
      return imagePath; // Return original path as fallback
    }
  }

  /// Gets a placeholder color based on store or product name
  static int getPlaceholderColor(String? name) {
    if (name == null || name.isEmpty) return 0xFF9E9E9E;

    final hashCode = name.hashCode;
    final colors = [
      0xFFE53935, // Red
      0xFFD81B60, // Pink
      0xFF7E57C2, // Purple
      0xFF3949AB, // Indigo
      0xFF039BE5, // Blue
      0xFF43A047, // Green
      0xFFFDD835, // Amber
      0xFFFB8C00, // Orange
    ];

    return colors[hashCode.abs() % colors.length];
  }
}
