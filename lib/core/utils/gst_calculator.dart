import 'package:decimal/decimal.dart';

/// GST calculation utilities for Indian tax system
class GstCalculator {
  /// Calculate GST amount from taxable value and rate
  static Decimal calculateGstAmount(Decimal taxableValue, Decimal gstRate) {
    return Decimal.parse(
      ((taxableValue * gstRate) / Decimal.fromInt(100)).toString(),
    );
  }

  /// Calculate total amount including GST
  static Decimal calculateTotalWithGst(Decimal taxableValue, Decimal gstRate) {
    final gstAmount = calculateGstAmount(taxableValue, gstRate);
    return taxableValue + gstAmount;
  }

  /// Calculate taxable value from total amount (reverse calculation)
  static Decimal calculateTaxableFromTotal(
    Decimal totalAmount,
    Decimal gstRate,
  ) {
    final gstFactor = Decimal.parse(
      (gstRate / Decimal.fromInt(100)).toString(),
    );
    final divisor = Decimal.fromInt(1) + gstFactor;
    return Decimal.parse((totalAmount / divisor).toString());
  }

  /// Split GST into CGST and SGST for intra-state transactions
  static Map<String, Decimal> splitIntraStateGst(Decimal gstAmount) {
    final halfAmount = Decimal.parse(
      (gstAmount / Decimal.fromInt(2)).toString(),
    );
    return {'cgst': halfAmount, 'sgst': halfAmount};
  }

  /// Get IGST for inter-state transactions
  static Map<String, Decimal> getInterStateGst(Decimal gstAmount) {
    return {'igst': gstAmount};
  }

  /// Determine if transaction is inter-state based on state codes
  static bool isInterState(
    String? businessStateCode,
    String? customerStateCode,
  ) {
    if (businessStateCode == null || customerStateCode == null) {
      return false;
    }
    return businessStateCode != customerStateCode;
  }

  /// Calculate line total for invoice item
  static Map<String, Decimal> calculateLineTotal({
    required Decimal quantity,
    required Decimal unitPrice,
    required Decimal gstRate,
    Decimal? discountPercent,
  }) {
    final discount = discountPercent ?? Decimal.zero;

    // Calculate gross amount
    final grossAmount = quantity * unitPrice;

    // Apply discount
    final discountAmount = Decimal.parse(
      ((grossAmount * discount) / Decimal.fromInt(100)).toString(),
    );
    final taxableAmount = Decimal.parse(
      (grossAmount - discountAmount).toString(),
    );

    // Calculate GST
    final gstAmount = calculateGstAmount(taxableAmount, gstRate);
    final totalAmount = taxableAmount + gstAmount;

    return {
      'gross_amount': grossAmount,
      'discount_amount': discountAmount,
      'taxable_amount': taxableAmount,
      'gst_amount': gstAmount,
      'total_amount': totalAmount,
    };
  }

  /// Round amount to 2 decimal places
  static Decimal roundAmount(Decimal amount) {
    return Decimal.parse(amount.toStringAsFixed(2));
  }

  /// Common GST rates in India
  static const Map<String, double> commonGstRates = {
    'Nil': 0.0,
    'Exempted': 0.0,
    '5%': 5.0,
    '12%': 12.0,
    '18%': 18.0,
    '28%': 28.0,
  };
}

/// Indian state codes for GST
class IndianStateCodes {
  static const Map<String, String> stateCodes = {
    '01': 'Jammu and Kashmir',
    '02': 'Himachal Pradesh',
    '03': 'Punjab',
    '04': 'Chandigarh',
    '05': 'Uttarakhand',
    '06': 'Haryana',
    '07': 'Delhi',
    '08': 'Rajasthan',
    '09': 'Uttar Pradesh',
    '10': 'Bihar',
    '11': 'Sikkim',
    '12': 'Arunachal Pradesh',
    '13': 'Nagaland',
    '14': 'Manipur',
    '15': 'Mizoram',
    '16': 'Tripura',
    '17': 'Meghalaya',
    '18': 'Assam',
    '19': 'West Bengal',
    '20': 'Jharkhand',
    '21': 'Odisha',
    '22': 'Chhattisgarh',
    '23': 'Madhya Pradesh',
    '24': 'Gujarat',
    '25': 'Daman and Diu',
    '26': 'Dadra and Nagar Haveli',
    '27': 'Maharashtra',
    '29': 'Karnataka',
    '30': 'Goa',
    '31': 'Lakshadweep',
    '32': 'Kerala',
    '33': 'Tamil Nadu',
    '34': 'Puducherry',
    '35': 'Andaman and Nicobar Islands',
    '36': 'Telangana',
    '37': 'Andhra Pradesh',
    '38': 'Ladakh',
  };

  static String? getStateName(String code) {
    return stateCodes[code];
  }

  static List<MapEntry<String, String>> getAllStates() {
    return stateCodes.entries.toList();
  }
}
