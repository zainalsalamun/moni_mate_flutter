import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormat {
  static String format(num amount) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatCurrency.format(amount);
  }
}

/// TextInputFormatter for currency input with thousand separators
class CurrencyInputFormatter extends TextInputFormatter {
  final String prefix;

  CurrencyInputFormatter({this.prefix = ''});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters
    String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // Remove leading zeros
    digits = digits.replaceFirst(RegExp(r'^0+'), '');
    if (digits.isEmpty) {
      digits = '0';
    }

    // Format with thousand separators (dot as separator in Indonesian)
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();

    // Calculate new selection position
    final selectionIndex = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

/// Parse formatted currency string back to double
double parseCurrency(String formatted) {
  return double.tryParse(formatted.replaceAll('.', '').replaceAll(',', '')) ??
      0.0;
}
