import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kosdekat/halaman/halaman_form_ulasan.dart';
import 'package:kosdekat/model/ulasan.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  const kosId = 'k-01';
  const namaKos = 'Kos Melati Indah (contoh)';

  Widget buatHalaman() => const MaterialApp(
    home: HalamanFormUlasan(kosId: kosId, namaKos: namaKos),
  );

  Future<void> kirim(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Kirim Ulasan'));
    await tester.tap(find.text('Kirim Ulasan'));
    await tester.pumpAndSettle();
  }

  testWidgets('nama kos tampil di form', (tester) async {
    await tester.pumpWidget(buatHalaman());
    expect(find.text(namaKos), findsOneWidget);
  });

  testWidgets('mengetuk bintang ke-4 menyalakan 4 bintang', (tester) async {
    await tester.pumpWidget(buatHalaman());

    await tester.tap(find.byTooltip('Rating 4 bintang'));
    await tester.pump();

    expect(find.byIcon(Icons.star), findsNWidgets(4));
    expect(find.byIcon(Icons.star_border), findsOneWidget);
  });

  testWidgets('kirim tanpa komentar ditolak', (tester) async {
    await tester.pumpWidget(buatHalaman());

    await kirim(tester);

    expect(find.text('Komentar tidak boleh kosong'), findsOneWidget);
    expect(find.byType(HalamanFormUlasan), findsOneWidget);
  });

  testWidgets('komentar kurang dari 5 karakter ditolak', (tester) async {
    await tester.pumpWidget(buatHalaman());

    await tester.enterText(find.byType(TextField).last, 'oke');
    await kirim(tester);

    expect(find.text('Komentar minimal 5 karakter'), findsOneWidget);
  });

  testWidgets('kirim valid menutup halaman dengan objek Ulasan', (
    tester,
  ) async {
    Ulasan? hasilPop;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) => ElevatedButton(
            onPressed: () async {
              hasilPop = await Navigator.push<Ulasan>(
                ctx,
                MaterialPageRoute(
                  builder: (_) =>
                      const HalamanFormUlasan(kosId: kosId, namaKos: namaKos),
                ),
              );
            },
            child: const Text('Buka Form'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka Form'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Rating 3 bintang'));
    await tester.pump();
    await tester.enterText(
      find.byType(TextField).last,
      'Lokasi strategis, kamar bersih',
    );
    await kirim(tester);

    expect(find.byType(HalamanFormUlasan), findsNothing);
    expect(hasilPop, isNotNull);
    expect(hasilPop!.kosId, kosId);
    expect(hasilPop!.namaKos, namaKos);
    expect(hasilPop!.rating, 3);
    expect(hasilPop!.komentar, 'Lokasi strategis, kamar bersih');
  });
}
