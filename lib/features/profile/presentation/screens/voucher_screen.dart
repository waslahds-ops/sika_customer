import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sika_customer/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

// Mock promo code model (replace with actual when API is ready)
class PromoCodeEntity {
  final int id;
  final String code;
  final String title;
  final String description;
  final double discountPercentage;
  final double maxSavings;
  final DateTime validUntil;
  final bool isUsed;
  final double minOrderAmount;

  PromoCodeEntity({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.maxSavings,
    required this.validUntil,
    required this.isUsed,
    required this.minOrderAmount,
  });
}

class VouchersScreen extends ConsumerStatefulWidget {
  const VouchersScreen({super.key});

  @override
  ConsumerState<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends ConsumerState<VouchersScreen> {
  final TextEditingController _promoController = TextEditingController();
  bool _showPastVouchers = false;
  bool _isValidating = false;
  String? _validationMessage;
  bool? _isValidCode;
  bool _isLoadingVouchers = false;
  bool _fetchedVouchers = false;
  List<PromoCodeEntity> _availableVouchers = [];

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchVouchers());
  }

  Future<void> _fetchVouchers() async {
    setState(() {
      _isLoadingVouchers = true;
      _fetchedVouchers = false;
    });

    try {
      final res = await ref.read(getCustomerPromoCodesUseCaseProvider)();
      res.fold(
        (failure) {
          // failure: mark fetched but keep list empty
          setState(() {
            _availableVouchers = [];
            _fetchedVouchers = true;
          });
        },
        (list) {
          // parse list into PromoCodeEntity
          final parsed = list.map<PromoCodeEntity>((dynamic item) {
            try {
              final map = item as Map<String, dynamic>;
              return PromoCodeEntity(
                id: (map['id'] ?? 0) is int
                    ? (map['id'] as int)
                    : int.tryParse(map['id'].toString()) ?? 0,
                code: (map['code'] ?? '').toString(),
                title: (map['title'] ?? '').toString(),
                description: (map['description'] ?? '').toString(),
                discountPercentage:
                    double.tryParse(
                      (map['discount_percentage'] ?? map['discount'] ?? 0)
                          .toString(),
                    ) ??
                    0.0,
                maxSavings:
                    double.tryParse(
                      (map['max_savings'] ?? map['max_saving'] ?? 0).toString(),
                    ) ??
                    0.0,
                validUntil: map.containsKey('valid_until')
                    ? DateTime.tryParse(map['valid_until'].toString()) ??
                          DateTime.now()
                    : DateTime.now(),
                isUsed: (map['is_used'] ?? false) as bool,
                minOrderAmount:
                    double.tryParse(
                      (map['min_order_amount'] ?? 0).toString(),
                    ) ??
                    0.0,
              );
            } catch (_) {
              return PromoCodeEntity(
                id: 0,
                code: '',
                title: '',
                description: '',
                discountPercentage: 0,
                maxSavings: 0,
                validUntil: DateTime.now(),
                isUsed: false,
                minOrderAmount: 0,
              );
            }
          }).toList();

          setState(() {
            _availableVouchers = parsed;
            _fetchedVouchers = true;
          });
        },
      );
    } catch (e) {
      setState(() {
        _availableVouchers = [];
        _fetchedVouchers = true;
      });
    } finally {
      setState(() => _isLoadingVouchers = false);
    }
  }

  Future<void> _validatePromoCode() async {
    if (_promoController.text.isEmpty) {
      setState(() {
        _validationMessage = AppLocalizations.of(context)!.pleaseEnterAPromoCode;
        _isValidCode = false;
      });
      return;
    }

    setState(() => _isValidating = true);

    try {
      final res = await ref.read(validatePromoCodeUseCaseProvider)(
        code: _promoController.text,
        orderAmount: null,
      );

      res.fold(
        (failure) {
          setState(() {
            _isValidCode = false;
            _validationMessage = failure.message;
          });
        },
        (data) {
          final success = data['success'] == true;
          setState(() {
            _isValidCode = success;
            _validationMessage =
                data['message']?.toString() ??
                (success ? AppLocalizations.of(context)!.promoCodeApplied : AppLocalizations.of(context)!.invalidPromoCode);
          });

          if (success) {
            // Extract voucher details from response
            double discountPercentage = 0.0;
            double maxSavings = 0.0;

            if (data['discount_percentage'] != null) {
              discountPercentage =
                  double.tryParse(data['discount_percentage'].toString()) ??
                  0.0;
            }

            if (data['max_savings'] != null) {
              maxSavings =
                  double.tryParse(data['max_savings'].toString()) ?? 0.0;
            }

            // Apply voucher to cart
            final code = _promoController.text.toUpperCase();
            ref
                .read(cartProvider.notifier)
                .applyVoucher(
                  code,
                  discountPercentage: discountPercentage > 0
                      ? discountPercentage
                      : null,
                  maxSavings: maxSavings > 0 ? maxSavings : null,
                );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_validationMessage ?? AppLocalizations.of(context)!.promoCodeApplied),
                backgroundColor: Colors.green,
              ),
            );

            _promoController.clear();
            // Refresh vouchers list in case server marks it used
            _fetchVouchers();

            // Pop back after 1 second to show the applied voucher in cart
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) Navigator.pop(context);
            });
          }
        },
      );
    } catch (e) {
      setState(() {
        _isValidCode = false;
        _validationMessage = '${AppLocalizations.of(context)!.errorValidatingCode}: $e';
      });
    } finally {
      setState(() => _isValidating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final availableVouchers = _fetchedVouchers ? _availableVouchers : [];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.vouchers,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _showPastVouchers = !_showPastVouchers);
            },
            child: Text(
              _showPastVouchers ? AppLocalizations.of(context)!.available : AppLocalizations.of(context)!.pastVouchers,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Promo Code Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.local_offer_outlined, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _promoController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.enterPromoCode,
                          border: InputBorder.none,
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        onChanged: (value) {
                          setState(() => _validationMessage = null);
                        },
                      ),
                    ),
                    _isValidating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : SizedBox(
                            width: 40,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.check_circle),
                              color: _isValidCode == true
                                  ? Colors.green
                                  : Colors.grey,
                              onPressed: _validatePromoCode,
                            ),
                          ),
                  ],
                ),
                if (_validationMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _validationMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: _isValidCode == true ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (!_showPastVouchers) ...[
            // Invite Friends Banner
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D9B5), Color(0xFF00BFA5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 20,
                    top: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.invite,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          l10n.friends,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.winVouchers,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          l10n.worth210000Lbp,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.worth210000Lbp,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: ElevatedButton(
                      onPressed: () {
                        try {
                          Share.share(
                            AppLocalizations.of(context)!.inviteFriendsAndWinVouchers,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${AppLocalizations.of(context)!.unableToShare}: $e')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.share, size: 18),
                          const SizedBox(width: 8),
                          Text(l10n.inviteAndWin),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 5,
                    child: Text(
                      l10n.tcApply,
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Available Vouchers Header
            Text(
              l10n.availableVouchers,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
          ] else ...[
            // Past Vouchers Header
            Text(
              l10n.pastVouchers,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Voucher Cards
          if (_isLoadingVouchers)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            ),
          ...availableVouchers
              .where((v) => !_showPastVouchers ? !v.isUsed : v.isUsed)
              .map(
                (voucher) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: VoucherCard(
                    promoCode: voucher.code,
                    discount: '${voucher.discountPercentage.toInt()}% off',
                    description:
                        '${AppLocalizations.of(context)!.minOrder} ${voucher.minOrderAmount.toStringAsFixed(0)} LBP. ${AppLocalizations.of(context)!.saveUpTo} ${voucher.maxSavings.toStringAsFixed(0)} LBP',
                    title: voucher.title,
                    validUntil:
                        '${AppLocalizations.of(context)!.validUntil} ${_formatDate(voucher.validUntil)}',
                    isExpired: voucher.validUntil.isBefore(DateTime.now()),
                    isUsed: voucher.isUsed,
                    onApply: () {
                      if (!voucher.isUsed &&
                          !voucher.validUntil.isBefore(DateTime.now())) {
                        _promoController.text = voucher.code;
                        _validatePromoCode();
                      }
                    },
                    onShare: () {
                      try {
                        Share.share(
                          '${AppLocalizations.of(context)!.useCode} ${voucher.code} - ${voucher.title}. ${voucher.discountPercentage.toInt()}% ${AppLocalizations.of(context)!.off} ${AppLocalizations.of(context)!.upTo} ${voucher.maxSavings.toStringAsFixed(0)} LBP. ${AppLocalizations.of(context)!.minOrder} ${voucher.minOrderAmount.toStringAsFixed(0)} LBP. ${AppLocalizations.of(context)!.validUntil} ${_formatDate(voucher.validUntil)}. ${AppLocalizations.of(context)!.getTheAppToRedeem}.',
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${AppLocalizations.of(context)!.unableToShare}: $e')),
                        );
                      }
                    },
                  ),
                ),
              ),

          if (availableVouchers
              .where((v) => !_showPastVouchers ? !v.isUsed : v.isUsed)
              .isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      _showPastVouchers ? Icons.history : Icons.local_offer,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _showPastVouchers
                          ? AppLocalizations.of(context)!.noPastVouchers
                          : AppLocalizations.of(context)!.noAvailableVouchers,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${_padZero(date.day)} ${_monthName(date.month)} ${date.year} ${_padZero(date.hour)}:${_padZero(date.minute)}';
  }

  String _padZero(int value) => value.toString().padLeft(2, '0');

  String _monthName(int month) {
    final months = [
      AppLocalizations.of(context)!.jan,
      AppLocalizations.of(context)!.feb,
      AppLocalizations.of(context)!.mar,
      AppLocalizations.of(context)!.apr,
      AppLocalizations.of(context)!.may,
      AppLocalizations.of(context)!.jun,
      AppLocalizations.of(context)!.jul,
      AppLocalizations.of(context)!.aug,
      AppLocalizations.of(context)!.sep,
      AppLocalizations.of(context)!.oct,
      AppLocalizations.of(context)!.nov,
      AppLocalizations.of(context)!.dec,
    ];
    return months[month - 1];
  }
}

class VoucherCard extends StatelessWidget {
  final String promoCode;
  final String discount;
  final String description;
  final String title;
  final String validUntil;
  final bool isExpired;
  final bool isUsed;
  final VoidCallback onApply;
  final VoidCallback? onShare;

  const VoucherCard({
    Key? key,
    required this.promoCode,
    required this.discount,
    required this.description,
    required this.title,
    required this.validUntil,
    required this.isExpired,
    required this.isUsed,
    required this.onApply,
    this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDisabled = isExpired || isUsed;
    final gradientColors = isUsed
        ? [Colors.grey[300]!, Colors.grey[200]!]
        : [Colors.orange[100]!, Colors.orange[50]!];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Opacity(
        opacity: isDisabled ? 0.6 : 1.0,
        child: Row(
          children: [
            // Voucher Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_offer,
                color: isUsed ? Colors.grey[600] : Colors.orange,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),

            // Voucher Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    discount,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isUsed ? Colors.grey[600] : Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isUsed ? Colors.grey[500] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isUsed ? Colors.grey[600] : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          validUntil,
                          style: TextStyle(
                            fontSize: 12,
                            color: isExpired
                                ? Colors.red[300]
                                : Colors.grey[500],
                          ),
                        ),
                      ),
                      if (!isUsed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            promoCode,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Share Button
            IconButton(
              onPressed: isDisabled ? null : onShare,
              icon: const Icon(Icons.share),
              color: isDisabled ? Colors.grey : Colors.black,
            ),

            const SizedBox(width: 4),

            // Apply/Used Button
            ElevatedButton(
              onPressed: isDisabled ? null : onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDisabled
                    ? Colors.grey[400]
                    : const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                elevation: 0,
              ),
              child: Text(
                isUsed
                    ? AppLocalizations.of(context)!.used
                    : isExpired
                    ? AppLocalizations.of(context)!.expired
                    : AppLocalizations.of(context)!.apply,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
