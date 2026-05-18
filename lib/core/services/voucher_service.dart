import 'package:flutter/foundation.dart';
import '../../core/network/dio_client.dart';
import '../models/voucher_model.dart';

class VoucherService {
  final DioClient dioClient;

  VoucherService({required this.dioClient});

  /// Fetch a random popup voucher from the API
  Future<VoucherModel?> getRandomPopupVoucher() async {
    try {
      debugPrint('🎟️ Fetching random popup voucher...');
      
      final response = await dioClient.get(
        '/public/vouchers/popup/random',
      );

      if (response != null) {
        debugPrint('✅ Got popup voucher: ${response.toString()}');
        final voucher = VoucherModel.fromJson(response as Map<String, dynamic>);
        return voucher;
      }
    } catch (e) {
      debugPrint('❌ Error fetching popup voucher: $e');
    }
    return null;
  }

  /// Fetch multiple popup vouchers for gallery
  Future<List<VoucherModel>> getPopupVoucherGallery({int limit = 5}) async {
    try {
      debugPrint('🎟️ Fetching popup voucher gallery (limit: $limit)...');
      
      final response = await dioClient.get(
        '/public/vouchers/popup/gallery?limit=$limit',
      );

      if (response != null && response is List) {
        final vouchers = (response as List)
            .map((v) => VoucherModel.fromJson(v as Map<String, dynamic>))
            .toList();
        debugPrint('✅ Got ${vouchers.length} vouchers for gallery');
        return vouchers;
      }
    } catch (e) {
      debugPrint('❌ Error fetching voucher gallery: $e');
    }
    return [];
  }
}
