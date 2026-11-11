import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kosdekat/main.dart';
import 'package:kosdekat/model/kos.dart';
import 'package:kosdekat/widget/kartu_kos.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  for (final terang in [true, false]) {
    testWidgets('KosDekatApp tampil di tema ${terang ? 'terang' : 'gelap'}', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue =
          terang ? Brightness.light : Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await tester.pumpWidget(const KosDekatApp());

      expect(find.text('Masuk ke KosDekat'), findsOneWidget);
      final konteks = tester.element(find.text('Masuk ke KosDekat'));
      expect(
        Theme.of(konteks).brightness,
        terang ? Brightness.light : Brightness.dark,
      );
    });
  }

  testWidgets('KartuKos di tab Cari menampilkan nama dan harga bulanan', (
    tester,
  ) async {
    final kos = Kos(
      id: '1',
      nama: 'Kos Melati Indah (contoh)',
      area: 'Sukapura',
      tipe: 'Putri',
      hargaBulanan: 1250000,
      kamarMandiDalam: true,
      jarakKm: 0.8,
      diperbarui: DateTime(2026, 10, 28),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KartuKos(kos: kos),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kos Melati Indah (contoh)'), findsOneWidget);
    expect(find.text('Rp1.250.000/bln'), findsOneWidget);
  });
}
