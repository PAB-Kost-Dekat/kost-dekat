import 'package:flutter/material.dart';

import '../model/kos.dart';
import '../utils/format_rupiah.dart';
import '../widget/kartu_kos.dart';

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

        if (data.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Belum ada kos yang terdaftar.',
                    style: teks.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Data kos dari server masih kosong. Muat ulang setelah data ditambahkan.',
                    style: teks.bodyMedium?.copyWith(
                      color: warna.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: onMuatUlang,
                    child: const Text('Muat ulang'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          key: const PageStorageKey<String>('list_tab_cari'),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final kos = data[index];
            final isFav = idFavorit.contains(kos.id);
            return KartuKos(
              kos: kos,
              isFavorit: isFav,
              onToggleFavorit: () => onToggleFavorit?.call(kos.id),
            );
          },
        );
      },
    );
  }
}
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.apartment),
                title: Text(kos.nama),
                isThreeLine: true,
                subtitle: Text.rich(
                  TextSpan(
                    text: '${kos.area}, ${kos.tipe}\n',
                    children: [
                      // Harga di baris sendiri karena itu yang dibandingkan pertama.
                      TextSpan(
                        text: CurrencyUtils.formatRupiah(kos.hargaBulanan),
                        style: teks.titleSmall?.copyWith(color: warna.primary),
                      ),
                    ],
                  ),
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
