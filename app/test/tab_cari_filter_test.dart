import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kosdekat/halaman/tab_cari.dart';
import 'package:kosdekat/model/kos.dart';
import 'package:kosdekat/widgets/kategori_segmented_button.dart';
import 'package:kosdekat/widgets/sort_selector.dart';

Kos _kos(String id, String nama, String area, String tipe, int harga,
        double jarak) =>
    Kos(
      id: id,
      nama: nama,
      area: area,
      tipe: tipe,
      hargaBulanan: harga,
      kamarMandiDalam: true,
      jarakKm: jarak,
      diperbarui: DateTime(2026, 11, 10),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final semua = [
    _kos('1', 'Kos Melati Indah', 'Sukapura', 'Putri', 1250000, 0.5),
    _kos('2', 'Pondok Asri', 'Dayeuhkolot', 'Putra', 900000, 1.2),
    _kos('3', 'Griya Mahasiswa', 'Sukapura', 'Campur', 1500000, 0.3),
  ];

  List<String> nama(List<Kos> l) => l.map((k) => k.nama).toList();

  group('saringKos', () {
    test('tanpa filter: semua kos, urut jarak terdekat', () {
      expect(nama(saringKos(semua)), [
        'Griya Mahasiswa',
        'Kos Melati Indah',
        'Pondok Asri',
      ]);
    });

    test('filter tipe Putra', () {
      expect(
          nama(saringKos(semua, tipe: TipeKosFilter.putra)), ['Pondok Asri']);
    });

    test('filter area Sukapura, urut harga terendah', () {
      expect(
        nama(saringKos(semua, area: 'Sukapura', urutan: SortOption.hargaAsc)),
        ['Kos Melati Indah', 'Griya Mahasiswa'],
      );
    });

    test('urut harga tertinggi', () {
      expect(nama(saringKos(semua, urutan: SortOption.hargaDesc)).first,
          'Griya Mahasiswa');
    });

    test('kombinasi tanpa hasil mengembalikan list kosong, data asli tetap',
        () {
      expect(saringKos(semua, tipe: TipeKosFilter.putra, area: 'Sukapura'),
          isEmpty);
      expect(nama(semua).first, 'Kos Melati Indah');
    });
  });

  // Teks "Putra" juga ada di label tipe kartu, jadi cari di dalam SegmentedButton.
  final segmenPutra = find.descendant(
    of: find.byType(SegmentedButton<TipeKosFilter>),
    matching: find.text('Putra'),
  );

  Widget buatTab() => MaterialApp(
        home: Scaffold(
          body: TabCari(futureKos: Future.value(semua), idFavorit: const {}),
        ),
      );

  testWidgets('SegmentedButton Putra hanya menampilkan kos putra',
      (tester) async {
    await tester.pumpWidget(buatTab());
    await tester.pumpAndSettle();
    expect(find.text('Kos Melati Indah'), findsOneWidget);

    await tester.tap(segmenPutra);
    await tester.pumpAndSettle();

    expect(find.text('Pondok Asri'), findsOneWidget);
    expect(find.text('Kos Melati Indah'), findsNothing);
    expect(find.text('Griya Mahasiswa'), findsNothing);
  });

  testWidgets('chip area dibuat dari data dan menyaring daftar',
      (tester) async {
    await tester.pumpWidget(buatTab());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ChoiceChip, 'Dayeuhkolot'));
    await tester.pumpAndSettle();

    expect(find.text('Pondok Asri'), findsOneWidget);
    expect(find.text('Kos Melati Indah'), findsNothing);
  });

  testWidgets('filter tanpa hasil menampilkan pesan dan bisa direset',
      (tester) async {
    await tester.pumpWidget(buatTab());
    await tester.pumpAndSettle();

    await tester.tap(segmenPutra);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Sukapura'));
    await tester.pumpAndSettle();

    expect(find.text('Tidak ada kos yang cocok dengan filter ini.'),
        findsOneWidget);

    await tester.tap(find.text('Tampilkan semua kos'));
    await tester.pumpAndSettle();

    expect(find.text('Kos Melati Indah'), findsOneWidget);
    expect(find.text('Pondok Asri'), findsOneWidget);
  });
}
