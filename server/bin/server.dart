import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

Future<void> main() async {
  final file = File('data/kos.json');
  final List<dynamic> kos = jsonDecode(await file.readAsString()) as List<dynamic>;
  final router = Router();

  router.get('/health', (Request request) =>
    Response.ok(jsonEncode({'status': 'ok', 'service': 'KosDekat API'}),
      headers: {'content-type': 'application/json'}));

  router.get('/kos', (Request request) =>
    Response.ok(jsonEncode(kos), headers: {'content-type': 'application/json'}));

// Penyimpanan ulasan di memori (akan reset saat server restart).
final daftarUlasan = <Map<String, dynamic>>[];

Future<void> main() async {
  final file = File('data/kos.json');
  final List<dynamic> kos = jsonDecode(await file.readAsString()) as List<dynamic>;
  final router = Router();

  router.get('/health', (Request request) =>
    Response.ok(jsonEncode({'status': 'ok', 'service': 'KosDekat API'}),
      headers: {'content-type': 'application/json'}));

  router.get('/kos', (Request request) =>
    Response.ok(jsonEncode(kos), headers: {'content-type': 'application/json'}));

  router.get('/kos/<id>', (Request request, String id) {
    final matches = kos.where((item) => item['id'] == id).toList();
    if (matches.isEmpty) {
      return Response.notFound(jsonEncode({'message': 'Kos tidak ditemukan'}),
        headers: {'content-type': 'application/json'});
    }
    return Response.ok(jsonEncode(matches.first),
      headers: {'content-type': 'application/json'});
  });

  router.get('/area', (Request request) {
    final Map<String, List<num>> grouped = {};
    for (final item in kos) {
      final area = item['area'] as String;
      grouped.putIfAbsent(area, () => []).add(item['hargaBulanan'] as num);
    }
    final result = grouped.entries.map((entry) {
      final prices = entry.value;
      final average = prices.reduce((a, b) => a + b) / prices.length;
      return {'area': entry.key, 'jumlahKos': prices.length,
        'hargaRataRata': average.round()};
    }).toList()
      ..sort((a, b) => (a['area'] as String).compareTo(b['area'] as String));
    return Response.ok(jsonEncode(result),
      headers: {'content-type': 'application/json'});
  });

  // POST /ulasan — terima ulasan baru, simpan di memori, kembalikan 201.
  router.post('/ulasan', (Request request) async {
    final String rawBody;
    try {
      rawBody = await request.readAsString();
    } catch (_) {
      return Response(400,
        body: jsonEncode({'message': 'Body tidak dapat dibaca'}),
        headers: {'content-type': 'application/json'});
    }

    Map<String, dynamic> body;
    try {
      body = jsonDecode(rawBody) as Map<String, dynamic>;
    } catch (_) {
      return Response(400,
        body: jsonEncode({'message': 'Body bukan JSON valid'}),
        headers: {'content-type': 'application/json'});
    }

    final kosId = body['kosId'];
    final rating = body['rating'];
    final komentar = body['komentar'];

    // Validasi field wajib.
    if (kosId == null || kosId.toString().trim().isEmpty) {
      return Response(400,
        body: jsonEncode({'message': 'Field kosId wajib diisi'}),
        headers: {'content-type': 'application/json'});
    }
    if (rating == null || rating is! num || rating < 1 || rating > 5) {
      return Response(400,
        body: jsonEncode({'message': 'Field rating harus angka 1–5'}),
        headers: {'content-type': 'application/json'});
    }
    if (komentar == null || komentar.toString().trim().isEmpty) {
      return Response(400,
        body: jsonEncode({'message': 'Field komentar tidak boleh kosong'}),
        headers: {'content-type': 'application/json'});
    }

    final ulasan = {
      'id': 'u${daftarUlasan.length + 1}',
      'kosId': kosId.toString(),
      'namaKos': body['namaKos']?.toString() ?? '',
      'rating': rating.toInt(),
      'komentar': komentar.toString().trim(),
      'tanggal': body['tanggal']?.toString() ?? DateTime.now().toIso8601String(),
    };
    daftarUlasan.add(ulasan);

    return Response(201,
      body: jsonEncode(ulasan),
      headers: {'content-type': 'application/json'});
  });

  // GET /ulasan — ambil semua ulasan, opsional filter ?kosId=...
  router.get('/ulasan', (Request request) {
    final kosId = request.url.queryParameters['kosId'];
    final filtered = kosId != null
        ? daftarUlasan.where((u) => u['kosId'] == kosId).toList()
        : List<Map<String, dynamic>>.from(daftarUlasan);
    return Response.ok(jsonEncode(filtered),
      headers: {'content-type': 'application/json'});
  });

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware((inner) => (request) async {
        final response = await inner(request);
        return response.change(headers: {
          'access-control-allow-origin': '*',
          'access-control-allow-methods': 'GET, OPTIONS',
          'access-control-allow-methods': 'GET, POST, OPTIONS',
          'access-control-allow-headers': 'Origin, Content-Type',
          ...response.headers,
        });
      })
      .addHandler(router.call);

  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);
  print('KosDekat API berjalan di http://${server.address.host}:${server.port}');
  print('Endpoint: GET /kos, GET /kos/<id>, GET /area, GET /health');
  print('         POST /ulasan, GET /ulasan');
}
