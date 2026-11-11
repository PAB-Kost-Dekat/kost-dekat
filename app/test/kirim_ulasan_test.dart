import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kosdekat/halaman/halaman_utama.dart';
import 'package:kosdekat/model/ulasan.dart';
import 'package:kosdekat/service/kos_service.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  final dataKos = jsonEncode([
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

  group('KosService.kirimUlasan', () {
    final ulasan = Ulasan(
      kosId: 'kos-1',
      namaKos: 'Kos Melati Indah',
      rating: 4,
      komentar: 'Bersih',
      tanggal: DateTime(2026, 11, 11, 10),
    );

    test('POST JSON ke /ulasan dan membaca balasan 201', () async {
      late http.Request diterima;
      final service = KosService(
        client: MockClient((request) async {
          diterima = request;
          return http.Response(request.body, 201);
        }),
        baseUrl: 'http://localhost:8080',
      );

      final hasil = await service.kirimUlasan(ulasan);

      expect(diterima.method, 'POST');
      expect(diterima.url.path, '/ulasan');
      expect(diterima.headers['Content-Type'], startsWith('application/json'));
      final body = jsonDecode(diterima.body) as Map<String, dynamic>;
      expect(body['kosId'], 'kos-1');
      expect(body['rating'], 4);
      expect(hasil.komentar, 'Bersih');
    });

    test('status selain 201 melempar exception', () async {
      final service = KosService(
        client: MockClient(
          (_) async => http.Response('{"message":"x"}', 400),
        ),
        baseUrl: 'http://localhost:8080',
      );
      expect(service.kirimUlasan(ulasan), throwsException);
    });
  });

  /// Server palsu: GET /kos selalu berhasil, POST /ulasan memakai [kodePost].
  ({KosService service, List<String> post}) buatServer(int kodePost) {
    final post = <String>[];
    final service = KosService(
      client: MockClient((request) async {
        if (request.method == 'POST') {
          post.add(request.body);
          return http.Response(request.body, kodePost);
        }
        return http.Response(dataKos, 200);
      }),
      baseUrl: 'http://localhost:8080',
    );
    return (service: service, post: post);
  }

  Future<void> tulisUlasan(WidgetTester tester, KosService service) async {
    await tester.pumpWidget(
      MaterialApp(home: HalamanUtama(kosService: service)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kos Melati Indah'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tulis Ulasan'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).last,
      'Dekat kampus dan bersih',
    );
    await tester.ensureVisible(find.text('Kirim Ulasan'));
    await tester.tap(find.text('Kirim Ulasan'));
    await tester.pumpAndSettle();
  }

  testWidgets('ulasan dari form terkirim ke server dan SnackBar sukses', (
    tester,
  ) async {
    final server = buatServer(201);
    await tulisUlasan(tester, server.service);

    expect(server.post, hasLength(1));
    expect(jsonDecode(server.post.single)['kosId'], 'kos-1');
    expect(find.text('Ulasan terkirim ke server'), findsOneWidget);
    expect(find.text('Dekat kampus dan bersih'), findsOneWidget);
  });

  testWidgets(
    'server gagal: tidak crash, SnackBar gagal, ulasan tetap di detail dan Profil',
    (tester) async {
      final server = buatServer(500);
      await tulisUlasan(tester, server.service);

      expect(tester.takeException(), isNull);
      expect(server.post, hasLength(1));
      expect(
        find.text('Gagal mengirim, ulasan disimpan di perangkat'),
        findsOneWidget,
      );
      expect(find.text('Dekat kampus dan bersih'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.text('Dekat kampus dan bersih'), findsOneWidget);
    },
  );
}
