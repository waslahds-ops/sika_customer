import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_pallete.dart';
import '../../../../core/providers/country_currency_provider.dart';
import '../../../../injection_container.dart';
import '../../../models/keeta_features.dart';

class VoucherBottomSheet extends ConsumerStatefulWidget {
  final double orderAmount;
  final Function(Voucher) onVoucherApplied;

  const VoucherBottomSheet({
    super.key,
    required this.orderAmount,
    required this.onVoucherApplied,
  });

  @override
  ConsumerState<VoucherBottomSheet> createState() => _VoucherBottomSheetState();
}

class _VoucherBottomSheetState extends ConsumerState<VoucherBottomSheet> {
  final TextEditingController _codeController = TextEditingController();
  Voucher? _appliedVoucher;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _applyVoucherCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter a voucher code');
      return;
    }

    setState(() => _isLoading = true);

    // Validate with API
    final useCase = ref.read(validatePromoCodeUseCaseProvider);
    final result = await useCase(code: code, orderAmount: widget.orderAmount);

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        setState(() => _errorMessage = 'Invalid or expired voucher code');
      },
      (response) {
        final isValid =
            response['is_valid'] == true || response['valid'] == true;

        if (isValid) {
          // Create mock Voucher object from response for now
          final voucher = Voucher(
            voucherId: response['id'] ?? 0,
            code: code,
            nameEn: response['title'] ?? code,
            nameAr: response['title_ar'] ?? code,
            descriptionEn: response['description'] ?? 'Valid voucher',
            descriptionAr: response['description_ar'] ?? 'كود صحيح',
            discountType: response['discount_type'] ?? 'percentage',
            discountValue:
                (response['discount_percentage'] ?? response['discount'] ?? 0)
                    .toDouble(),
            minOrderAmount: widget.orderAmount > 0 ? widget.orderAmount : null,
            maxDiscountAmount:
                (response['max_savings'] ?? response['max_discount'])
                    .toDouble(),
            validFrom: DateTime.now(),
            validUntil: DateTime.parse(
              response['valid_until'] ??
                  DateTime.now()
                      .add(const Duration(days: 30))
                      .toIso8601String(),
            ),
            usageLimit: null,
            usageCount: 0,
            isActive: true,
          );

          setState(() {
            _appliedVoucher = voucher;
            _errorMessage = null;
          });

          widget.onVoucherApplied(voucher);
        } else {
          setState(
            () => _errorMessage = response['message'] ?? 'Voucher not valid',
          );
        }
      },
    );
  }

  Future<List<Voucher>> _fetchAvailableVouchers() async {
    try {
      final useCase = ref.read(getCustomerPromoCodesUseCaseProvider);
      final result = await useCase();

      final vouchers = <Voucher>[];
      result.fold(
        (failure) {
          // Return empty list on failure
        },
        (list) {
          // Parse API response to Voucher objects
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              try {
                vouchers.add(
                  Voucher(
                    voucherId: item['id'] ?? 0,
                    code: item['code'] ?? '',
                    nameEn: item['title'] ?? '',
                    nameAr: item['title_ar'] ?? '',
                    descriptionEn: item['description'] ?? '',
                    descriptionAr: item['description_ar'] ?? '',
                    discountType: item['discount_type'] ?? 'percentage',
                    discountValue:
                        (item['discount_percentage'] ?? item['discount'] ?? 0)
                            .toDouble(),
                    minOrderAmount: (item['min_order_amount']).toDouble(),
                    maxDiscountAmount:
                        (item['max_savings'] ?? item['max_discount'] ?? 0)
                            .toDouble(),
                    validFrom: DateTime.now(),
                    validUntil: DateTime.parse(
                      item['valid_until'] ??
                          DateTime.now()
                              .add(const Duration(days: 30))
                              .toIso8601String(),
                    ),
                    usageLimit: null,
                    usageCount: 0,
                    isActive: true,
                  ),
                );
              } catch (e) {
                print('Error parsing voucher: $e');
              }
            }
          }
        },
      );
      return vouchers;
    } catch (e) {
      print('Error fetching vouchers: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyNotifier = ref.read(countryCurrencyProvider.notifier);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.local_offer, color: AppPallete.primaryTeal),
                const SizedBox(width: 12),
                const Text(
                  'Apply Voucher',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Code Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _codeController,
                        textDirection: TextDirection.ltr,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          hintText: 'Enter voucher code',
                          prefixIcon: const Icon(Icons.confirmation_number),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          errorText: _errorMessage,
                        ),
                        onSubmitted: (_) => _applyVoucherCode(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _applyVoucherCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPallete.primaryTeal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Apply',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ],
                ),
                if (_appliedVoucher != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _appliedVoucher!.nameEn,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                'You save ${currencyNotifier.formatConvertedPriceWithSymbolFromUsd(_appliedVoucher!.calculateDiscount(widget.orderAmount))}',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Available Vouchers
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Available Vouchers',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Flexible(
            child: FutureBuilder<List<Voucher>>(
              future: _fetchAvailableVouchers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  );
                }

                final vouchers = snapshot.data ?? [];

                if (vouchers.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No vouchers available',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: vouchers.length,
                  itemBuilder: (context, index) {
                    return _VoucherCard(
                      voucher: vouchers[index],
                      orderAmount: widget.orderAmount,
                      onTap: () {
                        _codeController.text = vouchers[index].code;
                        _applyVoucherCode();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VoucherCard extends ConsumerWidget {
  final Voucher voucher;
  final double orderAmount;
  final VoidCallback onTap;

  const _VoucherCard({
    required this.voucher,
    required this.orderAmount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyNotifier = ref.read(countryCurrencyProvider.notifier);
    final canUse =
        voucher.minOrderAmount == null ||
        orderAmount >= voucher.minOrderAmount!;
    final discount = voucher.calculateDiscount(orderAmount);

    return GestureDetector(
      onTap: canUse ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: canUse
                      ? [
                          AppPallete.primaryTeal,
                          AppPallete.primaryTeal.withValues(alpha: 0.7),
                        ]
                      : [Colors.grey[300]!, Colors.grey[200]!],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Voucher Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.local_offer,
                      color: canUse ? Colors.white : Colors.grey[600],
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Voucher Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          voucher.nameEn,
                          style: TextStyle(
                            color: canUse ? Colors.white : Colors.grey[700],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          voucher.descriptionEn,
                          style: TextStyle(
                            color: canUse
                                ? Colors.white.withValues(alpha: 0.9)
                                : Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                voucher.code,
                                style: TextStyle(
                                  color: canUse
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            if (canUse) ...[
                              const SizedBox(width: 8),
                              Text(
                                'Save ${currencyNotifier.formatConvertedPriceWithSymbolFromUsd(discount)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (!canUse && voucher.minOrderAmount != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Min order: ${currencyNotifier.formatConvertedPriceWithSymbolFromUsd(voucher.minOrderAmount!)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Arrow
                  Icon(
                    Icons.arrow_forward_ios,
                    color: canUse ? Colors.white : Colors.grey[600],
                    size: 16,
                  ),
                ],
              ),
            ),
            // Dotted Edge Effect
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: CustomPaint(
                size: const Size(8, 100),
                painter: _DottedLinePainter(
                  color: canUse
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.grey[400]!,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;

  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashHeight = 5.0;
    const dashSpace = 3.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(4, startY), Offset(4, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
