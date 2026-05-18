import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Currency { lbp, usd }

extension CurrencyExtension on Currency {
  String get symbol {
    switch (this) {
      case Currency.lbp:
        return 'LBP';
      case Currency.usd:
        return 'USD';
    }
  }

  String get displayName {
    switch (this) {
      case Currency.lbp:
        return 'ل.ل';
      case Currency.usd:
        return '\$';
    }
  }
}

class CurrencyNotifier extends StateNotifier<Currency> {
  CurrencyNotifier() : super(Currency.lbp);

  void toggleCurrency() {
    state = state == Currency.lbp ? Currency.usd : Currency.lbp;
    print('💱 [CURRENCY] Toggled to: ${state.symbol}');
  }

  void setCurrency(Currency currency) {
    state = currency;
    print('💱 [CURRENCY] Set to: ${currency.symbol}');
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, Currency>((ref) {
  return CurrencyNotifier();
});

/// Helper function to format price with selected currency
String formatPrice(double price, Currency currency) {
  switch (currency) {
    case Currency.lbp:
      final formatted = '${price.toStringAsFixed(0)} ${currency.symbol}';
      print('💱 [FORMAT] LBP: $price → $formatted');
      return formatted;
    case Currency.usd:
      // Simple conversion: divide LBP by ~88000 to get approximate USD
      final usdPrice = price / 88000;
      final formatted = '${currency.displayName}${usdPrice.toStringAsFixed(2)}';
      print('💱 [FORMAT] USD: $price LBP → $formatted');
      return formatted;
  }
}
