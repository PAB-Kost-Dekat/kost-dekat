import 'package:flutter/material.dart';

import '../model/kos.dart';
import '../model/ulasan.dart';
import '../tema/tema_kosdekat.dart';
import '../util/format_rupiah.dart';
import 'halaman_form_ulasan.dart';

/// Halaman detail kos (SCRUM-28).
/// Menerima objek [Kos] utuh lewat konstruktor (P05).
class HalamanDetailKos extends StatefulWidget {
  const HalamanDetailKos({
    super.key,
    required this.kos,
    this.ulasanAwal = const [],
    this.onUlasanBaru,
    this.isFavorit = false,
    this.onToggleFavorit,
    this.heroTag,
  });

  final Kos kos;
  final List<Ulasan> ulasanAwal;
  final ValueChanged<Ulasan>? onUlasanBaru;
  final bool isFavorit;
  final VoidCallback? onToggleFavorit;

  /// Sama persis dengan tag di [KartuKos] yang membuka halaman ini.
  final String? heroTag;

  @override
  State<HalamanDetailKos> createState() => _HalamanDetailKosState();
}

class _HalamanDetailKosState extends State<HalamanDetailKos> {
  late List<Ulasan> _ulasanKos;
  late bool _isFavorit;

  @override
  void initState() {
    super.initState();
    // Simpan salinan ulasan di State lokal agar ulasan baru langsung muncul
    _ulasanKos = List<Ulasan>.from(widget.ulasanAwal);
    _isFavorit = widget.isFavorit;
  }

  void _toggleFavorit() {
    setState(() {
      _isFavorit = !_isFavorit;
    });
    widget.onToggleFavorit?.call();
  }

  Future<void> _tulisUlasan() async {
    final ulasanBaru = await Navigator.push<Ulasan>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            HalamanFormUlasan(kosId: widget.kos.id, namaKos: widget.kos.nama),
      ),
    );

    if (!mounted) return;

    if (ulasanBaru != null) {
      setState(() {
        _ulasanKos.insert(0, ulasanBaru);
      });
      widget.onUlasanBaru?.call(ulasanBaru);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Ulasan tersimpan')));
    }
  }

  Widget _bungkusHero(ColorScheme warna, Widget gambar) {
    final tag = widget.heroTag;
    if (tag == null) return gambar;
    return Hero(
      tag: tag,
      // Isi gambar detail (ikon + teks) akan overflow bila diperkecil saat terbang,
      // jadi selama animasi tampilkan kotak polos yang ikonnya ikut menyesuaikan.
      flightShuttleBuilder: (konteks, animasi, arah, dari, ke) => Container(
        color: warna.primaryContainer,
        padding: const EdgeInsets.all(8),
        child: FittedBox(
          child: Icon(Icons.apartment, color: warna.onPrimaryContainer),
        ),
      ),
      child: gambar,
    );
  }

  double get _rataRataRating {
    if (_ulasanKos.isEmpty) return 0.0;
    final total = _ulasanKos.fold<int>(0, (sum, item) => sum + item.rating);
    return total / _ulasanKos.length;
  }

  @override
  Widget build(BuildContext context) {
    final kos = widget.kos;
    final teks = Theme.of(context).textTheme;
    final warna = Theme.of(context).colorScheme;
    final warnaBintang =
        Theme.of(context).extension<WarnaKosDekat>()?.bintang ?? warna.primary;

    // Inovasi: "Diperbarui N hari lalu" dan "±N menit jalan kaki"
    final selisihHari = DateTime.now().difference(kos.diperbarui).inDays;
    final teksDiperbarui = selisihHari <= 0
        ? 'Diperbarui hari ini'
        : 'Diperbarui $selisihHari hari lalu';
    final menitJalan = (kos.jarakKm * 12).round();
    final teksWaktuJalan = '±$menitJalan menit jalan kaki';

    return Scaffold(
      appBar: AppBar(
        title: Text(kos.nama),
        actions: [
          IconButton(
            tooltip: _isFavorit ? 'Hapus favorit' : 'Tambah favorit',
            icon: Icon(
              _isFavorit ? Icons.favorite : Icons.favorite_border,
              color: _isFavorit ? warna.error : null,
            ),
            onPressed: _toggleFavorit,
          ),
        ],
      ),
      body: ListView(
        children: [
          // Gambar aset + placeholder jika belum ada di aset
          _bungkusHero(
            warna,
            ClipRRect(
              child: Image.asset(
                'assets/images/kos_${kos.id}.png',
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 240,
                    color: warna.primaryContainer,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.apartment,
                          size: 72,
                          color: warna.onPrimaryContainer,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          kos.nama,
                          style: teks.titleMedium?.copyWith(
                            color: warna.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Kos
                Text(kos.nama, style: teks.headlineSmall),
                const SizedBox(height: 8),

                // Harga formatRupiah
                Text(
                  formatRupiah(kos.hargaBulanan),
                  style: teks.titleLarge?.copyWith(
                    color: warna.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Badges: Tipe, Area, Kamar Mandi Dalam
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      avatar: const Icon(Icons.person_outline, size: 18),
                      label: Text(kos.tipe),
                    ),
                    Chip(
                      avatar: const Icon(Icons.location_on_outlined, size: 18),
                      label: Text(kos.area),
                    ),
                    Chip(
                      avatar: Icon(
                        kos.kamarMandiDalam
                            ? Icons.bathtub_outlined
                            : Icons.shower_outlined,
                        size: 18,
                      ),
                      label: Text(
                        kos.kamarMandiDalam
                            ? 'Kamar Mandi Dalam (Ya)'
                            : 'Kamar Mandi Luar (Tidak)',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Divider(),
                const SizedBox(height: 8),

                // Lokasi dan Jarak
                Row(
                  children: [
                    Icon(Icons.directions_walk, color: warna.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${kos.jarakKm.toString().replaceAll('.', ',')} km dari kampus ($teksWaktuJalan)',
                        style: teks.bodyMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Informasi Pembaruan & ID
                Row(
                  children: [
                    Icon(Icons.history, color: warna.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        teksDiperbarui,
                        style: teks.bodyMedium?.copyWith(
                          color: warna.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Text(
                      'ID: ${kos.id}',
                      style: teks.bodySmall?.copyWith(
                        color: warna.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Bagian Ulasan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ulasan (${_ulasanKos.length})',
                      style: teks.titleMedium,
                    ),
                    if (_ulasanKos.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.star, color: warnaBintang, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            _rataRataRating.toStringAsFixed(1),
                            style: teks.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_ulasanKos.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Belum ada ulasan untuk kos ini. Jadilah yang pertama memberikan ulasan!',
                      style: teks.bodyMedium?.copyWith(
                        color: warna.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  ..._ulasanKos.map((ulasan) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(ulasan.namaKos, style: teks.titleSmall),
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      i < ulasan.rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: warnaBintang,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${ulasan.tanggal.day}/${ulasan.tanggal.month}/${ulasan.tanggal.year}',
                              style: teks.bodySmall?.copyWith(
                                color: warna.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(ulasan.komentar, style: teks.bodyMedium),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 72), // Memberikan ruang untuk FAB
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tulisUlasan,
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Tulis Ulasan'),
      ),
    );
  }
}
