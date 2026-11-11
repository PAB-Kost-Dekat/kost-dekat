# KosDekat — Info Kos Sekitar Telkom University

Aplikasi Flutter untuk membantu mahasiswa menemukan kos di sekitar Telkom University: Sukapura, Sukabirus, Bojongsoang, Cikoneng, Dayeuhkolot, dan area sekitar.

## Identitas kelompok
- Nama kelompok: **Kelompok 06**
- Tema: **KosDekat — pencarian kos sekitar Telkom University** (Proyek 5)
- Anggota:
  | Nama | NIM | Tugas |
  |---|---|---|
  | Arthur Budi Maharesi (ketua) | [NIM] | A1: server API shelf (`/kos`, `/kos/<id>`, `/area`), model `Kos`, ikon launcher & aset, halaman login, integrasi `main`, pull-to-refresh, Hero, kirim ulasan ke server |
  | Rezka Dwi Anggoro | [NIM] | A2: model `Ulasan`, `KosService` + `API_URL`, test MockClient, widget test, `flutter analyze` & `flutter test` |
  | Muhammad Althaf Arrajab | [NIM] | A3: kartu kos, tab Cari (FutureBuilder 3 keadaan), SegmentedButton tipe, urutan harga/jarak, chip area, format Rupiah |
  | Bahaa Azzikra Azhar Arma | [NIM] | A4: NavigationBar + IndexedStack, halaman detail, form ulasan, Navigator.pop + mounted + SnackBar, tab Favorit, tab Profil |
  | Muhammad Rasyadan Agung Sedayu | [NIM] | A5: tema `ColorScheme.fromSeed` + mode gelap, font Plus Jakarta Sans, audit warna, `POST /ulasan` di server, dokumentasi |

## Struktur repository
```text
KosDekat/
├── app/
│   ├── lib/
│   ├── test/
│   ├── assets/
│   └── pubspec.yaml
├── server/
│   ├── bin/server.dart
│   ├── data/kos.json
│   └── pubspec.yaml
├── screenshots/
└── README.md
```

## Persiapan
- Flutter SDK dan Android Studio / Android SDK.
- Dart SDK (mengikuti versi Flutter).
- Perangkat Android atau emulator.
- Aktifkan USB debugging jika menggunakan HP fisik.

## Cara menjalankan server API
Buka terminal pertama dari folder repository:

```bash
cd server
dart pub get
dart run bin/server.dart
```

Server berjalan pada port `8080`. Endpoint:
| Method | Endpoint | Fungsi |
|---|---|---|
| GET | `/kos` | Mengambil seluruh daftar kos (12 data awal) |
| GET | `/kos/<id>` | Mengambil detail kos berdasarkan ID |
| GET | `/area` | Daftar area dan harga rata-rata kos |
| GET | `/health` | Pemeriksaan status server |

Contoh akses endpoint:
- `http://localhost:8080/kos`
- `http://localhost:8080/kos/k01`
- `http://localhost:8080/area`

## Cara menjalankan aplikasi Flutter
Buka terminal kedua:

```bash
cd app
flutter create --platforms=android --org id.ac.telkomuniversity .
flutter pub get
dart run flutter_launcher_icons
flutter run --dart-define=API_URL=http://10.0.2.2:8080
```

`10.0.2.2` adalah alamat khusus emulator Android untuk mengakses `localhost` komputer. Jika memakai HP fisik, ganti alamat tersebut dengan IP lokal komputer yang menjalankan server, misalnya:

```bash
flutter run --dart-define=API_URL=http://192.168.1.10:8080
```

