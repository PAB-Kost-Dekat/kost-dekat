import 'package:flutter/material.dart';

import '../model/kos.dart';
import '../widget/kartu_kos.dart';

/// Tab Favorit yang menampilkan daftar kos yang telah ditandai pengguna.
/// Bagian dari SCRUM-31 (A4) yang mengonsumsi state bersama dari HalamanUtama.
class TabFavorit extends StatelessWidget {
  const TabFavorit({
    super.key,
    required this.futureKos,
    required this.idFavorit,
    this.onToggleFavorit,
  });

  final Future<List<Kos>> futureKos;
  final Set<String> idFavorit;
  final void Function(String id)? onToggleFavorit;

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
            const SizedBox(height: 8),
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
                  isFavorit: true,
                  onToggleFavorit: () => onToggleFavorit?.call(kos.id),
                (kos) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.favorite),
                    title: Text(kos.nama),
                    subtitle: Text('${kos.area} • ${kos.tipe}'),
                    trailing: IconButton(
                      tooltip: 'Hapus favorit',
                      icon: Icon(Icons.favorite, color: warna.error),
                      onPressed: () => onToggleFavorit?.call(kos.id),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
