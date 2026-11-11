import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kosdekat/halaman/halaman_detail_kos.dart';
import 'package:kosdekat/halaman/halaman_utama.dart';
import 'package:kosdekat/service/kos_service.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final service = KosService(
    client: MockClient(
      (request) async => http.Response(
        jsonEncode([
          {
            'id': 'kos-1',
            'nama': 'Kos Melati Indah',
            'area': 'Sukapura',
            'tipe': 'Putri',
            'hargaBulanan': 1250000,
            'kamarMandiDalam': true,
            'jarakKm': 0.5,
            'diperbarui': '2026-10-28T09:00:00.000',
          },
        ]),
        200,
      ),
    ),
    baseUrl: 'http://localhost:8080',
  );

  // SnackBar dan FloatingActionButton punya Hero bawaan; ambil hanya Hero gambar
  // (tag String) yang tampil. Kartu di bawah halaman detail berada di luar layar.
  List<Object> tagHeroTampil(WidgetTester tester) => tester
      .widgetList<Hero>(find.byType(Hero))
      .map((h) => h.tag)
      .whereType<String>()
      .where((t) => t.endsWith('-kos-1'))
      .toList();

  /// Pump beberapa frame selama animasi agar overflow saat terbang ikut tertangkap.
  Future<void> jalankanAnimasi(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 60));
    }
    await tester.pumpAndSettle();
  }

  testWidgets(
    'buka detail dari tab Cari lalu dari tab Favorit tanpa error tag ganda',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: HalamanUtama(kosService: service)),
      );
      await tester.pumpAndSettle();

      // Favoritkan kos, sehingga kartunya hidup di tab Cari dan tab Favorit.
      await tester.tap(find.byTooltip('Tambah favorit'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Dari tab Cari: tag detail sama dengan kartu Cari.
      await tester.tap(find.text('Kos Melati Indah'));
      await jalankanAnimasi(tester);
      expect(tester.takeException(), isNull);
      expect(find.byType(HalamanDetailKos), findsOneWidget);
      expect(tagHeroTampil(tester), ['cari-kos-1']);

      await tester.pageBack();
      await jalankanAnimasi(tester);
      expect(tester.takeException(), isNull);

      // Dari tab Favorit: tag berbeda, tidak bentrok dengan kartu Cari.
      await tester.tap(find.text('Favorit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kos Melati Indah'));
      await jalankanAnimasi(tester);
      expect(tester.takeException(), isNull);
      expect(find.byType(HalamanDetailKos), findsOneWidget);
      expect(tagHeroTampil(tester), ['favorit-kos-1']);

      await tester.pageBack();
      await jalankanAnimasi(tester);
      expect(tester.takeException(), isNull);
    },
  );
}
