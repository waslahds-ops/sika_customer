class PaymentMethod {
  final int paymentMethodId;
  final int userId;
  final String cardBrand; // visa, mastercard, amex, etc.
  final String lastFourDigits;
  final String cardholderName;
  final String expiryMonth;
  final String expiryYear;
  final bool isDefault;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PaymentMethod({
    required this.paymentMethodId,
    required this.userId,
    required this.cardBrand,
    required this.lastFourDigits,
    required this.cardholderName,
    required this.expiryMonth,
    required this.expiryYear,
    required this.isDefault,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      paymentMethodId: json['payment_method_id'] ?? json['id'] as int,
      userId: json['user_id'] as int,
      cardBrand: json['card_brand'] ?? json['brand'] as String,
      lastFourDigits: json['last_four_digits'] ?? json['last_four'] as String,
      cardholderName: json['cardholder_name'] ?? json['holder_name'] as String,
      expiryMonth: json['expiry_month'] ?? json['exp_month'] as String,
      expiryYear: json['expiry_year'] ?? json['exp_year'] as String,
      isDefault: json['is_default'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_method_id': paymentMethodId,
      'user_id': userId,
      'card_brand': cardBrand,
      'last_four_digits': lastFourDigits,
      'cardholder_name': cardholderName,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'is_default': isDefault,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Get masked card number (e.g., "•••• •••• •••• 4242")
  String getMaskedCardNumber() => '•••• •••• •••• $lastFourDigits';

  /// Get expiry display (e.g., "12/25")
  String getExpiryDisplay() => '$expiryMonth/$expiryYear';

  /// Check if card is expired
  bool isExpired() {
    final now = DateTime.now();
    final cardExpiry = DateTime(
      int.parse('20$expiryYear'),
      int.parse(expiryMonth),
    );
    return now.isAfter(cardExpiry);
  }

  /// Get card brand icon asset path
  String getBrandIconPath() {
    switch (cardBrand.toLowerCase()) {
      case 'visa':
        return 'assets/images/visa.png';
      case 'mastercard':
      case 'master card':
        return 'assets/images/mastercard.png';
      case 'amex':
      case 'american express':
        return 'assets/images/amex.png';
      case 'visa_electron':
      case 'visa electron':
        return 'assets/images/visa_electron.png';
      default:
        return 'assets/images/credit_card.png';
    }
  }
}
