import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountryService extends ChangeNotifier {
  static final CountryService _instance = CountryService._internal();
  factory CountryService() => _instance;
  CountryService._internal();

  static const String _countryKey = 'selected_country';
  static const String _currencyKey = 'selected_currency';

  String _selectedCountry = 'India';
  String _selectedCurrency = '₹';
  String _currencyCode = 'INR';

  String get selectedCountry => _selectedCountry;
  String get selectedCurrency => _selectedCurrency;
  String get currencyCode => _currencyCode;

  static const Map<String, Map<String, String>> supportedCountries = {
    'India': {
      'currency_symbol': '₹',
      'currency_code': 'INR',
      'tax_name': 'GST',
    },
    'United States': {
      'currency_symbol': '\$',
      'currency_code': 'USD',
      'tax_name': 'Sales Tax',
    },
    'United Kingdom': {
      'currency_symbol': '£',
      'currency_code': 'GBP',
      'tax_name': 'VAT',
    },
    'Canada': {
      'currency_symbol': 'C\$',
      'currency_code': 'CAD',
      'tax_name': 'HST/GST',
    },
    'Australia': {
      'currency_symbol': 'A\$',
      'currency_code': 'AUD',
      'tax_name': 'GST',
    },
    'European Union': {
      'currency_symbol': '€',
      'currency_code': 'EUR',
      'tax_name': 'VAT',
    },
  };

  String get taxName =>
      supportedCountries[_selectedCountry]?['tax_name'] ?? 'Tax';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCountry = prefs.getString(_countryKey) ?? 'India';
    _selectedCurrency =
        supportedCountries[_selectedCountry]?['currency_symbol'] ?? '₹';
    _currencyCode =
        supportedCountries[_selectedCountry]?['currency_code'] ?? 'INR';
    notifyListeners();
  }

  Future<void> setCountry(String country) async {
    if (supportedCountries.containsKey(country)) {
      _selectedCountry = country;
      _selectedCurrency = supportedCountries[country]!['currency_symbol']!;
      _currencyCode = supportedCountries[country]!['currency_code']!;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_countryKey, country);
      await prefs.setString(_currencyKey, _selectedCurrency);

      notifyListeners();
    }
  }

  String formatCurrency(double amount) {
    return '$_selectedCurrency${amount.toStringAsFixed(2)}';
  }

  String formatCurrencyCompact(double amount) {
    if (amount >= 1000000) {
      return '$_selectedCurrency${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$_selectedCurrency${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$_selectedCurrency${amount.toStringAsFixed(0)}';
  }
}
