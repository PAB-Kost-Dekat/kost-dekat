import 'package:flutter/material.dart';

import '../model/kos.dart';

/// Tab Cari yang menampilkan daftar kos dan keadaan memuat/gagal/berhasil.
/// Kerangka ini menjadi fondasi bagi A3 untuk melengkapi filter & fitur khas (SCRUM-22).
class TabCari extends StatelessWidget {
  const TabCari({
    super.key,
    required this.futureKos,
    required this.idFavorit,
    this.onToggleFavorit,
    this.onMuatUlang,
  });

  final Future<List<Kos>> futureKos;
  final Set<String> idFavorit;
  final void Function(String id)? onToggleFavorit;
  final VoidCallback? onMuatUlang;

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final warna = Theme.of(context).colorScheme;

    return FutureBuilder<List<Kos>>(
      future: futureKos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 48, color: warna.error),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat data kos.',
                    style: teks.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: onMuatUlang,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data ?? [];

        return ListView.builder(
          key: const PageStorageKey<String>('list_tab_cari'),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          itemCount: data.isEmpty ? 20 : data.length,
          itemBuilder: (context, index) {
            if (data.isEmpty) {
              // Daftar scrollable placeholder untuk menjaga posisi scroll sebelum SCRUM-22 di-merge
              final idItem = 'placeholder-$index';
              final isFav = idFavorit.contains(idItem);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: Text('Kos Sekitar Kampus ${index + 1}'),
                  subtitle: const Text('Daftar kos siap dipasang (SCRUM-22)'),
                  trailing: IconButton(
                    tooltip: isFav ? 'Hapus favorit' : 'Tambah favorit',
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? warna.error : null,
                    ),
                    onPressed: () => onToggleFavorit?.call(idItem),
                  ),
                ),
              );
            }

            final kos = data[index];
            final isFav = idFavorit.contains(kos.id);
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.apartment),
                title: Text(kos.nama),
                subtitle: Text(
                  '${kos.area} • ${kos.tipe} • Rp${kos.hargaBulanan}/bln',
                ),
                trailing: IconButton(
                  tooltip: isFav ? 'Hapus favorit' : 'Tambah favorit',
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? warna.error : null,
                  ),
                  onPressed: () => onToggleFavorit?.call(kos.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

