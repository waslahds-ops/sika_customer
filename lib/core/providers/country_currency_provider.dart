import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/country_currency_config.dart';

class CountryCurrencyState {
  final Country country;
  final Currency currency;

  CountryCurrencyState({required this.country, required this.currency});

  CountryCurrencyState copyWith({Country? country, Currency? currency}) {
    return CountryCurrencyState(
      country: country ?? this.country,
      currency: currency ?? this.currency,
    );
  }
}

class CountryCurrencyNotifier extends StateNotifier<CountryCurrencyState> {
  late Box _settingsBox;

  CountryCurrencyNotifier()
    : super(
        CountryCurrencyState(
          country: CountryCurrencyConfig.defaultCountry,
          currency: CountryCurrencyConfig.defaultCurrency,
        ),
      ) {
    _initializeBox();
  }

  Future<void> _initializeBox() async {
    try {
      _settingsBox = Hive.box('settingsBox');
      _loadSavedCountryCurrency();
    } catch (e) {
      debugPrint('❌ Error initializing settings box: $e');
    }
  }

  void _loadSavedCountryCurrency() {
    try {
      final savedCountry = _settingsBox.get('country') as String?;
      final savedCurrency = _settingsBox.get('currency') as String?;

      Country country = CountryCurrencyConfig.defaultCountry;
      Currency currency = CountryCurrencyConfig.defaultCurrency;

      if (savedCountry != null) {
        country = Country.values.firstWhere(
          (e) => e.toString() == savedCountry,
          orElse: () => CountryCurrencyConfig.defaultCountry,
        );
      }

      if (savedCurrency != null) {
        currency = Currency.values.firstWhere(
          (e) => e.toString() == savedCurrency,
          orElse: () => CountryCurrencyConfig.defaultCurrency,
        );
      }

      state = CountryCurrencyState(country: country, currency: currency);
    } catch (e) {
      debugPrint('❌ Error loading country/currency: $e');
    }
  }

  Future<void> setCountry(Country country) async {
    try {
      // Get the default currency for this country
      final currency =
          CountryCurrencyConfig.countryToCurrency[country] ??
          CountryCurrencyConfig.defaultCurrency;

      state = CountryCurrencyState(country: country, currency: currency);

      // Save to Hive
      await _settingsBox.put('country', country.toString());
      await _settingsBox.put('currency', currency.toString());
    } catch (e) {
      debugPrint('❌ Error setting country: $e');
    }
  }

  Future<void> setCurrency(Currency currency) async {
    try {
      state = state.copyWith(currency: currency);

      // Save to Hive
      await _settingsBox.put('currency', currency.toString());
    } catch (e) {
      debugPrint('❌ Error setting currency: $e');
    }
  }

  String getCurrencySymbol() {
    return CountryCurrencyConfig.getCurrencySymbol(state.currency);
  }

  String formatPrice(double price) {
    return CountryCurrencyConfig.formatPrice(price, state.currency);
  }

  String formatPriceWithSymbol(double price) {
    return CountryCurrencyConfig.formatPriceWithSymbol(price, state.currency);
  }

  // Conversion helpers: assume stored prices are in USD when converting.
  static const double _usdToLbpRate = 90000.0;

  double convertUsdToSelected(double priceUsd) {
    if (state.currency == Currency.lbp) return priceUsd * _usdToLbpRate;
    return priceUsd; // USD selected
  }

  double convertSelectedToUsd(double priceInSelected) {
    if (state.currency == Currency.lbp) return priceInSelected / _usdToLbpRate;
    return priceInSelected; // USD selected
  }

  String formatConvertedPriceFromUsd(double priceUsd) {
    final converted = convertUsdToSelected(priceUsd);
    return formatPrice(converted);
  }

  String formatConvertedPriceWithSymbolFromUsd(double priceUsd) {
    final converted = convertUsdToSelected(priceUsd);
    return formatPriceWithSymbol(converted);
  }

  String getCountryName() {
    return CountryCurrencyConfig.getCountryName(state.country);
  }

  List<PaymentMethod> getAvailablePaymentMethods() {
    return CountryCurrencyConfig.paymentMethodsByCountry[state.country] ?? [];
  }
}

// Riverpod Provider
final countryCurrencyProvider =
    StateNotifierProvider<CountryCurrencyNotifier, CountryCurrencyState>((ref) {
      return CountryCurrencyNotifier();
    });
