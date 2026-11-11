import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kosdekat/halaman/halaman_form_ulasan.dart';
import 'package:kosdekat/model/kos.dart';
import 'package:kosdekat/widget/kartu_kos.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final kosContoh = Kos(
    id: 'k-01',
    nama: 'Kos Sukapura Indah',
    area: 'Sukapura',
    tipe: 'Putri',
    hargaBulanan: 1250000,
    kamarMandiDalam: true,
    jarakKm: 0.5,
    diperbarui: DateTime(2026, 11, 10),
  );

  group('P03: StatelessWidget buatan sendiri', () {
    testWidgets('KartuKos adalah StatelessWidget dan menampilkan data kos', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KartuKos(kos: kosContoh),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Memastikan KartuKos adalah StatelessWidget buatan sendiri
      expect(find.byType(KartuKos), findsOneWidget);
      expect(tester.widget(find.byType(KartuKos)), isA<StatelessWidget>());

      // Menampilkan informasi dari model Kos
      expect(find.text('Kos Sukapura Indah'), findsOneWidget);
      expect(find.text('Sukapura'), findsOneWidget);
      expect(find.text('Putri'), findsOneWidget);
      expect(find.text('Rp1.250.000/bln'), findsOneWidget);
    });
  });

  group('P03: StatefulWidget buatan sendiri + setState mengubah tampilan', () {
    testWidgets(
      'HalamanFormUlasan adalah StatefulWidget dan setState mengubah tampilan rating bintang',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: HalamanFormUlasan(
              kosId: 'k-01',
              namaKos: 'Kos Sukapura Indah',
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Memastikan HalamanFormUlasan adalah StatefulWidget buatan sendiri
        expect(find.byType(HalamanFormUlasan), findsOneWidget);
        expect(
          tester.widget(find.byType(HalamanFormUlasan)),
          isA<StatefulWidget>(),
        );

        // Awalnya rating default 5 bintang aktif
        expect(find.byIcon(Icons.star), findsNWidgets(5));
        expect(find.byIcon(Icons.star_border), findsNothing);

        // Ketuk bintang ke-2 -> setState terpanggil -> tampilan berubah jadi 2 bintang aktif dan 3 border
        await tester.tap(find.byTooltip('Rating 2 bintang'));
        await tester.pump();

        expect(find.byIcon(Icons.star), findsNWidgets(2));
        expect(find.byIcon(Icons.star_border), findsNWidgets(3));

        // Ketuk bintang ke-4 -> setState terpanggil -> tampilan berubah jadi 4 bintang aktif dan 1 border
        await tester.tap(find.byTooltip('Rating 4 bintang'));
        await tester.pump();

        expect(find.byIcon(Icons.star), findsNWidgets(4));
        expect(find.byIcon(Icons.star_border), findsOneWidget);
      },
    );
  });
}