Pastikan HP dan komputer berada pada jaringan Wi-Fi yang sama. Setelah `flutter create`, pastikan file `android/app/src/main/AndroidManifest.xml` memuat permission berikut tepat di bawah tag `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## Pengujian dan analisis
Jalankan dari folder `app`:

```bash
flutter analyze
flutter test
```

Target pemeriksaan: tidak ada error/warning dari `flutter analyze` dan seluruh test lulus. Jalankan juga pada emulator atau perangkat Android.
---

## 8. Alur Kerja Tim

1. Ambil tiket di Jira, pindahkan ke **In Progress**.
2. Buat branch dari `main`: `feat/SCRUM-<nomor>-<ringkas>`, contoh `feat/SCRUM-15-endpoint-area`.
3. Commit diawali key Jira: `SCRUM-15 tambah endpoint GET /area`.
4. Sebelum PR: `dart format lib test`, `flutter analyze`, `flutter test`.
5. Buka Pull Request, isi template (termasuk baris File:baris untuk tabel README), minta 1 review.
6. Setelah merge, pindahkan tiket ke **Done**.

Detail lengkap ada di [CONTRIBUTING.md](CONTRIBUTING.md).

---

## 9. Tangkapan Layar

Diambil dari aplikasi yang berjalan di emulator/HP Android (bukan mockup). Minimal empat (P02): Cari, Detail, Form Ulasan, Favorit. Simpan di folder `screenshots/` dengan nama persis seperti di bawah.

| Cari | Detail | Form Ulasan | Favorit |
|------|--------|-------------|---------|
| ![Cari](screenshots/01_cari.png) | ![Detail](screenshots/02_detail.png) | ![Form](screenshots/03_form_ulasan.png) | ![Favorit](screenshots/04_favorit.png) |

| Profil | Gagal memuat | Mode gelap |
|--------|--------------|------------|
| ![Profil](screenshots/05_profil.png) | ![Gagal](screenshots/06_gagal.png) | ![Gelap](screenshots/07_gelap.png) |

---

## 10. Tabel Pemenuhan Fitur

> Path relatif terhadap `app/` kecuali diawali `server/` atau `screenshots/`. Nomor baris sesuai `main` setelah PR #47.

### 10.1 Fitur wajib (Bagian 3)

| Poin | File:baris | Keterangan |
|------|-----------|------------|
| P01–P02 Proyek dibuat dengan `flutter create --org id.ac.telkomuniversity`, paket bukan `com.example` | android/app/build.gradle.kts:19 | applicationId `id.ac.telkomuniversity.kosdekat` |
| P01–P02 Nama aplikasi di launcher sesuai tema (bukan `flutter_application_1`) | android/app/src/main/AndroidManifest.xml:3 | Label "KosDekat" |
| P01–P02 Berjalan di emulator/HP Android, ≥ 4 tangkapan layar dari perangkat | screenshots/ | Lihat bagian 9 |
| P01–P02 `flutter analyze` bersih (tanpa error maupun warning) | - | No issues found! |
| P03 StatelessWidget & StatefulWidget buatan sendiri, setState mengubah tampilan | lib/widget/kartu_kos.dart:11, lib/halaman/halaman_form_ulasan.dart:8, :80 | `KartuKos` (Stateless), `HalamanFormUlasan` (Stateful); mengetuk bintang memanggil `setState` dan jumlah bintang menyala berubah |
| P03 TextField + TextEditingController di-dispose | lib/halaman/halaman_form_ulasan.dart:24-32 | Controller nama pengulas & komentar di-dispose sebelum `super.dispose()` |
| P03 ≥ 2 jenis tombol Material 3 | lib/halaman/halaman_form_ulasan.dart:112, lib/widget/kartu_kos.dart:133, lib/halaman/halaman_detail_kos.dart:370 | FilledButton ("Kirim Ulasan"), IconButton (hati favorit), FloatingActionButton.extended ("Tulis Ulasan"); juga OutlinedButton "Keluar" di lib/halaman/tab_profil.dart:116 |
| P03 ChoiceChip / FilterChip / SegmentedButton | lib/halaman/tab_cari.dart:166, :170 | SegmentedButton tipe kos (lib/widgets/kategori_segmented_button.dart) dan ChoiceChip area (lib/widgets/area_chip_list.dart) menyaring daftar lewat `saringKos` |
| P03 SnackBar | lib/halaman/halaman_detail_kos.dart:78, :90, lib/halaman/halaman_utama.dart:58 | "Ulasan tersimpan", "Ulasan terkirim ke server" / "Gagal mengirim…", "Ditambahkan/Dihapus dari Favorit" |
| P04 Model ≥ 6 field (DateTime & bool) | lib/model/kos.dart:14-23 | 8 field, `diperbarui` DateTime, `kamarMandiDalam` bool |
| P04 Kartu buatan sendiri (Row, Column, Expanded, Stack) | lib/widget/kartu_kos.dart:72 (Row), :76 (Stack), :118 (Expanded), :119 (Column) | `KartuKos` |
| P04 ListView.builder | lib/halaman/tab_cari.dart:156 | Daftar kos |
| P04 NavigationBar ≥ 3 tab + IndexedStack | lib/halaman/halaman_utama.dart:86 (IndexedStack), :115 (NavigationBar) | Cari · Favorit · Profil |
| P05 Halaman detail menerima objek lewat konstruktor | lib/halaman/halaman_detail_kos.dart:11-14, lib/widget/kartu_kos.dart:41 | `HalamanDetailKos(kos: kos)` dibuka dengan `Navigator.push` |
| P05 Form tambah → `Navigator.pop(context, data)` → `await` → muncul di daftar | lib/halaman/halaman_form_ulasan.dart:48, lib/halaman/halaman_detail_kos.dart:59 | Ulasan langsung tampil di Detail dan di tab Profil |
| P05 Cek `mounted` setelah `await` | lib/halaman/halaman_detail_kos.dart:67, :89 | Setelah form ditutup dan setelah POST ke server |
| P05 ≥ 3 widget test di `test/`, `flutter test` lulus semua | test/navigator_pop_await_test.dart, test/halaman_form_ulasan_test.dart, test/tab_favorit_test.dart | 48 `testWidgets` di 23 file test; `flutter test`: 67 test lulus |
| P06 ColorScheme.fromSeed + darkTheme | lib/tema/tema_kosdekat.dart:28, :68, lib/main.dart:25 | Seed `#14695C` (lib/tema/tema_kosdekat.dart:5), tema terang & gelap; switch mode gelap di tab Profil |
| P06 Warna dari `Theme.of(context).colorScheme` (≤ 3 pengecualian) | lib/tema/tema_kosdekat.dart:33, lib/tema/tema_kosdekat.dart:72 | 2 pengecualian, keduanya warna bintang rating lewat `WarnaKosDekat`: amber gelap #B26A00 (terang, kontras ≥ 3:1) dan amber #FFC107 (gelap). Selain itu semua warna dari `colorScheme`; `Color(0xFF14695C)` di baris 5 adalah seed `ColorScheme.fromSeed` |
| P06 Font kustom | pubspec.yaml:11, :28, lib/tema/tema_kosdekat.dart:34 | Plus Jakarta Sans lewat `google_fonts`, file .ttf dibundel di assets/fonts/ agar tetap tampil tanpa internet |
| P06 Ikon launcher sendiri (flutter_launcher_icons) | pubspec.yaml:29-32 | assets/kosdekat_logo.png (512×512), hasil di android/app/src/main/res/mipmap-* |
| P06 Gambar aset lokal di pubspec.yaml | pubspec.yaml:24, :26 | assets/kos_illustration.png di keadaan kosong tab Favorit (lib/halaman/tab_favorit.dart:41); foto kos assets/images/kos_<id>.jpeg di halaman detail |
| P07 `server/` shelf + shelf_router, data ≥ 12 item JSON | server/bin/server.dart:5, :128 | server/data/kos.json: 12 item |
| P07 ≥ 3 endpoint GET | server/bin/server.dart:19, :22, :32 | `GET /kos`, `GET /kos/<id>` (404 bila tidak ada), `GET /area` |
| P07 http + dart-define | lib/service/kos_service.dart:3, :9 | `API_URL` dari `--dart-define` |
| P07 fromJson/toJson + konversi DateTime | lib/model/kos.dart:25, :34, :37, :45 | `DateTime.parse` dan `toIso8601String` (ISO 8601) |
| P07 FutureBuilder 3 keadaan + tombol Coba lagi | lib/halaman/tab_cari.dart:92, :114 | memuat / gagal / berhasil |
| P07 Minimal satu test memakai MockClient | test/kos_service_test.dart:33 | Menguji `KosService` tanpa server |

