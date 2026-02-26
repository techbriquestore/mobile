import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String priceFCFA(num amount) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return '${formatter.format(amount)} FCFA';
  }

  static String phoneNumber(String phone) {
    if (phone.length != 10) return phone;
    return '${phone.substring(0, 2)} ${phone.substring(2, 4)} ${phone.substring(4, 6)} ${phone.substring(6, 8)} ${phone.substring(8, 10)}';
  }

  static String date(DateTime dt) => DateFormat('d MMMM yyyy', 'fr_FR').format(dt);
  static String dateShort(DateTime dt) => DateFormat('dd/MM/yyyy').format(dt);
  static String dateTime(DateTime dt) => DateFormat("d MMMM yyyy 'Ã ' HH'h'mm", 'fr_FR').format(dt);

  static String percentage(double value) => '${(value * 100).toStringAsFixed(0)}%';
  static String quantity(int qty) => NumberFormat('#,###', 'fr_FR').format(qty);
}
