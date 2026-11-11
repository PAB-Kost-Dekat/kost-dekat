import 'package:flutter/material.dart';

import '../model/kos.dart';
import '../model/ulasan.dart';
import '../service/kos_service.dart';
import 'tab_cari.dart';
import 'tab_favorit.dart';
import 'tab_profil.dart';

/// Pemilik state bersama: tab aktif, Future kos, id favorit, dan daftar ulasan.
/// Menggunakan NavigationBar + IndexedStack agar posisi scroll dan state tiap tab tetap terjaga.
class HalamanUtama extends StatefulWidget {
  const HalamanUtama({
    super.key,
    this.kosService,
    this.namaPengguna = 'Mahasiswa Tel-U',
    this.emailPengguna = '',
  });

  final KosService? kosService;
  final String namaPengguna;
  final String emailPengguna;

  @override
  State<HalamanUtama> createState() => HalamanUtamaState();
}

class HalamanUtamaState extends State<HalamanUtama> {
  late final KosService _service;
  int _indexTab = 0;
  late Future<List<Kos>> _futureKos;
  final Set<String> _idFavorit = <String>{};
  final List<Ulasan> _daftarUlasan = <Ulasan>[];

  int get indexTab => _indexTab;
  Future<List<Kos>> get futureKos => _futureKos;
  Set<String> get idFavorit => _idFavorit;
  List<Ulasan> get daftarUlasan => _daftarUlasan;

  @override
  void initState() {
    super.initState();
    _service = widget.kosService ?? KosService();
    _futureKos = _service.ambilDaftarKos();
  }

  void toggleFavorit(String id) {
    final ditambah = !_idFavorit.contains(id);
    setState(() {
      if (ditambah) {
        _idFavorit.add(id);
      } else {
        _idFavorit.remove(id);
      }
    });
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            ditambah ? 'Ditambahkan ke Favorit' : 'Dihapus dari Favorit',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void tambahUlasan(Ulasan u) {
    setState(() {
      _daftarUlasan.add(u);
    });
  }

  /// Selesai saat data baru selesai dimuat (dipakai pull-to-refresh).
  Future<void> muatUlang() {
    setState(() {
      _futureKos = _service.ambilDaftarKos();
    });
    return _futureKos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _indexTab,
          children: [
            TabCari(
              futureKos: _futureKos,
              idFavorit: _idFavorit,
              daftarUlasan: _daftarUlasan,
              onUlasanBaru: tambahUlasan,
              onToggleFavorit: toggleFavorit,
              onMuatUlang: muatUlang,
            ),
            TabFavorit(
              futureKos: _futureKos,
              idFavorit: _idFavorit,
              daftarUlasan: _daftarUlasan,
              onUlasanBaru: tambahUlasan,
              onToggleFavorit: toggleFavorit,
            ),
            TabProfil(
              namaPengguna: widget.namaPengguna,
              emailPengguna: widget.emailPengguna,
              daftarUlasan: _daftarUlasan,
              jumlahFavorit: _idFavorit.length,
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexTab,
        onDestinationSelected: (i) => setState(() => _indexTab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.search), label: 'Cari'),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
