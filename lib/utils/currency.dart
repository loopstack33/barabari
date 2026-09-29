import 'package:intl/intl.dart';

final _pkrFormat = NumberFormat.currency(
  locale: 'en_PK',
  symbol: 'PKR ',
  decimalDigits: 0,
);

String formatPkr(double value) => _pkrFormat.format(value);
