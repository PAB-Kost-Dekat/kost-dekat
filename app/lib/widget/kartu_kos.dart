import 'package:flutter/material.dart';

import '../halaman/halaman_detail_kos.dart';
import '../model/kos.dart';
import '../model/ulasan.dart';
import '../util/format_rupiah.dart';

/// Kartu kos (SCRUM-21).
/// Menggunakan Stack, Column, Row, dan Expanded.
/// Membuka [HalamanDetailKos] melalui Navigator.push saat diketuk (P05).
class KartuKos extends StatelessWidget {
  const KartuKos({
    super.key,
    required this.kos,
    this.onTap,
    this.kirimUlasan,
    this.isFavorit = false,
    this.onToggleFavorit,
    this.daftarUlasan = const [],
    this.onUlasanBaru,
    this.heroTag,
  });

  final Kos kos;
  final VoidCallback? onTap;
  final Future<void> Function(Ulasan ulasan)? kirimUlasan;
  final bool isFavorit;
  final VoidCallback? onToggleFavorit;
  final List<Ulasan> daftarUlasan;
  final ValueChanged<Ulasan>? onUlasanBaru;

  /// Tag Hero gambar ke detail; harus unik per tab (mis. 'cari-kos-1').
  final String? heroTag;

  void _bukaDetail(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HalamanDetailKos(
          kos: kos,
          kirimUlasan: kirimUlasan,
          ulasanAwal: daftarUlasan.where((u) => u.kosId == kos.id).toList(),
          onUlasanBaru: onUlasanBaru,
          isFavorit: isFavorit,
          onToggleFavorit: onToggleFavorit,
          heroTag: heroTag,
        ),
      ),
    );
  }

  Widget _bungkusHero(Widget gambar) =>
      heroTag == null ? gambar : Hero(tag: heroTag!, child: gambar);

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final warna = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _bukaDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian gambar dengan Stack (gambar, badge tipe, icon hati)
              Stack(
                children: [
                  _bungkusHero(
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 100,
                        height: 100,
                        color: warna.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.apartment,
                          size: 40,
                          color: warna.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: warna.surface.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        kos.tipe,
                        style: teks.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Bagian detail kos dengan Column dan Row + Expanded
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            kos.nama,
                            style: teks.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          tooltip:
                              isFavorit ? 'Hapus favorit' : 'Tambah favorit',
                          icon: Icon(
                            isFavorit ? Icons.favorite : Icons.favorite_border,
                            color: isFavorit ? warna.error : null,
                            size: 20,
                          ),
                          onPressed: onToggleFavorit,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: warna.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            kos.area,
                            style: teks.bodySmall?.copyWith(
                              color: warna.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.directions_walk,
                          size: 14,
                          color: warna.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${kos.jarakKm.toString().replaceAll('.', ',')} km',
                          style: teks.bodySmall?.copyWith(color: warna.primary),
                        ),
                        if (kos.kamarMandiDalam) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• KM Dalam',
                            style: teks.bodySmall?.copyWith(
                              color: warna.secondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatRupiah(kos.hargaBulanan),
                      style: teks.titleSmall?.copyWith(
                        color: warna.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
