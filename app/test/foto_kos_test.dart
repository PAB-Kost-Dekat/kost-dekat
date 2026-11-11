import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('setiap foto kos terdaftar di aset dan id-nya ada di server', () async {
    final idServer = (jsonDecode(
      File('../server/data/kos.json').readAsStringSync(),
    ) as List)
        .map((k) => (k as Map<String, dynamic>)['id'] as String)
        .toSet();

    final foto = Directory('assets/images')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .toList();
    expect(foto, isNotEmpty);

    for (final nama in foto) {
      // Halaman detail memuat 'assets/images/kos_<id>.jpeg'.
      final cocok = RegExp(r'^kos_(.+)\.jpeg$').firstMatch(nama);
      expect(cocok, isNotNull, reason: '$nama harus bernama kos_<id>.jpeg');
      expect(idServer, contains(cocok!.group(1)),
          reason: '$nama: id tidak ada');

      final data = await rootBundle.load('assets/images/$nama');
      expect(data.lengthInBytes, greaterThan(0), reason: nama);
    }
  });
}
