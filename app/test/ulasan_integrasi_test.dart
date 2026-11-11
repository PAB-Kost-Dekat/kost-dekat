import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kosdekat/halaman/halaman_utama.dart';
import 'package:kosdekat/halaman/tab_profil.dart';
import 'package:kosdekat/service/kos_service.dart';
import 'package:kosdekat/widget/kartu_kos.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final tabAsal in ['Cari', 'Favorit']) {
    testWidgets(
      'ulasan dari $tabAsal muncul di Profil dan detail kedua tab KosDekat',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(1000, 1800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final client = MockClient((request) async {
          expect(request.url.path, '/kos');
          return http.Response(
            jsonEncode([
              {
                'id': 'kos-1',
                'nama': 'Kos Melati Sukapura',
                'area': 'Sukapura',
                'tipe': 'Putri',
                'hargaBulanan': 1250000,
                'kamarMandiDalam': true,
                'jarakKm': 0.8,
                'diperbarui': '2026-11-10T12:00:00Z',
              },
              {
                'id': 'kos-2',
                'nama': 'Kos Mawar Sukapura',
                'area': 'Sukapura',
                'tipe': 'Putra',
                'hargaBulanan': 1000000,
                'kamarMandiDalam': false,
                'jarakKm': 1.2,
                'diperbarui': '2026-11-10T12:00:00Z',
              },
            ]),
            200,
          );
        });
        addTearDown(client.close);
        await tester.pumpWidget(
          MaterialApp(
            home: HalamanUtama(kosService: KosService(client: client)),
          ),
        );
        await tester.pumpAndSettle();

        final kartuMelati =
            find.widgetWithText(KartuKos, 'Kos Melati Sukapura');
        await tester.tap(
          find.descendant(
            of: kartuMelati,
            matching: find.byTooltip('Tambah favorit'),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(tabAsal).last);
        await tester.pumpAndSettle();
        await tester.tap(kartuMelati);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Tulis Ulasan'));
        await tester.tap(find.text('Tulis Ulasan'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Rating 4 bintang'));
        const komentar = 'Kos nyaman dan dekat kampus Telkom.';
        await tester.enterText(find.byType(TextFormField).last, komentar);
        await tester.tap(find.text('Kirim Ulasan'));
        await tester.pumpAndSettle();
        expect(find.text(komentar), findsOneWidget);
        expect(find.text('Ulasan (1)'), findsOneWidget);

        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Profil').last);
        await tester.pumpAndSettle();
        expect(find.text('Ulasan Saya (1)'), findsOneWidget);
        expect(find.text(komentar), findsOneWidget);
        final ulasanProfil = tester
            .widget<TabProfil>(find.byType(TabProfil))
            .daftarUlasan
            .single;
        expect(ulasanProfil.kosId, 'kos-1');
        expect(ulasanProfil.namaKos, 'Kos Melati Sukapura');
        expect(ulasanProfil.rating, 4);
        expect(ulasanProfil.komentar, komentar);

        // Kedua jalur membuka ulang detail dari daftar ulasan yang sama.
        for (final tab in ['Cari', 'Favorit']) {
          await tester.tap(find.text(tab).last);
          await tester.pumpAndSettle();
          await tester.tap(kartuMelati);
          await tester.pumpAndSettle();
          expect(find.text('Ulasan (1)'), findsOneWidget);
          expect(find.text(komentar), findsOneWidget);
          await tester.pageBack();
          await tester.pumpAndSettle();
        }

        // Ulasan kos pertama tidak boleh muncul pada kos lain.
        await tester.tap(find.text('Cari').last);
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(KartuKos, 'Kos Mawar Sukapura'));
        await tester.pumpAndSettle();
        expect(find.text('Ulasan (0)'), findsOneWidget);
        expect(find.text(komentar), findsNothing);
      },
    );
  }
}
