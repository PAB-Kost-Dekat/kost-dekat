import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kosdekat/halaman/halaman_detail_kos.dart';
import 'package:kosdekat/model/kos.dart';
import 'package:kosdekat/model/ulasan.dart';
import 'package:kosdekat/tema/tema_kosdekat.dart';
import 'package:kosdekat/widget/kartu_kos.dart';

void main() {
  final kosContoh = Kos(
    id: 'kos-1',
    nama: 'Kos Melati Indah',
    area: 'Sukapura',
    tipe: 'Putri',
    hargaBulanan: 1250000,
    kamarMandiDalam: true,
    jarakKm: 0.5,
    diperbarui: DateTime.now().subtract(const Duration(days: 3)),
  );

  Widget bungkusTema(Widget child) {
    return MaterialApp(
      theme: temaTerang,
      home: child,
    );
  }

  testWidgets(
    'HalamanDetailKos menerima objek Kos via konstruktor dan menampilkan seluruh field serta inovasi',
    (tester) async {
      final ulasanAwal = [
        Ulasan(
          kosId: 'kos-1',
          namaKos: 'Siti Aminah',
          rating: 5,
          komentar: 'Tempatnya sangat bersih dan nyaman!',
          tanggal: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      await tester.pumpWidget(
        bungkusTema(
          HalamanDetailKos(
            kos: kosContoh,
            ulasanAwal: ulasanAwal,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Nama Kos
      expect(find.text('Kos Melati Indah'), findsWidgets);

      // 2. Harga Format Rupiah
      expect(find.text('Rp1.250.000/bln'), findsOneWidget);

      // 3. Tipe Kos
      expect(find.text('Putri'), findsOneWidget);

      // 4. Area
      expect(find.text('Sukapura'), findsOneWidget);

      // 5. Fasilitas Kamar Mandi Dalam
      expect(find.text('Kamar Mandi Dalam (Ya)'), findsOneWidget);

      // 6. Jarak & Inovasi menit jalan kaki (0.5 * 12 = 6 menit)
      expect(find.textContaining('0,5 km dari kampus'), findsOneWidget);
      expect(find.textContaining('±6 menit jalan kaki'), findsOneWidget);

      // 7. Inovasi pembaruan ("Diperbarui 3 hari lalu")
      expect(find.text('Diperbarui 3 hari lalu'), findsOneWidget);

      // 8. ID Kos
      expect(find.text('ID: kos-1'), findsOneWidget);

      // Ulasan & Rata-rata bintang
      expect(find.text('Ulasan (1)'), findsOneWidget);
      expect(find.text('5.0'), findsOneWidget);
      expect(find.text('Siti Aminah'), findsOneWidget);
      expect(find.text('Tempatnya sangat bersih dan nyaman!'), findsOneWidget);

      // Tombol Tulis Ulasan
      expect(find.text('Tulis Ulasan'), findsOneWidget);

      // Tombol Favorit di AppBar
      expect(find.byTooltip('Tambah favorit'), findsOneWidget);
    },
  );

  testWidgets(
    'Dapat kembali ke halaman sebelumnya dengan tombol back',
    (tester) async {
      await tester.pumpWidget(
        bungkusTema(
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HalamanDetailKos(kos: kosContoh),
                      ),
                    );
                  },
                  child: const Text('Buka Detail'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Buka detail
      await tester.tap(find.text('Buka Detail'));
      await tester.pumpAndSettle();
      expect(find.text('Kos Melati Indah'), findsWidgets);

      // Tekan tombol back di AppBar
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Kembali ke halaman awal
      expect(find.text('Buka Detail'), findsOneWidget);
    },
  );

  testWidgets(
    'KartuKos membuka HalamanDetailKos saat diketuk via Navigator.push',
    (tester) async {
      await tester.pumpWidget(
        bungkusTema(
          Scaffold(
            body: KartuKos(kos: kosContoh),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ketuk kartu kos
      await tester.tap(find.byType(KartuKos));
      await tester.pumpAndSettle();

      // Halaman detail terbuka dengan data kos
      expect(find.byType(HalamanDetailKos), findsOneWidget);
      expect(find.text('Kos Melati Indah'), findsWidgets);
      expect(find.text('Rp1.250.000/bln'), findsOneWidget);
    },
  );

  testWidgets(
    'Toggle favorit di AppBar memicu callback dan mengubah ikon',
    (tester) async {
      var favoritAktif = false;

      await tester.pumpWidget(
        bungkusTema(
          HalamanDetailKos(
            kos: kosContoh,
            isFavorit: false,
            onToggleFavorit: () {
              favoritAktif = !favoritAktif;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Tambah favorit'), findsOneWidget);

      // Ketuk tombol favorit
      await tester.tap(find.byTooltip('Tambah favorit'));
      await tester.pumpAndSettle();

      expect(favoritAktif, isTrue);
      expect(find.byTooltip('Hapus favorit'), findsOneWidget);
    },
  );

  testWidgets(
    'Menulis ulasan baru menambahkan ulasan ke state lokal seketika',
    (tester) async {
      Ulasan? ulasanDiterima;

      await tester.pumpWidget(
        bungkusTema(
          HalamanDetailKos(
            kos: kosContoh,
            onUlasanBaru: (u) => ulasanDiterima = u,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ulasan (0)'), findsOneWidget);
      expect(
        find.textContaining('Belum ada ulasan untuk kos ini'),
        findsOneWidget,
      );

      // Ketuk tombol Tulis Ulasan
      await tester.tap(find.text('Tulis Ulasan'));
      await tester.pumpAndSettle();

      // Masuk ke form ulasan
      expect(find.text('Rating'), findsOneWidget);

      // Isi komentar
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Komentar ulasan'),
        'Kosnya sangat rekomendasi untuk mahasiswa baru.',
      );
      await tester.pump();

      // Kirim ulasan
      await tester.tap(find.widgetWithText(FilledButton, 'Kirim Ulasan'));
      await tester.pumpAndSettle();

      // Form ditutup, ulasan baru langsung tampil di state lokal detail kos
      expect(find.text('Ulasan tersimpan'), findsOneWidget);
      expect(find.text('Ulasan (1)'), findsOneWidget);
      expect(
        find.text('Kosnya sangat rekomendasi untuk mahasiswa baru.'),
        findsOneWidget,
      );
      expect(ulasanDiterima, isNotNull);
      expect(ulasanDiterima?.komentar, 'Kosnya sangat rekomendasi untuk mahasiswa baru.');
    },
  );
}

