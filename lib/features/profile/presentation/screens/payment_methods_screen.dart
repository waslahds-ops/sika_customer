import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/payment_provider.dart';
import '../../../../features/models/models.dart';
import '../../../../l10n/app_localizations.dart';

// Custom formatter for card number (spaces every 4 digits)
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// Custom formatter for expiry date (MM/YY)
class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    if (text.length <= 2) {
      return newValue.copyWith(text: text);
    }

    // Format as MM/YY
    final month = text.substring(0, 2);
    final year = text.substring(2, text.length > 4 ? 4 : text.length);

    // Validate month (01-12)
    final monthInt = int.tryParse(month) ?? 0;
    if (monthInt < 1 || monthInt > 12) {
      // Keep only what was valid
      return oldValue;
    }

    final string = '$month/$year';
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() =>
      _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    // Load payment methods when screen initializes
    Future.microtask(() => ref.refresh(paymentMethodsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethodsState = ref.watch(paymentMethodsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.paymentMethods,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Add new card section
            GestureDetector(
              onTap: () => _showAddCardSheet(),
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.credit_card,
                          color: Colors.black54,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.addNewCard,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _CardBrandLogo(
                                  'assets/images/visa.png',
                                  'VISA',
                                ),
                                const SizedBox(width: 8),
                                _CardBrandLogo(
                                  'assets/images/mastercard.png',
                                  'MC',
                                ),
                                const SizedBox(width: 8),
                                _CardBrandLogo(
                                  'assets/images/amex.png',
                                  'AMEX',
                                ),
                                const SizedBox(width: 8),
                                _CardBrandLogo(
                                  'assets/images/visa_electron.png',
                                  'VE',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.black54,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            // Saved cards list
            paymentMethodsState.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFDB714)),
                ),
              ),
              error: (error, stackTrace) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${AppLocalizations.of(context)!.errorLoadingPaymentMethods}: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              data: (paymentMethods) {
                if (paymentMethods.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      AppLocalizations.of(context)!.noSavedCardsYet,
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: paymentMethods.length,
                  itemBuilder: (context, index) {
                    final paymentMethod = paymentMethods[index];
                    return _buildPaymentMethodCard(
                      paymentMethod,
                      onDelete: () =>
                          _deletePaymentMethod(paymentMethod.paymentMethodId),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    PaymentMethod paymentMethod, {
    required VoidCallback onDelete,
  }) {
    final isExpired = paymentMethod.isExpired();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Card brand icon
          Image.asset(
            paymentMethod.getBrandIconPath(),
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.credit_card, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          // Card details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paymentMethod.cardholderName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  paymentMethod.getMaskedCardNumber(),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.expires}: ${paymentMethod.getExpiryDisplay()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isExpired ? Colors.red : Colors.grey[600],
                      ),
                    ),
                    if (isExpired)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(AppLocalizations.of(context)!.expired.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Delete button
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.delete_outline, color: Colors.red[400], size: 20),
          ),
        ],
      ),
    );
  }

  void _deletePaymentMethod(int paymentMethodId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteCard),
        content: Text(
          AppLocalizations.of(context)!.areYouSureYouWantToRemoveThisCard,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref
                  .read(paymentMethodsProvider.notifier)
                  .removePaymentMethod(paymentMethodId);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.cardRemovedSuccessfully,
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddCardSheet() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddNewCardScreen()));
  }
}

/// Helper widget for displaying card brand logos
class _CardBrandLogo extends StatelessWidget {
  final String imagePath;
  final String label;

  const _CardBrandLogo(this.imagePath, this.label);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: 30,
      height: 20,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 30,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

/// Add New Card Screen with API Integration
class AddNewCardScreen extends ConsumerStatefulWidget {
  const AddNewCardScreen({super.key});

