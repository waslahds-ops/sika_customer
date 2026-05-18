import 'package:hive/hive.dart';

/// Service to manage password verification timeouts
class PasswordVerificationService {
  static const String _boxName = 'password_verification';
  static const String _lastVerificationKey = 'last_verification_timestamp';
  static const String _hasPasswordKey = 'has_password';
  static const Duration _verificationTimeout = Duration(hours: 72);

  late Box<dynamic> _box;

  /// Initialize the service
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  /// Check if password verification is needed
  Future<bool> isPasswordVerificationNeeded() async {
    final hasPassword = _box.get(_hasPasswordKey, defaultValue: false) as bool;

    if (!hasPassword) {
      return false; // No password set, no verification needed
    }

    final lastVerificationTimestamp = _box.get(_lastVerificationKey) as String?;

    if (lastVerificationTimestamp == null) {
      return true; // Never verified, need verification
    }

    try {
      final lastVerification = DateTime.parse(lastVerificationTimestamp);
      final now = DateTime.now();
      final difference = now.difference(lastVerification);

      return difference >= _verificationTimeout;
    } catch (e) {
      return true; // On error, ask for verification
    }
  }

  /// Mark password as verified
  Future<void> markPasswordVerified() async {
    final now = DateTime.now();
    await _box.put(_lastVerificationKey, now.toIso8601String());
  }

  /// Mark that user has set a password
  Future<void> markPasswordSet() async {
    await _box.put(_hasPasswordKey, true);
    await markPasswordVerified();
  }

  /// Mark that user doesn't have a password
  Future<void> markNoPassword() async {
    await _box.put(_hasPasswordKey, false);
  }

  /// Get time remaining until next verification
  Future<Duration?> getTimeUntilNextVerification() async {
    final hasPassword = _box.get(_hasPasswordKey, defaultValue: false) as bool;

    if (!hasPassword) {
      return null;
    }

    final lastVerificationTimestamp = _box.get(_lastVerificationKey) as String?;

    if (lastVerificationTimestamp == null) {
      return null;
    }

    try {
      final lastVerification = DateTime.parse(lastVerificationTimestamp);
      final nextVerification = lastVerification.add(_verificationTimeout);
      final now = DateTime.now();

      if (nextVerification.isAfter(now)) {
        return nextVerification.difference(now);
      }
      return null; // Verification is due
    } catch (e) {
      return null;
    }
  }

  /// Clear verification data
  Future<void> clearVerificationData() async {
    await _box.delete(_lastVerificationKey);
    await _box.delete(_hasPasswordKey);
  }

  /// Close the box
  Future<void> close() async {
    await _box.close();
  }
}
