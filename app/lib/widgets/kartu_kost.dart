import 'package:flutter/material.dart';

import '../model/kos.dart';
import '../utils/format_rupiah.dart';

class KartuKost extends StatelessWidget {
  final Kos kos;
  final VoidCallback onTap;

  const KartuKost({super.key, required this.kos, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final warna = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    // Tag harus sama dengan Hero di DetailKosPage.
                    Hero(
                      tag: 'kos-img-${kos.id}',
                      // shortcut: ilustrasi yang sama untuk semua kos, ganti dengan foto asli tiap kos bila ada.
                      child: Image.asset(
                        'assets/kos_illustration.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        excludeFromSemantics: true,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: warna.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          kos.tipe,
                          style: teks.labelSmall?.copyWith(
                            color: warna.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kos.nama,
                      style: teks.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: warna.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            kos.area,
                            style: teks.bodySmall?.copyWith(
                              color: warna.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.directions_walk,
                          size: 14,
                          color: warna.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text('${kos.jarakKm} km', style: teks.bodySmall),
                        if (kos.kamarMandiDalam) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.shower_outlined,
                            size: 14,
                            color: warna.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text('KM dalam', style: teks.bodySmall),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyUtils.formatRupiah(kos.hargaBulanan),
                      style: teks.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: warna.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
