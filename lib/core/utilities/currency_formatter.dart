import 'package:intl/intl.dart';

/// Currency Formatter for Vietnamese Dong (đ)
class CurrencyFormatter {
  CurrencyFormatter._();

  static const int defaultDecimalDigits = 0;

  static String format(num data, {int? decimalDigits}) {
    // Format strictly as Vietnamese Dong: dot separator, space, followed by đ
    final numberFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: decimalDigits ?? defaultDecimalDigits,
    );
    // Replace non-breaking spaces with normal spaces to ensure clean rendering
    return numberFormat.format(data).replaceAll('\u00A0', ' ');
  }

  static String compact(num data, {int? decimalDigits, bool withSymbol = true}) {
    final suffix = withSymbol ? 'đ' : '';
    if (data >= 1000000) {
      final value = data / 1000000;
      return '${value.toStringAsFixed(1)}M$suffix';
    } else if (data >= 1000) {
      final value = data / 1000;
      return '${value.toStringAsFixed(0)}K$suffix';
    } else {
      return '${format(data, decimalDigits: decimalDigits).replaceAll(' đ', '')}$suffix';
    }
  }

  static String withoutSymbol(num data, {int? decimalDigits}) {
    final numberFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: decimalDigits ?? defaultDecimalDigits,
    );
    return numberFormat.format(data).trim();
  }

  static String currencySymbol() {
    return 'đ';
  }
}

