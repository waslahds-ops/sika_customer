/// Validation utilities for the app
class Validators {
  /// Validates phone number based on country code
  static bool isValidPhone(String phone, String countryCode) {
    // Remove all spaces, dashes, and parentheses
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    switch (countryCode) {
      case 'LB': // Lebanon - accepts 03, 70, 71, 76, 81 (with or without leading 0)
        // Matches: +96103xxxxxx, 03xxxxxx, 3xxxxxx, 70xxxxxx, 71xxxxxx, 76xxxxxx, 81xxxxxx
        final regex = RegExp(r'^(\+961|00961|961)?(0?3|70|71|76|81)\d{6}$');
        return regex.hasMatch(cleaned);
      case 'SA': // Saudi Arabia
        final regex = RegExp(r'^(\+966|00966|966)?5[0-9]\d{7}$');
        return regex.hasMatch(cleaned);
      case 'KW': // Kuwait
        final regex = RegExp(r'^(\+965|00965|965)?[569]\d{7}$');
        return regex.hasMatch(cleaned);
      case 'BH': // Bahrain
        final regex = RegExp(r'^(\+973|00973|973)?[3679]\d{7}$');
        return regex.hasMatch(cleaned);
      case 'OM': // Oman
        final regex = RegExp(r'^(\+968|00968|968)?[79]\d{7}$');
        return regex.hasMatch(cleaned);
      case 'JO': // Jordan
        final regex = RegExp(r'^(\+962|00962|962)?7[789]\d{7}$');
        return regex.hasMatch(cleaned);
      case 'EG': // Egypt
        final regex = RegExp(r'^(\+20|0020|20)?1[0-5]\d{8}$');
        return regex.hasMatch(cleaned);
      case 'TR': // Turkey
        final regex = RegExp(r'^(\+90|0090|90)?5\d{9}$');
        return regex.hasMatch(cleaned);
      default:
        // Generic phone validation
        final regex = RegExp(r'^[+]?[0-9]{10,15}$');
        return regex.hasMatch(cleaned);
    }
  }

  /// Validates Lebanese phone numbers (legacy - kept for backward compatibility)
  /// Accepts formats:
  /// - +961 3 123456, +961 70 123456 (with spaces)
  /// - 3 123456, 70 123456 (without country code)
  /// NOT allowed: 03, 01 (must be single digit 3, or two digits 70, 71, 76, 78, 79, 81)
  static bool isValidLebanesePhone(String phone) {
    return isValidPhone(phone, 'LB');
  }

  /// Formats phone number based on country dial code
  /// Returns format with country code: +961 3 123456
  static String formatPhone(String phone, String dialCode, String countryCode) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    String number = cleaned;

    // Remove any existing country code prefix
    final codeWithoutPlus = dialCode.replaceAll('+', '');
    if (number.startsWith('+$codeWithoutPlus')) {
      number = number.substring(codeWithoutPlus.length + 1);
    } else if (number.startsWith('00$codeWithoutPlus')) {
      number = number.substring(codeWithoutPlus.length + 2);
    } else if (number.startsWith(codeWithoutPlus)) {
      number = number.substring(codeWithoutPlus.length);
    }

    // Remove leading zero if present for most countries
    if (number.startsWith('0') && countryCode != 'EG') {
      number = number.substring(1);
    }

    // Return in format: +dialCode number
    return '$dialCode$number';
  }

  /// Formats Lebanese phone number to format: 3 123456 (without +961)
  /// Backend expects format without country code and without leading zero
  static String formatLebanesePhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    String number = cleaned;

    // Remove country code if present
    if (number.startsWith('+961')) {
      number = number.substring(4);
    } else if (number.startsWith('00961')) {
      number = number.substring(5);
    } else if (number.startsWith('961')) {
      number = number.substring(3);
    }

    // Remove leading zero if present (03 -> 3)
    if (number.startsWith('0')) {
      number = number.substring(1);
    }

    // Format as: operator + space + number
    // e.g., "3123456" becomes "3 123456"
    if (number.length == 7) {
      return '${number.substring(0, 1)} ${number.substring(1)}';
    } else if (number.length == 8) {
      return '${number.substring(0, 2)} ${number.substring(2)}';
    }

    return number;
  }

  /// Validates email format
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  /// Gets validation error message for phone based on country
  static String? validatePhone(
    String? value,
    String countryCode,
    String countryName,
  ) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    if (!isValidPhone(value, countryCode)) {
      return 'Enter a valid $countryName phone number';
    }

    return null;
  }

  /// Gets validation error message for Lebanese phone
  static String? validateLebanesePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    if (!isValidLebanesePhone(value)) {
      return 'Enter a valid Lebanese phone number\n(e.g., 03 123456, 70 123456, or +961 3 123456)';
    }

    return null;
  }

  /// Gets validation error message for email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    if (!isValidEmail(value)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  /// Validates email or phone based on country
  static String? validateEmailOrPhone(
    String? value, {
    String countryCode = 'LB',
    String countryName = 'Lebanese',
  }) {
    if (value == null || value.isEmpty) {
      return 'Email or phone number is required';
    }

    // Check if it looks like an email
    if (value.contains('@')) {
      return validateEmail(value);
    }

    // Otherwise validate as phone for the selected country
    return validatePhone(value, countryCode, countryName);
  }
}
