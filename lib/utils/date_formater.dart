import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime date) {
    // Format lokal Indonesia
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  static String formatMonth(DateTime date) {
    return DateFormat('MMMM', 'id_ID').format(date);
  }
}
