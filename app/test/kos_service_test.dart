import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kosdekat/service/kos_service.dart';

void main() {
  const baseUrl = 'http://localhost:8080';
  const kos = {
    'id': '1',
    'nama': 'Kos Melati',
    'area': 'Sukapura',
    'tipe': 'Putri',
    'hargaBulanan': 1200000,
    'kamarMandiDalam': true,
    'jarakKm': 1,
    'diperbarui': '2026-11-10T12:00:00Z',
  };
  const area = {'area': 'Sukapura', 'jumlahKos': 1, 'hargaRataRata': 1200000};

  test('memuat daftar kos, detail, dan ringkasan area', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.origin, baseUrl);
      final data = switch (request.url.path) {
        '/kos' => [kos],
        '/kos/1' => kos,
        '/area' => [area],
        _ => throw StateError('Endpoint tidak dikenal: ${request.url}'),
      };
      return http.Response(jsonEncode(data), 200);
    });
    addTearDown(client.close);
    final service = KosService(client: client, baseUrl: '$baseUrl/');

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
