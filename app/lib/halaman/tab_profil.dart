import 'package:flutter/material.dart';

import '../model/ulasan.dart';
import '../tema/tema_kosdekat.dart';
import 'halaman_login.dart';

/// Tab ketiga: Profil pengguna, ringkasan, dan daftar "Ulasan Saya" (SCRUM-32).
/// Merupakan StatelessWidget (P03) yang menerima data dari HalamanUtama.
class TabProfil extends StatelessWidget {
  const TabProfil({
    super.key,
    required this.namaPengguna,
    required this.emailPengguna,
    this.daftarUlasan = const [],
    this.jumlahFavorit = 0,
  });

  final String namaPengguna;
  final String emailPengguna;
  final List<Ulasan> daftarUlasan;
  final int jumlahFavorit;

  String get _inisial => namaPengguna
      .trim()
      .split(RegExp(r'\s+'))
      .where((kata) => kata.isNotEmpty)
      .take(2)
      .map((kata) => kata[0].toUpperCase())
      .join();

  String _formatTanggal(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year.toString();
    return '$d/$m/$y';
  }

  Future<void> _konfirmasiKeluar(BuildContext context) async {
    final keluar = await showDialog<bool>(
      context: context,
      builder: (konteksDialog) => AlertDialog(
        title: const Text('Keluar dari KosDekat?'),
        content: const Text('Favorit dan ulasan di perangkat ini akan hilang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(konteksDialog, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(konteksDialog, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (keluar != true || !context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HalamanLogin()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final warna = Theme.of(context).colorScheme;
    final warnaBintang =
        Theme.of(context).extension<WarnaKosDekat>()?.bintang ?? warna.primary;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      children: [
        // Bagian atas: Avatar dan Identitas
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: warna.primaryContainer,
              child: Text(
                _inisial,
                style: teks.titleLarge?.copyWith(
                  color: warna.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    namaPengguna,
                    style:
                        teks.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (emailPengguna.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      emailPengguna,
                      style: teks.bodyMedium?.copyWith(
                        color: warna.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tombol Keluar (diletakkan di atas agar mudah diakses dan langsung terlihat)
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _konfirmasiKeluar(context),
            icon: const Icon(Icons.logout),
            label: const Text('Keluar'),
          ),
        ),
        const SizedBox(height: 16),

        // Ringkasan: Jumlah Favorit dan Jumlah Ulasan
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$jumlahFavorit',
                        style: teks.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: warna.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Favorit',
                        style: teks.bodyMedium?.copyWith(
                          color: warna.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${daftarUlasan.length}',
                        style: teks.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: warna.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ulasan',
                        style: teks.bodyMedium?.copyWith(
                          color: warna.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Bagian "Ulasan Saya"
        Row(
          children: [
            Icon(Icons.rate_review_outlined, color: warna.primary),
            const SizedBox(width: 8),
            Text(
              'Ulasan Saya (${daftarUlasan.length})',
              style: teks.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (daftarUlasan.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            child: Center(
              child: Text(
                'Belum ada ulasan. Buka detail kos lalu tulis ulasan.',
                style: teks.bodyMedium?.copyWith(
                  color: warna.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daftarUlasan.length,
            itemBuilder: (context, index) {
              final ulasan = daftarUlasan[index];
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
                          Expanded(
                            child: Text(
                              ulasan.namaKos,
                              style: teks.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTanggal(ulasan.tanggal),
                            style: teks.bodySmall?.copyWith(
                              color: warna.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < ulasan.rating ? Icons.star : Icons.star_border,
                            color: warnaBintang,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(ulasan.komentar, style: teks.bodyMedium),
                    ],
                  ),
                ),
              );
            },
          ),

        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),

        // Pengaturan mode tema (darkTheme)
        ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, currentMode, _) {
            final isDark = currentMode == ThemeMode.dark ||
                (currentMode == ThemeMode.system &&
                    MediaQuery.platformBrightnessOf(context) ==
                        Brightness.dark);
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: warna.primary,
              ),
              title: const Text('Mode gelap'),
              subtitle: Text(
                currentMode == ThemeMode.system
                    ? 'Mengikuti sistem (${isDark ? "Gelap" : "Terang"})'
                    : (isDark ? 'Mode gelap aktif' : 'Mode terang aktif'),
              ),
              value: isDark,
              onChanged: (val) {
                themeModeNotifier.value =
                    val ? ThemeMode.dark : ThemeMode.light;
              },
            );
          },
        ),

        // Informasi tentang aplikasi
        const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.info_outline),
          title: Text('Tentang aplikasi'),
          subtitle: Text('Kelompok 06 · Proyek UTS PAB'),
        ),
      ],
    );
  }
}
