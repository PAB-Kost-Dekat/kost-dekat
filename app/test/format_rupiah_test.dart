import 'package:flutter_test/flutter_test.dart';
import 'package:kosdekat/utils/format_rupiah.dart';

void main() {
  group('CurrencyUtils.formatRupiah', () {
    test('memformat angka ribet menjadi format standar dengan /bln', () {
      expect(CurrencyUtils.formatRupiah(1250000), 'Rp1.250.000/bln');
    });

    test('memformat angka tanpa tambahan /bln jika parameter false', () {
      expect(
        CurrencyUtils.formatRupiah(500000, includePeriod: false),
        'Rp500.000',
      );
    });

    test('memformat angka kecil dengan benar', () {
      expect(CurrencyUtils.formatRupiah(50000), 'Rp50.000/bln');
    });
  });
}