  @override
  ConsumerState<AddNewCardScreen> createState() => _AddNewCardScreenState();
}

class _AddNewCardScreenState extends ConsumerState<AddNewCardScreen> {
  late TextEditingController _cardNumberController;
  late TextEditingController _expiryController;
  late TextEditingController _cvvController;
  late TextEditingController _nameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController();
    _expiryController = TextEditingController();
    _cvvController = TextEditingController();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.addNewCard,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card number input
              _buildInput(
                controller: _cardNumberController,
                label: AppLocalizations.of(context)!.pleaseEnterBankCardNumber,
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Expiry and CVV row
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildInput(
                      controller: _expiryController,
                      label: 'MM/YY',
                      icon: null,
                      keyboardType: TextInputType.number,
                      hint: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: _buildInput(
                      controller: _cvvController,
                      label: 'CVV/CVC',
                      icon: null,
                      keyboardType: TextInputType.number,
                      hint: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Cardholder name
              _buildInput(
                controller: _nameController,
                label: AppLocalizations.of(context)!.pleaseEnterCardholderName,
                icon: null,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 32),
              // Security info
              _buildSecurityInfo(),
              const SizedBox(height: 32),
              // Add button
              SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDB714),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.black87,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)!.add,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required TextInputType keyboardType,
    IconData? icon,
    bool hint = false,
  }) {
    // Determine input formatters based on field type
    List<TextInputFormatter> inputFormatters = [];
    String fieldType = label.toLowerCase();

    if (fieldType.contains('card number')) {
      // Card number: only digits, formatted as XXXX XXXX XXXX XXXX
      inputFormatters = [
        FilteringTextInputFormatter.digitsOnly,
        CardNumberFormatter(),
      ];
    } else if (fieldType.contains('mm/yy') || fieldType.contains('expiry')) {
      // Expiry: MM/YY format
      inputFormatters = [
        FilteringTextInputFormatter.digitsOnly,
        ExpiryDateFormatter(),
      ];
    } else if (fieldType.contains('cvv') || fieldType.contains('cvc')) {
      // CVV: 3-4 digits only
      inputFormatters = [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ];
    } else if (fieldType.contains('cardholder') || fieldType.contains('name')) {
      // Cardholder name: letters and spaces only
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
      ];
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: !_isLoading,
        inputFormatters: inputFormatters,
        maxLength: fieldType.contains('card number') ? 19 : null,
        decoration: InputDecoration(
          hintText: hint ? label : null,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          label: !hint
              ? Text(
                  label,
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                )
              : null,
          border: InputBorder.none,
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: icon != null
              ? Container(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(icon, color: Colors.grey[500], size: 24),
                )
              : hint
              ? Container(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.grey[400],
                    size: 18,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: Colors.teal, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.sikaProtectsYourCardInformation,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.teal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSecurityBullet(
          AppLocalizations.of(context)!.sikaAdheresToPciDss,
        ),
        const SizedBox(height: 12),
        _buildSecurityBullet(
          AppLocalizations.of(context)!.cardInformationIsKeptSecure,
        ),
        const SizedBox(height: 12),
        _buildSecurityBullet(AppLocalizations.of(context)!.allDataIsEncrypted),
        const SizedBox(height: 12),
        _buildSecurityBullet(AppLocalizations.of(context)!.sikaWillNeverSellYourCardInformation),
        const SizedBox(height: 12),
        _buildSecurityBullet(
          AppLocalizations.of(context)!.ifAPreAuthorisationChargeOccursTheFundsWillBeRefundedImmediately,
        ),
      ],
    );
  }

  Widget _buildSecurityBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(Icons.check_circle, color: Colors.teal, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _addCard() async {
    // Validate inputs
    if (_cardNumberController.text.isEmpty ||
        _expiryController.text.isEmpty ||
        _cvvController.text.isEmpty ||
        _nameController.text.isEmpty) {
      _showErrorSnackbar(AppLocalizations.of(context)!.pleaseFillInAllFields);
      return;
    }

    // Validate card number (remove spaces for validation, 13-19 digits)
    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    if (!RegExp(r'^\d{13,19}$').hasMatch(cardNumber)) {
      _showErrorSnackbar(AppLocalizations.of(context)!.pleaseEnterAValidCardNumber);
      return;
    }

    // Validate expiry format (MM/YY)
    if (!RegExp(r'^(0[1-9]|1[0-2])/\d{2}$').hasMatch(_expiryController.text)) {
      _showErrorSnackbar(AppLocalizations.of(context)!.expiryDateMustBeInMMYYFormat);
      return;
    }

    // Validate CVV (3-4 digits)
    if (!RegExp(r'^\d{3,4}$').hasMatch(_cvvController.text)) {
      _showErrorSnackbar(AppLocalizations.of(context)!.cvvMustBe3To4Digits);
      return;
    }

    // Validate cardholder name (only letters and spaces, 2+ characters)
    if (!RegExp(r'^[a-zA-Z\s]{2,}$').hasMatch(_nameController.text)) {
      _showErrorSnackbar(
        AppLocalizations.of(context)!.cardholderNameMustContainOnlyLettersAndSpaces,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Call the API through Riverpod provider (send formatted values)
      await ref
          .read(paymentMethodsProvider.notifier)
          .addPaymentMethod(
            cardNumber: cardNumber, // Send without spaces
            expiryDate: _expiryController.text,
            cvv: _cvvController.text,
            cardholderName: _nameController.text.trim(),
          );

      _showSuccessSnackbar(AppLocalizations.of(context)!.cardAddedSuccessfully);

      // Pop back to payment methods screen
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showErrorSnackbar('${AppLocalizations.of(context)!.failedToAddCard}: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
