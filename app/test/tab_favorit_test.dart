import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kosdekat/halaman/halaman_utama.dart';
import 'package:kosdekat/halaman/tab_favorit.dart';
import 'package:kosdekat/model/kos.dart';
import 'package:kosdekat/service/kos_service.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  const teksKosong = 'Belum ada kos favorit yang ditandai.';

  final dataJson = [
    {
      'id': '1',
      'nama': 'Kos Melati Indah',
      'area': 'Sukapura',
      'tipe': 'Putri',
      'hargaBulanan': 1200000,
      'kamarMandiDalam': true,
      'jarakKm': 0.8,
      'diperbarui': '2026-11-10T12:00:00.000',
    },
    {
      'id': '2',
      'nama': 'Pondok Asri',
      'area': 'Dayeuhkolot',
      'tipe': 'Putra',
      'hargaBulanan': 900000,
      'kamarMandiDalam': false,
      'jarakKm': 1.2,
      'diperbarui': '2026-11-10T12:00:00.000',
    },
  ];
  final daftarKos = dataJson.map(Kos.fromJson).toList();

  group('TabFavorit', () {
    testWidgets('menampilkan keadaan kosong bila belum ada favorit', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabFavorit(
              futureKos: Future.value(daftarKos),
              idFavorit: const {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(teksKosong), findsOneWidget);
      expect(find.text('Kos Melati Indah'), findsNothing);
    });

    testWidgets('hanya menampilkan kos yang ada di idFavorit', (tester) async {
      String? idDiketuk;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TabFavorit(
              futureKos: Future.value(daftarKos),
              idFavorit: const {'1'},
              onToggleFavorit: (id) => idDiketuk = id,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kos Melati Indah'), findsOneWidget);
      expect(find.text('Pondok Asri'), findsNothing);

      await tester.tap(find.byTooltip('Hapus favorit'));
      await tester.pump();
      expect(idDiketuk, '1');
    });
  });

  testWidgets(
    'favorit dari tab Cari muncul di tab Favorit dengan SnackBar, tanpa ambil ulang data',
    (tester) async {
      var jumlahPanggilan = 0;
      final service = KosService(
        client: MockClient((request) async {
          jumlahPanggilan++;
          return http.Response(jsonEncode(dataJson), 200);
        }),
        baseUrl: 'http://test:8080',
      );

      await tester.pumpWidget(
        MaterialApp(home: HalamanUtama(kosService: service)),
      );
      await tester.pumpAndSettle();
      expect(jumlahPanggilan, 1);

      await tester.tap(find.text('Favorit'));
      await tester.pumpAndSettle();
      expect(find.text(teksKosong), findsOneWidget);

      await tester.tap(find.text('Cari'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Tambah favorit').first);
      await tester.pump();
      expect(find.text('Ditambahkan ke Favorit'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text('Favorit'));
      await tester.pumpAndSettle();
      // Urutan default jarak terdekat: Kos Melati Indah (0,8 km) di atas.
      expect(find.text('Kos Melati Indah'), findsOneWidget);
      expect(find.text(teksKosong), findsNothing);

      await tester.tap(
        find.descendant(
          of: find.byType(TabFavorit),
          matching: find.byTooltip('Hapus favorit'),
        ),
      );
      await tester.pump();
      expect(find.text('Dihapus dari Favorit'), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text(teksKosong), findsOneWidget);
      expect(jumlahPanggilan, 1);
    },
  );
}
