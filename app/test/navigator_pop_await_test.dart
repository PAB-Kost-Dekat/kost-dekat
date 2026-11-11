import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kosdekat/halaman/halaman_detail_kos.dart';
import 'package:kosdekat/halaman/halaman_form_ulasan.dart';
import 'package:kosdekat/model/kos.dart';
import 'package:kosdekat/model/ulasan.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final kosContoh = Kos(
    id: 'k-01',
    nama: 'Kos Melati Indah (contoh)',
    area: 'Sukapura',
    tipe: 'Putri',
    hargaBulanan: 1250000,
    kamarMandiDalam: true,
    jarakKm: 0.8,
    diperbarui: DateTime(2026, 10, 28),
  );

  final ulasanAwal = [
    Ulasan(
      kosId: 'k-01',
      namaKos: 'Kos Melati Indah (contoh)',
      rating: 4,
      komentar: 'Nyaman dan bersih',
      tanggal: DateTime(2026, 10, 1),
    ),
  ];

  testWidgets('halaman detail menampilkan ulasan awal', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HalamanDetailKos(kos: kosContoh, ulasanAwal: ulasanAwal),
      ),
    );
    await tester.pump();

    expect(find.text('Ulasan (1)'), findsOneWidget);
    expect(find.text('Nyaman dan bersih'), findsOneWidget);
  });

  testWidgets(
    'tekan back di form tanpa isi tidak menambah ulasan dan tidak error',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HalamanDetailKos(kos: kosContoh, ulasanAwal: ulasanAwal),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Tulis Ulasan'));
      await tester.pumpAndSettle();
      expect(find.byType(HalamanFormUlasan), findsOneWidget);

      // Back tanpa isi: Navigator.pop mengembalikan null ke detail.
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();

      expect(find.byType(HalamanFormUlasan), findsNothing);
      expect(find.text('Ulasan (1)'), findsOneWidget);
      expect(find.text('Ulasan tersimpan'), findsNothing);
    },
  );

  testWidgets(
    'ulasan baru langsung muncul di daftar dan SnackBar tampil (P05 + P03)',
    (tester) async {
      Ulasan? ulasanDiterima;

      await tester.pumpWidget(
        MaterialApp(
          home: HalamanDetailKos(
            kos: kosContoh,
            ulasanAwal: const [],
            onUlasanBaru: (u) => ulasanDiterima = u,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Ulasan (0)'), findsOneWidget);

      await tester.tap(find.text('Tulis Ulasan'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Rating 4 bintang'));
      await tester.pump();
      await tester.enterText(
        find.byType(TextField).last,
        'Lokasi bagus dan harga terjangkau',
      );
      await tester.ensureVisible(find.text('Kirim Ulasan'));
      await tester.tap(find.text('Kirim Ulasan'));
      await tester.pumpAndSettle();

      // Kembali ke detail: ulasan baru langsung tampil dan SnackBar muncul.
      expect(find.byType(HalamanFormUlasan), findsNothing);
      expect(find.text('Ulasan (1)'), findsOneWidget);
      expect(find.text('Lokasi bagus dan harga terjangkau'), findsOneWidget);
      expect(find.text('Ulasan tersimpan'), findsOneWidget);

      // Callback onUlasanBaru menerima data yang dikirim form.
      expect(ulasanDiterima, isNotNull);
      expect(ulasanDiterima!.kosId, 'k-01');
      expect(ulasanDiterima!.rating, 4);
      expect(ulasanDiterima!.komentar, 'Lokasi bagus dan harga terjangkau');
    },
  );
}
