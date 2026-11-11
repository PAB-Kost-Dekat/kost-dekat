import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/kos.dart';
import '../model/ringkasan_area.dart';
import '../model/ulasan.dart';

const String apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:8080',
);

class KosService {
  KosService({http.Client? client, String baseUrl = apiUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), '');

  final http.Client _client;
  final String _baseUrl;

  Future<List<Kos>> ambilDaftarKos() async {
    final data = await _ambilJson('/kos') as List<dynamic>;
    return data
        .map((item) => Kos.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Kos> ambilKos(String id) async {
    final data = await _ambilJson('/kos/${Uri.encodeComponent(id)}');
    return Kos.fromJson(data as Map<String, dynamic>);
  }

  Future<List<RingkasanArea>> ambilRingkasanArea() async {
    final data = await _ambilJson('/area') as List<dynamic>;
    return data
        .map((item) => RingkasanArea.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Ulasan> kirimUlasan(Ulasan ulasan) async {
    final response = await _client
        .post(
          Uri.parse('$_baseUrl/ulasan'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(ulasan.toJson()),
        )
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 201) {
      throw Exception('Gagal mengirim ulasan: status ${response.statusCode}');
    }
    return Ulasan.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  void dispose() => _client.close();

  Future<Object?> _ambilJson(String path) async {
    final response = await _client
        .get(Uri.parse('$_baseUrl$path'))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat data (kode ${response.statusCode})');
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}
