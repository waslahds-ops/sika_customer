import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/voucher_model.dart';
import '../services/voucher_service.dart';
import '../../injection_container.dart';

/// Provider for VoucherService
final voucherServiceProvider = Provider<VoucherService>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return VoucherService(dioClient: dioClient);
});

/// Provider to fetch random popup voucher
final popupVoucherProvider = FutureProvider<VoucherModel?>((ref) async {
  final service = ref.read(voucherServiceProvider);
  return service.getRandomPopupVoucher();
});

/// Provider to fetch popup voucher gallery
final popupVoucherGalleryProvider = FutureProvider<List<VoucherModel>>((ref) async {
  final service = ref.read(voucherServiceProvider);
  return service.getPopupVoucherGallery(limit: 5);
});
