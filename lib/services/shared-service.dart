import 'package:intl/intl.dart';
String formatDateOnly(dynamic date, {String format = 'yyyy-MM-dd'}) {
  return DateFormat(format, "id_ID").format(date is String ? DateTime.parse(date): date);
}