### 10.2 Fitur khas KosDekat (Bagian 5)

| Poin | File:baris | Keterangan |
|------|-----------|------------|
| Model `Kos` sesuai tema | lib/model/kos.dart:14-23 | id, nama, area, tipe, hargaBulanan, kamarMandiDalam, jarakKm, diperbarui |
| Tab Cari · Favorit · Profil | lib/halaman/halaman_utama.dart:86, :115 | NavigationBar 3 tab + IndexedStack |
| Form ulasan: nama kos, rating 1–5 bintang yang bisa diketuk, komentar | lib/halaman/halaman_form_ulasan.dart:73, :24-25 | Model `Ulasan` terpisah (lib/model/ulasan.dart) |
| SegmentedButton Putra/Putri/Campur | lib/halaman/tab_cari.dart:166 | Widget di lib/widgets/kategori_segmented_button.dart |
| Urutan berdasarkan harga atau jarak | lib/halaman/tab_cari.dart:175, :11 | Jarak terdekat / Harga terendah / Harga tertinggi, diuji di test/tab_cari_filter_test.dart |
| Harga format Rupiah "Rp1.250.000/bln" | lib/utils/format_rupiah.dart:2 | Diuji di test/format_rupiah_test.dart |
| Endpoint khas `GET /area` | server/bin/server.dart:32 | Jumlah kos dan harga rata-rata per area; dibaca lewat `KosService.ambilRingkasanArea` (lib/service/kos_service.dart:34) dan diuji di test/kos_service_test.dart:57. Chip area di tab Cari dibentuk dari data `/kos` |

