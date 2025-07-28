import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

class CurrencyHelper {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'hi_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Formats a Decimal amount as currency string
  static String formatCurrency(Decimal amount) {
    return _currencyFormat.format(amount.toDouble());
  }

  /// Formats a double amount as currency string
  static String formatCurrencyFromDouble(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Parses a currency string back to Decimal
  static Decimal? parseCurrency(String currencyString) {
    try {
      // Remove currency symbol and whitespace
      final cleanString =
          currencyString.replaceAll('₹', '').replaceAll(',', '').trim();
      return Decimal.parse(cleanString);
    } catch (e) {
      return null;
    }
  }

  /// Gets the currency symbol
  static String get currencySymbol => '₹';

  /// Formats amount with thousands separator but no currency symbol
  static String formatAmount(Decimal amount) {
    final formatter = NumberFormat('#,##,###.##', 'hi_IN');
    return formatter.format(amount.toDouble());
  }
}
