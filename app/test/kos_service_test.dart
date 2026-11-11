import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kosdekat/service/kos_service.dart';

void main() {
  const baseUrl = 'http://localhost:8080';
  const kos = {
    'id': '1',
    'nama': 'Kos Melati Indah (contoh)',
    'nama': 'Kos Melati',
    'area': 'Sukapura',
    'tipe': 'Putri',
    'hargaBulanan': 1200000,
    'kamarMandiDalam': true,
    'jarakKm': 1,
    'diperbarui': '2026-11-10T12:00:00Z',
  };
  const kosKedua = {
    'id': '2',
    'nama': 'Kos Graha Sukapura (contoh)',
    'area': 'Sukapura',
    'tipe': 'Putra',
    'hargaBulanan': 900000,
    'kamarMandiDalam': false,
    'jarakKm': 0.5,
    'diperbarui': '2026-11-09T08:30:00Z',
  };
  const area = {'area': 'Sukapura', 'jumlahKos': 2, 'hargaRataRata': 1050000};

  test('memuat dua kos Sukapura beserta detail dan ringkasan area', () async {
  const area = {'area': 'Sukapura', 'jumlahKos': 1, 'hargaRataRata': 1200000};

  test('memuat daftar kos, detail, dan ringkasan area', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.origin, baseUrl);
      final data = switch (request.url.path) {
        '/kos' => [kos, kosKedua],
        '/kos' => [kos],
        '/kos/1' => kos,
        '/area' => [area],
        _ => throw StateError('Endpoint tidak dikenal: ${request.url}'),
      };
      return http.Response(jsonEncode(data), 200);
    });
    addTearDown(client.close);
    final service = KosService(client: client, baseUrl: '$baseUrl/');

    final daftarKos = await service.ambilDaftarKos();
    expect(daftarKos, hasLength(2));
    expect(daftarKos[0].nama, 'Kos Melati Indah (contoh)');
    expect(daftarKos[0].hargaBulanan, 1200000);
    expect(daftarKos[0].diperbarui, DateTime.utc(2026, 11, 10, 12));
    expect(daftarKos[0].jarakKm, 1.0);
    expect(daftarKos[1].nama, 'Kos Graha Sukapura (contoh)');
    expect(daftarKos[1].hargaBulanan, 900000);
    expect(daftarKos[1].diperbarui, DateTime.utc(2026, 11, 9, 8, 30));
    expect((await service.ambilKos('1')).nama, 'Kos Melati Indah (contoh)');
    final ringkasan = (await service.ambilRingkasanArea()).single;
    expect(ringkasan.area, 'Sukapura');
    expect(ringkasan.jumlahKos, 2);
    expect(ringkasan.hargaRataRata, 1050000);
  });

  test('gagal memuat daftar KosDekat saat GET /kos membalas 500', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/kos');
      return http.Response('', 500);
    });
    addTearDown(client.close);
    final service = KosService(client: client, baseUrl: baseUrl);

    await expectLater(service.ambilDaftarKos(), throwsException);
    expect((await service.ambilDaftarKos()).single.jarakKm, 1.0);
    expect((await service.ambilKos('1')).nama, 'Kos Melati');
    final ringkasan = (await service.ambilRingkasanArea()).single;
    expect(ringkasan.area, 'Sukapura');
    expect(ringkasan.jumlahKos, 1);
    expect(ringkasan.hargaRataRata, 1200000);
  });

  test('melempar Exception dengan kode status selain 200', () async {
    final client = MockClient((_) async => http.Response('', 404));
    addTearDown(client.close);
    final service = KosService(client: client, baseUrl: baseUrl);

    await expectLater(
      service.ambilKos('999'),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'pesan',
          contains('Gagal memuat data (kode 404)'),
        ),
      ),
    );
  });
}
