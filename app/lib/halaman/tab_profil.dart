import 'package:flutter/material.dart';

import '../model/ulasan.dart';
import 'halaman_login.dart';

// shortcut: hanya identitas + Keluar; "Ulasan saya" dan switch mode gelap menyusul di SCRUM-32.
class TabProfil extends StatelessWidget {
  const TabProfil({
    super.key,
    required this.namaPengguna,
    required this.emailPengguna,
    this.daftarUlasan = const [],
  });

  final String namaPengguna;
  final String emailPengguna;
  final List<Ulasan> daftarUlasan;

  String get _inisial => namaPengguna
      .trim()
      .split(RegExp(r'\s+'))
      .where((kata) => kata.isNotEmpty)
      .take(2)
      .map((kata) => kata[0].toUpperCase())
      .join();

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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: warna.primaryContainer,
              child: Text(
                _inisial,
                style: teks.titleLarge?.copyWith(
                  color: warna.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(namaPengguna, style: teks.titleLarge),
                  if (emailPengguna.isNotEmpty)
                    Text(
                      emailPengguna,
                      style: teks.bodyMedium?.copyWith(
                        color: warna.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _konfirmasiKeluar(context),
            icon: const Icon(Icons.logout),
            label: const Text('Keluar'),
          ),
        ),
      ],
    );
  }
}
