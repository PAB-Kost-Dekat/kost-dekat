import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kosdekat/main.dart';
import 'package:kosdekat/services/api_service.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

import 'package:kosdekat/main.dart';
import 'package:kosdekat/model/kos.dart';
import 'package:kosdekat/widgets/kartu_kost.dart';

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

  testWidgets('KosDekatApp smoke test', (tester) async {
    final client = MockClient((request) async {
      return http.Response('[]', 200, headers: {'content-type': 'application/json'});
    });
    final api = ApiService(baseUrl: 'http://localhost:8080', client: client);
    await tester.pumpWidget(KosDekatApp(api: api));
    expect(find.text('KosDekat'), findsOneWidget);
    api.dispose();
  }

  testWidgets('kartu KosDekat menampilkan nama dan harga bulanan', (
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
          body: KartuKost(kos: kos, onTap: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kos Melati Indah (contoh)'), findsOneWidget);
    expect(find.text('Rp1.250.000/bln'), findsOneWidget);
    // Tag harus sama dengan DetailKosPage agar animasi Hero berjalan.
    expect(
      tester.widget<Hero>(find.byType(Hero)).tag,
      equals('kos-img-${kos.id}'),
    );
  });
}
