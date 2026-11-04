/// 6.5 -> "6.500 DT"
String money(double value) => '${value.toStringAsFixed(3)} DT';

/// 0.5 -> "+ 0.500 DT"
String plusMoney(double value) => '+ ${value.toStringAsFixed(3)} DT';

/// 13 -> "13", 7.5 -> "7.5"
String percent(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();