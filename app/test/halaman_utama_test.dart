import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:kosdekat/halaman/halaman_utama.dart';
import 'package:kosdekat/model/ulasan.dart';
import 'package:kosdekat/service/kos_service.dart';

void main() {
  final dataKosContoh = [
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
    {
      'id': 'kos-2',
      'nama': 'Pondok Asri',
      'area': 'Dayeuhkolot',
      'tipe': 'Putra',
      'hargaBulanan': 900000,
      'kamarMandiDalam': false,
      'jarakKm': 1.2,
      'diperbarui': '2026-10-28T09:00:00.000',
    },
  ];

  KosService buatService({
    List<Map<String, dynamic>>? data,
    void Function()? onRequest,
  }) {
    final client = MockClient((request) async {
      onRequest?.call();
      if (request.url.path == '/kos') {
        return http.Response(
          jsonEncode(data ?? dataKosContoh),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      return http.Response('Not Found', 404);
    });
    return KosService(client: client, baseUrl: 'http://localhost:8080');
  }

  testWidgets(
    'Ketiga tab bisa dipindah dan tap tab Favorit menampilkan halaman Favorit',
    (tester) async {
      final service = buatService();
      await tester.pumpWidget(
        MaterialApp(home: HalamanUtama(kosService: service)),
      );
      await tester.pumpAndSettle();

      // Tab default adalah Cari
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Kos Melati Indah'), findsOneWidget);

      // Pindah ke tab Favorit
      await tester.tap(find.text('Favorit'));
      await tester.pumpAndSettle();

      // Halaman Favorit tampil
      expect(find.text('Favorit'), findsWidgets);
      expect(find.text('Belum ada kos favorit yang ditandai.'), findsOneWidget);
      expect(
        find.image(const AssetImage('assets/kos_illustration.png')),
        findsOneWidget,
      );

      // Pindah ke tab Profil
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();

      expect(find.text('Mahasiswa Tel-U'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Keluar'), findsOneWidget);

      // Pindah kembali ke tab Cari
      await tester.tap(find.text('Cari'));
      await tester.pumpAndSettle();

      expect(find.text('Kos Melati Indah'), findsOneWidget);
    },
  );

  testWidgets(
    'Posisi scroll tab Cari tetap saat berpindah tab dan kembali (IndexedStack)',
    (tester) async {
      // Buat data banyak agar daftar bisa di-scroll
      final banyakKos = List.generate(
        30,
        (i) => {
          'id': 'kos-$i',
          'nama': 'Kos Mahasiswa $i',
          'area': 'Sukapura',
          'tipe': 'Campur',
          'hargaBulanan': 1000000 + (i * 50000),
          'kamarMandiDalam': true,
          'jarakKm': 0.1 * (i + 1),
          'diperbarui': '2026-10-28T09:00:00.000',
        },
      );

      final service = buatService(data: banyakKos);
      await tester.pumpWidget(
        MaterialApp(home: HalamanUtama(kosService: service)),
      );
      await tester.pumpAndSettle();

      final scrollableFinder = find.byType(Scrollable).first;
      final offsetSebelum = tester
          .state<ScrollableState>(scrollableFinder)
          .position
          .pixels;

      // Gulir ke bawah
      await tester.drag(scrollableFinder, const Offset(0, -300));
      await tester.pumpAndSettle();

      final offsetSetelahScroll = tester
          .state<ScrollableState>(scrollableFinder)
          .position
          .pixels;
      expect(offsetSetelahScroll, greaterThan(offsetSebelum));

      // Pindah ke tab Favorit
      await tester.tap(find.text('Favorit'));
      await tester.pumpAndSettle();

      // Pindah kembali ke tab Cari
      await tester.tap(find.text('Cari'));
      await tester.pumpAndSettle();

      // Posisi scroll tetap terjaga karena menggunakan IndexedStack
      final offsetSetelahKembali = tester
          .state<ScrollableState>(scrollableFinder)
          .position
          .pixels;
      expect(offsetSetelahKembali, equals(offsetSetelahScroll));
    },
  );

  testWidgets('Pindah tab tidak memanggil server ulang', (tester) async {
    var callCount = 0;
    final service = buatService(
      onRequest: () {
        callCount++;
      },
    );

    await tester.pumpWidget(
      MaterialApp(home: HalamanUtama(kosService: service)),
    );
    await tester.pumpAndSettle();

    // Saat awal, hanya dipanggil 1 kali
    expect(callCount, equals(1));

    // Pindah ke tab Favorit
    await tester.tap(find.text('Favorit'));
    await tester.pumpAndSettle();
    expect(callCount, equals(1));

    // Pindah ke tab Profil
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(callCount, equals(1));

    // Pindah kembali ke Cari
    await tester.tap(find.text('Cari'));
    await tester.pumpAndSettle();
    expect(callCount, equals(1));
  });

  testWidgets(
    'Callback toggleFavorit, tambahUlasan, dan muatUlang memperbarui state',
    (tester) async {
      var fetchCount = 0;
      final service = buatService(
        onRequest: () {
          fetchCount++;
        },
      );

      await tester.pumpWidget(
        MaterialApp(home: HalamanUtama(kosService: service)),
      );
      await tester.pumpAndSettle();

      final state = tester.state<HalamanUtamaState>(find.byType(HalamanUtama));

      // 1. Uji toggleFavorit
      expect(state.idFavorit.contains('kos-1'), isFalse);
      state.toggleFavorit('kos-1');
      await tester.pump();
      expect(state.idFavorit.contains('kos-1'), isTrue);

      state.toggleFavorit('kos-1');
      await tester.pump();
      expect(state.idFavorit.contains('kos-1'), isFalse);

      // 2. Uji tambahUlasan
      expect(state.daftarUlasan, isEmpty);
      final ulasanBaru = Ulasan(
        kosId: 'kos-1',
        namaKos: 'Kos Melati Indah',
        rating: 5,
        komentar: 'Sangat nyaman dan bersih!',
        tanggal: DateTime.now(),
      );
      state.tambahUlasan(ulasanBaru);
      await tester.pump();
      expect(state.daftarUlasan.length, equals(1));
      expect(
        state.daftarUlasan.first.komentar,
        equals('Sangat nyaman dan bersih!'),
      );

      // 3. Uji muatUlang
      expect(fetchCount, equals(1));
      state.muatUlang();
      await tester.pumpAndSettle();
      expect(fetchCount, equals(2));
    },
  );
}
