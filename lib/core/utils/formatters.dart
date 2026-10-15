class Formatters {
  Formatters._();

  /// 32 -> "32 DT", 25.5 -> "25.500 DT"
  static String dt(double value) {
    final whole = value == value.roundToDouble();
    return '${whole ? value.toStringAsFixed(0) : value.toStringAsFixed(3)} DT';
  }

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// "12:14"
  static String time(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

  /// "12/03/2025"
  static String date(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

  /// "12:14 - 28/04/2025"
  static String dateTime(DateTime d) => '${time(d)} - ${date(d)}';

  /// Retire espaces, tirets et le préfixe +216 : "+216 98 123 456" -> "98123456".
  static String normalizePhone(String phone) {
    var p = phone.replaceAll(RegExp(r'[\s\-]'), '');
    if (p.startsWith('+216')) p = p.substring(4);
    return p;
  }
}