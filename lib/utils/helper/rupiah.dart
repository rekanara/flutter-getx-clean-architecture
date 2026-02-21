import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RupiahHelper {
  String formatCurrencyStringToRupiah(String amount) {
    try {
      double parsedAmount = double.tryParse(amount) ?? 0.0;
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp',
        decimalDigits: 0,
      );
      return formatter.format(parsedAmount);
    } catch (e) {
      debugPrint('Error formatting currency: $e');
      return amount;
    }
  }

  String formatCurrencyToRupiah(double amount) {
    try {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp',
        decimalDigits: 0,
      );
      return formatter.format(amount);
    } catch (e) {
      debugPrint('Error formatting currency: $e');
      return amount.toString();
    }
  }
}
