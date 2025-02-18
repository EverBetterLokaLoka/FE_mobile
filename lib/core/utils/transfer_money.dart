import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat("#,###", "vi_VN");

  static String format(String value) {
    String text = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.isEmpty) return "0 VND";
    return "${_formatter.format(int.parse(text))} VND";
  }
}