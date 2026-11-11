class CurrencyUtils {
  static String formatRupiah(num number, {bool includePeriod = true}) {
    String digits = number.abs().toString();
    String result = '';
    int count = 0;

    for (int i = digits.length - 1; i >= 0; i--) {
      count++;
      result = digits[i] + result;
      if (count == 3 && i > 0) {
        result = '.$result';
        count = 0;
      }
    }

    String formatted = 'Rp$result';
    if (includePeriod) {
      formatted += '/bln';
    }
    return formatted;
  }
}

String formatRupiah(num number, {bool includePeriod = true}) =>
    CurrencyUtils.formatRupiah(number, includePeriod: includePeriod);
