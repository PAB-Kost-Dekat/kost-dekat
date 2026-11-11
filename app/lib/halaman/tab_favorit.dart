import 'package:flutter/material.dart';

import '../model/kos.dart';
import '../model/ulasan.dart';
import '../widget/kartu_kos.dart';

/// Tab Favorit yang menampilkan daftar kos yang telah ditandai pengguna.
/// Bagian dari SCRUM-31 (A4) yang mengonsumsi state bersama dari HalamanUtama.
class TabFavorit extends StatelessWidget {
  const TabFavorit({
    super.key,
    required this.futureKos,
    required this.idFavorit,
    this.daftarUlasan = const [],
    this.onUlasanBaru,
    this.onToggleFavorit,
    this.daftarUlasan = const [],
    this.onUlasanBaru,
    this.kirimUlasan,
  });

  final Future<List<Kos>> futureKos;
  final Set<String> idFavorit;
  final List<Ulasan> daftarUlasan;
  final ValueChanged<Ulasan>? onUlasanBaru;
  final void Function(String id)? onToggleFavorit;
  final List<Ulasan> daftarUlasan;
  final ValueChanged<Ulasan>? onUlasanBaru;
  final Future<void> Function(Ulasan ulasan)? kirimUlasan;

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final warna = Theme.of(context).colorScheme;

    if (idFavorit.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Favorit', style: teks.headlineMedium),
            const SizedBox(height: 16),
            Image.asset(
              'assets/kos_illustration.png',
              height: 160,
              excludeFromSemantics: true,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada kos favorit yang ditandai.',
              style: teks.bodyMedium?.copyWith(color: warna.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<Kos>>(
      future: futureKos,
      builder: (context, snapshot) {
        final listKos = (snapshot.data ?? [])
            .where((k) => idFavorit.contains(k.id))
            .toList();

        return ListView(
          key: const PageStorageKey<String>('list_tab_favorit'),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          children: [
            Text('Favorit', style: teks.headlineMedium),
            const SizedBox(height: 16),
            if (listKos.isEmpty)
              Text(
                'Ada ${idFavorit.length} favorit ditandai.',
                style: teks.bodyMedium?.copyWith(color: warna.onSurfaceVariant),
              )
            else
              ...listKos.map(
                (kos) => KartuKos(
                  kos: kos,
                  daftarUlasan: daftarUlasan,
                  onUlasanBaru: onUlasanBaru,
                  kirimUlasan: kirimUlasan,
                  isFavorit: true,
                  onToggleFavorit: () => onToggleFavorit?.call(kos.id),
                  heroTag: 'favorit-${kos.id}',
                ),
              ),
          ],
        );
      },
    );
  }
}
