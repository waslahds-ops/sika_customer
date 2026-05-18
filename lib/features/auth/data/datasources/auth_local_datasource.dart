import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

abstract class AuthLocalDataSource {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
  Future<Map<String, dynamic>?> getUserData();
  Future<void> saveUserData(Map<String, dynamic> userData);
  Future<void> deleteUserData();
  Future<void> saveVerificationCode(String code);
  Future<String?> getVerificationCode();
  Future<void> deleteVerificationCode();
  Future<void> saveVerificationCodeTimestamp(int timestamp);
  Future<int?> getVerificationCodeTimestamp();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _authBoxName = 'authBox';
  static const String _tokenKey = 'accessToken';
  static const String _userDataKey = 'userData';
  static const String _verificationCodeKey = 'verificationCode';
  static const String _verificationCodeTimestampKey =
      'verificationCodeTimestamp';

  Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_authBoxName)) {
      return await Hive.openBox(_authBoxName);
    }
    return Hive.box(_authBoxName);
  }

  @override
  Future<String?> getToken() async {
    try {
      final box = await _getBox();
      debugPrint('Retrieved token: ${box.get(_tokenKey)}');
      return box.get(_tokenKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      final box = await _getBox();
      await box.put(_tokenKey, token);
    } catch (e) {
      throw Exception('Failed to save token: $e');
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      final box = await _getBox();
      await box.delete(_tokenKey);
    } catch (e) {
      throw Exception('Failed to delete token: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final box = await _getBox();
      final data = box.get(_userDataKey);
      if (data != null) {
        debugPrint('📦 Retrieved user data from Hive: ${data.runtimeType}');
        return Map<String, dynamic>.from(data as Map);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user data: $e');
      return null;
    }
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final box = await _getBox();
      debugPrint('💾 Saving user data to Hive');
      await box.put(_userDataKey, userData);
      debugPrint('✅ User data saved successfully');
    } catch (e) {
      debugPrint('❌ Failed to save user data: $e');
      throw Exception('Failed to save user data: $e');
    }
  }

  @override
  Future<void> deleteUserData() async {
    try {
      final box = await _getBox();
      await box.delete(_userDataKey);
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  @override
  Future<void> saveVerificationCode(String code) async {
    try {
      final box = await _getBox();
      await box.put(_verificationCodeKey, code);
      debugPrint('💾 Verification code saved to secure storage');
    } catch (e) {
      throw Exception('Failed to save verification code: $e');
    }
  }

  @override
  Future<String?> getVerificationCode() async {
    try {
      final box = await _getBox();
      final code = box.get(_verificationCodeKey);
      if (code != null) {
        debugPrint('✅ Verification code retrieved from secure storage');
      }
      return code;
    } catch (e) {
      debugPrint('❌ Error retrieving verification code: $e');
      return null;
    }
  }

  @override
  Future<void> deleteVerificationCode() async {
    try {
      final box = await _getBox();
      await box.delete(_verificationCodeKey);
      await box.delete(_verificationCodeTimestampKey);
      debugPrint('🗑️ Verification code deleted from secure storage');
    } catch (e) {
      throw Exception('Failed to delete verification code: $e');
    }
  }

  @override
  Future<void> saveVerificationCodeTimestamp(int timestamp) async {
    try {
      final box = await _getBox();
      await box.put(_verificationCodeTimestampKey, timestamp);
      debugPrint('💾 Verification code timestamp saved: $timestamp');
    } catch (e) {
      throw Exception('Failed to save verification code timestamp: $e');
    }
  }

  @override
  Future<int?> getVerificationCodeTimestamp() async {
    try {
      final box = await _getBox();
      final timestamp = box.get(_verificationCodeTimestampKey) as int?;
      return timestamp;
    } catch (e) {
      debugPrint('❌ Error retrieving verification code timestamp: $e');
      return null;
    }
  }
}
