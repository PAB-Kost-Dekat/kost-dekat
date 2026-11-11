import 'package:flutter/material.dart';

import '../model/kos.dart';
import '../widgets/kartu_kost.dart';
import '../widgets/kategori_segmented_button.dart';
import '../widgets/area_chip_list.dart';
import '../widgets/sort_selector.dart';
import 'detail_kos_page.dart';

class TabCariPage extends StatefulWidget {
  const TabCariPage({super.key});

  @override
  State<TabCariPage> createState() => _TabCariPageState();
}

class _TabCariPageState extends State<TabCariPage> {
  late Future<List<Kos>> _futureKos;
  TipeKosFilter _selectedFilter = TipeKosFilter.semua;
  String? _selectedArea;
  SortOption _currentSort = SortOption.jarakTerdekat;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _futureKos = _getKosFromApi();
    });
  }

  Future<List<Kos>> _getKosFromApi() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Kos(
        id: '1',
        nama: 'Kos Melati Indah',
        area: 'Setiabudi',
        tipe: 'Putri',
        hargaBulanan: 1250000,
        kamarMandiDalam: true,
        jarakKm: 0.5,
        diperbarui: DateTime.now(),
      ),
      Kos(
        id: '2',
        nama: 'Pondok Asri',
        area: 'Dayeuhkolot',
        tipe: 'Putra',
        hargaBulanan: 900000,
        kamarMandiDalam: false,
        jarakKm: 1.2,
        diperbarui: DateTime.now(),
      ),
      Kos(
        id: '3',
        nama: 'Griya Mahasiswa',
        area: 'Telekomunikasi',
        tipe: 'Campur',
        hargaBulanan: 1500000,
        kamarMandiDalam: true,
        jarakKm: 0.3,
        diperbarui: DateTime.now(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari Kost Terdekat')),
      body: Column(
        children: [
          KategoriSegmentedButton(
            selectedFilter: _selectedFilter,
            onSelectionChanged: (filter) =>
                setState(() => _selectedFilter = filter),
          ),
          AreaChipList(
            areas: const ['Setiabudi', 'Dayeuhkolot', 'Telekomunikasi'],
            selectedArea: _selectedArea,
            onAreaSelected: (area) => setState(() => _selectedArea = area),
          ),
          SortSelector(
            currentSort: _currentSort,
            onSortChanged: (sort) =>
                setState(() => _currentSort = sort ?? SortOption.jarakTerdekat),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<Kos>>(
              future: _futureKos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Gagal memuat data kost.'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _fetchData,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }
                final listKos = snapshot.data ?? [];
                if (listKos.isEmpty) {
                  return const Center(child: Text('Tidak ada kos ditemukan.'));
                }

                return ListView.builder(
                  itemCount: listKos.length,
                  itemBuilder: (context, index) {
                    final kos = listKos[index];
                    return KartuKost(
                      kos: kos,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailKosPage(kos: kos),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
