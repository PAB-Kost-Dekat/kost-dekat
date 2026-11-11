import 'package:flutter/material.dart';

import '../model/kos.dart';
import '../utils/format_rupiah.dart';

class DetailKosPage extends StatelessWidget {
  final Kos kos;

  const DetailKosPage({super.key, required this.kos});

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(kos.nama)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'kos-img-${kos.id}',
              child: Image.asset(
                'assets/kos_illustration.png',
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kos.nama,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kos.area,
                    style: TextStyle(
                      fontSize: 16,
                      color: warna.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    CurrencyUtils.formatRupiah(kos.hargaBulanan),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: warna.primary,
                    ),
                  ),
                  const Divider(height: 24),
                  Text(
                    'Tipe Kos: ${kos.tipe}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kamar Mandi Dalam: ${kos.kamarMandiDalam ? "Ya" : "Tidak"}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Jarak: ${kos.jarakKm} km',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Diperbarui: ${kos.diperbarui.toLocal().toString().split(".")[0]}',
                    style: TextStyle(
                      fontSize: 12,
                      color: warna.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
