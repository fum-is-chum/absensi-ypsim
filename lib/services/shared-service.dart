import 'package:intl/intl.dart';

String formatDateOnly(dynamic date) {
  return DateFormat('yyyy-MM-dd').format(date is String ? DateTime.parse(date): date);
}