import 'package:intl/intl.dart';

class CurrencyHelper {
  static String format(dynamic amount) {
    final number = double.tryParse(amount.toString()) ?? 0;
    return 'Rp ${NumberFormat('#,###', 'id_ID').format(number)}';
  }
}
