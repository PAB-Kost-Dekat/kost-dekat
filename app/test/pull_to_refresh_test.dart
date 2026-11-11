import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kosdekat/halaman/halaman_utama.dart';
import 'package:kosdekat/service/kos_service.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final dataJson = jsonEncode([
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
  ]);

  /// Balasan server per panggilan; panggilan setelah daftar habis memakai yang terakhir.
  ({KosService service, List<int> hit}) buatService(List<int> kodeStatus) {
    final hit = <int>[];
    final service = KosService(
      client: MockClient((request) async {
        final kode = kodeStatus[hit.length.clamp(0, kodeStatus.length - 1)];
        hit.add(kode);
        return http.Response(kode == 200 ? dataJson : 'error', kode);
      }),
      baseUrl: 'http://localhost:8080',
    );
    return (service: service, hit: hit);
  }

  Future<void> tarik(WidgetTester tester) async {
    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('tarik daftar ke bawah memuat ulang data dari server', (
    tester,
  ) async {
    final s = buatService([200]);
    await tester.pumpWidget(
      MaterialApp(home: HalamanUtama(kosService: s.service)),
    );
    await tester.pumpAndSettle();
    expect(s.hit.length, 1);
    expect(find.byType(RefreshIndicator), findsOneWidget);

    await tarik(tester);

    expect(s.hit.length, 2);
    expect(find.text('Kos Melati Indah'), findsOneWidget);
  });

  testWidgets('keadaan gagal bisa ditarik, lalu data tampil', (tester) async {
    final s = buatService([500, 200]);
    await tester.pumpWidget(
      MaterialApp(home: HalamanUtama(kosService: s.service)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Gagal memuat data kos.'), findsOneWidget);

    await tarik(tester);

    expect(s.hit, [500, 200]);
    expect(find.text('Gagal memuat data kos.'), findsNothing);
    expect(find.text('Kos Melati Indah'), findsOneWidget);
  });
}