### 10.3 Nilai tambah (Bagian 7)

| Poin | File:baris | Keterangan |
|------|-----------|------------|
| POST ulasan ke server (+5) | server/bin/server.dart:50 + lib/service/kos_service.dart:41 + lib/halaman/halaman_detail_kos.dart:85 | Dikerjakan. Server memvalidasi kosId, rating 1–5, komentar (400 bila tidak valid, 201 bila berhasil). Aplikasi tetap menyimpan ulasan lokal lalu mengirim POST; SnackBar "Ulasan terkirim ke server" atau "Gagal mengirim, ulasan disimpan di perangkat" tanpa crash. Diuji di test/kirim_ulasan_test.dart |
| Pull-to-refresh (+2) | lib/halaman/tab_cari.dart:154 (daftar), :78 (keadaan kosong/gagal) | Dikerjakan. Tarik ke bawah memanggil `muatUlang()` di HalamanUtama; indikator berhenti saat data selesai dimuat; keadaan gagal juga bisa ditarik. Diuji di test/pull_to_refresh_test.dart |
| Hero kartu → detail (+3) | lib/widget/kartu_kos.dart:58 + lib/halaman/halaman_detail_kos.dart:105 | Dikerjakan. Tag per tab (`cari-<id>`, `favorit-<id>`) agar tidak bentrok di IndexedStack. Diuji di test/hero_kartu_detail_test.dart |

---

## 11. Catatan Desain

- Warna utama dari seed `#14695C` (hijau pinus, referensi Dribbble "Papa Kost"), diturunkan lewat `ColorScheme.fromSeed` untuk mode terang dan gelap.
- Font Plus Jakarta Sans untuk seluruh teks.
- Warna di luar `ColorScheme` hanya bintang rating (amber), dipilih agar kontras ≥ 3:1 di kedua mode.
- Pedoman lengkap ada di [docs/design/](docs/design/).

## 12. Catatan Implementasi

- Ulasan disimpan di state aplikasi lalu dikirim ke server lewat `POST /ulasan`. Server menyimpannya di memori, jadi ulasan hilang ketika server dimulai ulang.
- Endpoint `/area` menghitung jumlah kos dan rata-rata harga bulanan per area dari file JSON.
- Foto kos ada untuk 9 dari 12 kos (`app/assets/images/kos_<id>.jpeg`); kos tanpa foto menampilkan ikon.
- Seluruh data kos di `server/data/kos.json` adalah data contoh fiktif untuk keperluan tugas, bukan informasi kos sungguhan.
- Nomor baris di tabel pemenuhan fitur perlu dicek ulang bila kode diubah setelah PR #47.
