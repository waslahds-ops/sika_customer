/// Country and Currency Configuration for the Application
/// Supports multiple countries and their associated currencies

enum Country { lebanon }

enum Currency { lbp, usd }

class CountryCurrencyConfig {
  // Country to Currency Mapping
  static const Map<Country, Currency> countryToCurrency = {
    Country.lebanon: Currency.lbp,
  };

  // Currency Details
  static const Map<Currency, CurrencyInfo> currencyInfo = {
    Currency.lbp: CurrencyInfo(
      code: 'LBP',
      symbol: 'ل.ل',
      name: 'Lebanese Pound',
      decimalPlaces: 0, // LBP typically doesn't use decimal places
    ),
    Currency.usd: CurrencyInfo(
      code: 'USD',
      symbol: '\$',
      name: 'US Dollar',
      decimalPlaces: 2,
    ),
  };

  // Country Details
  static const Map<Country, CountryInfo> countryInfo = {
    Country.lebanon: CountryInfo(
      code: 'LB',
      name: 'Lebanon',
      countryCode: '+961',
      language: 'ar', // Arabic
    ),
  };

  // Payment Methods by Country
  static const Map<Country, List<PaymentMethod>> paymentMethodsByCountry = {
    Country.lebanon: [
      PaymentMethod.creditCard,
      PaymentMethod.debitCard,
      PaymentMethod.mobileWallet,
      PaymentMethod.bankTransfer,
    ],
  };

  // Get currency symbol for formatting
  static String getCurrencySymbol(Currency currency) {
    return currencyInfo[currency]?.symbol ?? '';
  }

  // Format price with currency
  static String formatPrice(double price, Currency currency) {
    final info = currencyInfo[currency];
    if (info == null) return price.toString();

    final formatted = price.toStringAsFixed(info.decimalPlaces);
    return '$formatted ${info.code}';
  }

  // Format price with symbol
  static String formatPriceWithSymbol(double price, Currency currency) {
    final info = currencyInfo[currency];
    if (info == null) return price.toString();

    final formatted = price.toStringAsFixed(info.decimalPlaces);
    return '${info.symbol} $formatted';
  }

  // Get country name
  static String getCountryName(Country country) {
    return countryInfo[country]?.name ?? '';
  }

  // Get currency code
  static String getCurrencyCode(Currency currency) {
    return currencyInfo[currency]?.code ?? '';
  }

  // Default currency for app (Lebanon)
  static const Currency defaultCurrency = Currency.lbp;
  static const Country defaultCountry = Country.lebanon;
}

class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  final int decimalPlaces;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    required this.decimalPlaces,
  });
}

class CountryInfo {
  final String code;
  final String name;
  final String countryCode;
  final String language;

  const CountryInfo({
    required this.code,
    required this.name,
    required this.countryCode,
    required this.language,
  });
}

enum PaymentMethod { creditCard, debitCard, mobileWallet, bankTransfer }

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.mobileWallet:
        return 'Mobile Wallet';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
    }
  }
}
