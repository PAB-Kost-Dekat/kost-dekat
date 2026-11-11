import 'package:flutter/material.dart';

import '../model/kos.dart';
import '../widget/kartu_kos.dart';
import '../widgets/area_chip_list.dart';
import '../widgets/kategori_segmented_button.dart';
import '../widgets/sort_selector.dart';

/// Saring [semua] menurut tipe dan area, lalu urutkan. Tidak mengubah [semua].
List<Kos> saringKos(
  List<Kos> semua, {
  TipeKosFilter tipe = TipeKosFilter.semua,
  String? area,
  SortOption urutan = SortOption.jarakTerdekat,
}) {
  final hasil = semua.where((k) {
    final cocokTipe =
        tipe == TipeKosFilter.semua || k.tipe.toLowerCase() == tipe.name;
    return cocokTipe && (area == null || k.area == area);
  }).toList();
  switch (urutan) {
    case SortOption.jarakTerdekat:
      hasil.sort((a, b) => a.jarakKm.compareTo(b.jarakKm));
    case SortOption.hargaAsc:
      hasil.sort((a, b) => a.hargaBulanan.compareTo(b.hargaBulanan));
    case SortOption.hargaDesc:
      hasil.sort((a, b) => b.hargaBulanan.compareTo(a.hargaBulanan));
  }
  return hasil;
}

/// Tab Cari: daftar kos dari server dengan filter tipe (SegmentedButton),
/// chip area, dan urutan harga/jarak (SCRUM-22, 23, 24, 26).
class TabCari extends StatefulWidget {
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
  State<TabCari> createState() => _TabCariState();
}

class _TabCariState extends State<TabCari> {
  TipeKosFilter _tipe = TipeKosFilter.semua;
  String? _area;
  SortOption _urutan = SortOption.jarakTerdekat;

  void _resetFilter() => setState(() {
        _tipe = TipeKosFilter.semua;
        _area = null;
      });

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final warna = Theme.of(context).colorScheme;

    return FutureBuilder<List<Kos>>(
      future: widget.futureKos,
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
                    onPressed: widget.onMuatUlang,
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
                    onPressed: widget.onMuatUlang,
                    child: const Text('Muat ulang'),
                  ),
                ],
              ),
            ),
          );
        }

        final areas = data.map((k) => k.area).toSet().toList()..sort();
        final hasil = saringKos(
          data,
          tipe: _tipe,
          area: _area,
          urutan: _urutan,
        );

        // Filter ikut di dalam list agar ikut tergulir dan posisi gulir tetap.
        return ListView.builder(
          key: const PageStorageKey<String>('list_tab_cari'),
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          itemCount: 1 + (hasil.isEmpty ? 1 : hasil.length),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  KategoriSegmentedButton(
                    selectedFilter: _tipe,
                    onSelectionChanged: (t) => setState(() => _tipe = t),
                  ),
                  AreaChipList(
                    areas: areas,
                    selectedArea: _area,
                    onAreaSelected: (a) => setState(() => _area = a),
                  ),
                  SortSelector(
                    currentSort: _urutan,
                    onSortChanged: (u) => setState(
                      () => _urutan = u ?? SortOption.jarakTerdekat,
                    ),
                  ),
                ],
              );
            }

            if (hasil.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      'Tidak ada kos yang cocok dengan filter ini.',
                      style: teks.bodyMedium?.copyWith(
                        color: warna.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _resetFilter,
                      child: const Text('Tampilkan semua kos'),
                    ),
                  ],
                ),
              );
            }

            final kos = hasil[index - 1];
            return KartuKos(
              kos: kos,
              isFavorit: widget.idFavorit.contains(kos.id),
              onToggleFavorit: () => widget.onToggleFavorit?.call(kos.id),
            );
          },
        );
      },
    );
  }
}
