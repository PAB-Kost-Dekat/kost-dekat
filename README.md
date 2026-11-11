# KosDekat — Info Kos Sekitar Telkom University

Proyek UTS Pengembangan Aplikasi Bergerak · **Kelompok 06 · Proyek 5**

KosDekat adalah aplikasi Android (Flutter) untuk mencari kos di sekitar Telkom University (Sukapura, Sukabirus, Bojongsoang, dan sekitarnya). Aplikasi mengambil data dari server REST API kecil berbasis Dart `shelf` yang ada di folder `server/`.

> Seluruh data kos di `server/data/kos.json` adalah **data contoh fiktif** untuk keperluan tugas, bukan informasi kos sungguhan.

---

## Daftar Isi

1. [Fitur](#1-fitur)
2. [Anggota Kelompok](#2-anggota-kelompok)
3. [Tautan Penting](#3-tautan-penting)
4. [Struktur Repositori](#4-struktur-repositori)
5. [Prasyarat](#5-prasyarat)
6. [Cara Menjalankan](#6-cara-menjalankan)
7. [Endpoint API](#7-endpoint-api)
8. [Alur Kerja Tim](#8-alur-kerja-tim)
9. [Tangkapan Layar](#9-tangkapan-layar)
10. [Tabel Pemenuhan Fitur](#10-tabel-pemenuhan-fitur)
11. [Catatan Desain](#11-catatan-desain)
12. [Atribusi Aset](#12-atribusi-aset)

---

## 1. Fitur

| Fitur | Keterangan |
|---|---|
| Daftar kos | Kartu berisi gambar, nama, area, jarak, tipe, harga, dan kamar mandi dalam |
| Filter tipe | `SegmentedButton` Putra / Putri / Campur |
| Urutan | Termurah (harga) atau Terdekat (jarak) |
| Harga Rupiah | Format seragam, contoh `Rp1.250.000/bln` |
| Ringkasan area | Harga rata-rata dan jumlah kos per area dari `GET /area` |
| Detail kos | Semua informasi kos, termasuk "Diperbarui N hari lalu" |
| Ulasan | Rating 1–5 bintang yang bisa diketuk + komentar, langsung tampil di Detail dan Profil |
| Favorit | Tandai kos, lihat di tab Favorit |
| Tema | Terang dan gelap dari satu warna seed, font kustom, ikon launcher sendiri |
| Keadaan jaringan | Memuat, gagal (tombol **Coba lagi**), berhasil |
| Login (simulasi lokal) | Validasi nama, email `@student.telkomuniversity.ac.id`, dan kata sandi minimal 6 karakter. Tanpa server: data tidak dikirim dan kata sandi tidak disimpan |
| Keluar | Tombol di tab Profil dengan konfirmasi, kembali ke halaman login |

Navigasi bawah: **Cari · Favorit · Profil**.

> Favorit dan ulasan disimpan di memori aplikasi, jadi ikut hilang saat pengguna **Keluar** atau menutup aplikasi.

---

## 2. Anggota Kelompok

| No | Nama | NIM | Peran | Tugas utama (tiket Jira) |
|----|------|-----|-------|---------------------------|
| 1 | _isi_ | _isi_ | A1 · Server & Rilis | Server, data JSON, endpoint (SCRUM-13 s.d. 16), ikon & aset (SCRUM-35), uji dari nol (SCRUM-39), POST ulasan (SCRUM-42) |
| 2 | _isi_ | _isi_ | A2 · Model, Service & QA | Model & service (SCRUM-17 s.d. 20), widget test (SCRUM-37), analyze/test (SCRUM-38), audit 28 poin (SCRUM-49) |
| 3 | _isi_ | _isi_ | A3 · Tab Cari & Fitur Khas | Kartu, FutureBuilder, filter, urutan, Rupiah, ringkasan area (SCRUM-21 s.d. 26), pull-to-refresh & Hero (SCRUM-40, 41) |
| 4 | _isi_ | _isi_ | A4 · Navigasi & Halaman | HalamanUtama, Detail, Form Ulasan, Favorit, Profil (SCRUM-27 s.d. 32, 47, 48) |
| 5 | _isi_ | _isi_ | A5 · Setup, Tema & Dokumentasi | Setup repo (SCRUM-10 s.d. 12), tema & font (SCRUM-33, 34, 36), README, screenshot, video (SCRUM-43 s.d. 45) |

Ketua kelompok: _isi_ (mengunggah ke LMS, SCRUM-46).

---

## 3. Tautan Penting

| Apa | Tautan |
|---|---|
| Board Jira (project SCRUM) | _isi tautan board_ |
| Product Requirements Document (PRD) | _isi tautan dokumen PRD_ |
| Design system | [docs/design/design.md](docs/design/design.md) |
| Peta file ke tiket | [docs/struktur-kode.md](docs/struktur-kode.md) |
| Aturan kerja tim | [CONTRIBUTING.md](CONTRIBUTING.md) |
| Video demo | _isi tautan YouTube unlisted / Google Drive_ |

---

## 4. Struktur Repositori

```
kost-dekat/
├─ app/                              # Proyek Flutter (id.ac.telkomuniversity.kosdekat)
│  ├─ android/                       # Dibuat flutter create; label & izin internet diatur skrip
│  ├─ lib/
│  │  ├─ main.dart                   # KosDekatApp: MaterialApp + tema terang/gelap
│  │  ├─ model/
│  │  │  ├─ kos.dart                 # Model Kos (8 field) + fromJson/toJson
│  │  │  ├─ ulasan.dart              # Model Ulasan (form tambah)
│  │  │  └─ ringkasan_area.dart      # Respons GET /area
│  │  ├─ service/
│  │  │  └─ kos_service.dart         # Paket http, API_URL dari --dart-define
│  │  ├─ halaman/
│  │  │  ├─ halaman_utama.dart       # NavigationBar 3 tab + IndexedStack (pemilik state)
│  │  │  ├─ tab_cari.dart            # FutureBuilder, filter, urutan, daftar kos
│  │  │  ├─ tab_favorit.dart         # Daftar kos favorit
│  │  │  ├─ tab_profil.dart          # Ringkasan pengguna + ulasan saya
│  │  │  ├─ halaman_detail_kos.dart  # Detail via konstruktor + tombol Tulis ulasan
│  │  │  └─ halaman_form_ulasan.dart # TextField, bintang, Navigator.pop(context, data)
│  │  ├─ widget/
│  │  │  ├─ kartu_kos.dart           # Row, Column, Expanded, Stack
│  │  │  └─ ringkasan_area.dart      # Kartu area dari GET /area
│  │  ├─ tema/
│  │  │  └─ tema_kosdekat.dart       # ColorScheme.fromSeed + darkTheme + font
│  │  └─ util/
│  │     └─ format_rupiah.dart       # "Rp1.250.000/bln"
│  ├─ test/
│  │  ├─ widget_test.dart            # ≥ 3 widget test
│  │  ├─ kos_service_test.dart       # Test MockClient (tanpa server)
│  │  └─ format_rupiah_test.dart     # Unit test format harga
│  ├─ assets/
│  │  ├─ fonts/                      # File .ttf + OFL.txt
│  │  ├─ icon/                       # ikon_kosdekat.png (sumber ikon launcher)
│  │  └─ images/                     # Ilustrasi kos, empty state, logo
│  └─ pubspec.yaml
├─ server/                           # API Dart (shelf + shelf_router)
│  ├─ bin/server.dart                # Router + GET /kos, /kos/<id>, /area
│  ├─ data/kos.json                  # ≥ 12 kos contoh
│  └─ pubspec.yaml
├─ docs/
│  ├─ README.md                      # Indeks dokumentasi
│  ├─ struktur-kode.md               # Peta file → tiket Jira → PIC
│  └─ design/                        # Design system (token, pedoman, komponen)
├─ screenshots/                      # ≥ 4 tangkapan layar dari perangkat
├─ scripts/
│  ├─ buat_app.sh                    # Membuat app/ + folder lib & assets
│  └─ zip_pengumpulan.sh             # Zip LMS tanpa build/, .dart_tool/, android/.gradle/
├─ .github/
│  ├─ pull_request_template.md       # Checklist PR + baris tabel README
│  └─ workflows/cek.yml              # flutter analyze + flutter test otomatis
├─ CONTRIBUTING.md                   # Aturan branch, commit, PR, penamaan
└─ README.md
```

Rincian tanggung jawab setiap file ada di [docs/struktur-kode.md](docs/struktur-kode.md).

---

## 5. Prasyarat

| Kebutuhan | Versi |
|---|---|
| Flutter SDK | _isi hasil `flutter --version`_ |
| Dart SDK | _isi hasil `dart --version`_ (ikut Flutter) |
| Android | Emulator Android Studio atau HP Android dengan USB debugging |
| Git | Versi apa pun |

Semua anggota memakai versi Flutter yang sama agar `pubspec.lock` dan hasil `flutter analyze` konsisten.

---

## 6. Cara Menjalankan

### 6.1 Clone repositori

```bash
git clone https://github.com/PAB-Kost-Dekat/kost-dekat.git
cd kost-dekat
```

### 6.2 Menyalakan server

```bash
cd server
dart pub get
dart run bin/server.dart
# Server KosDekat berjalan di port 8080
```

Uji dari terminal lain:

```bash
curl http://localhost:8080/kos
curl http://localhost:8080/kos/1
curl http://localhost:8080/area
```

### 6.3 Menjalankan aplikasi

```bash
cd app
flutter pub get
```

Pilih **salah satu** perintah sesuai perangkat:

| Perangkat | Perintah |
|-----------|----------|
| Emulator Android | `flutter run --dart-define=API_URL=http://10.0.2.2:8080` |
| HP fisik, satu Wi-Fi dengan laptop | `flutter run --dart-define=API_URL=http://<IP-LAN-laptop>:8080` |
| HP fisik via kabel USB | `adb reverse tcp:8080 tcp:8080` lalu `flutter run --dart-define=API_URL=http://127.0.0.1:8080` |

> **Penting.** `127.0.0.1` di emulator atau HP menunjuk ke perangkat itu sendiri, bukan laptop. Gunakan `127.0.0.1` hanya bersama `adb reverse`.
> Cari IP LAN laptop dengan `ipconfig` (Windows) atau `ip addr` (Linux/macOS). Bila HP tetap tidak terhubung, izinkan Dart di firewall untuk jaringan Private.

### 6.4 Pemeriksaan kualitas

```bash
cd app
flutter analyze   # harus: No issues found!
flutter test      # harus: All tests passed!
```

### 6.5 APK debug

```bash
cd app
flutter build apk --debug
# hasil: app/build/app/outputs/flutter-apk/app-debug.apk
```

---

## 7. Endpoint API

| Metode & jalur | Respons berhasil | Respons gagal | Keterangan |
|---|---|---|---|
| `GET /kos` | 200, daftar kos | 500 | Daftar item |
| `GET /kos/<id>` | 200, satu kos | 404 `{"pesan": "Kos tidak ditemukan"}` | Satu item berdasarkan id |
| `GET /area` | 200, `[{area, jumlahKos, hargaRataRata}]` | 500 | **Endpoint khas KosDekat** |
| `POST /ulasan` | 201, ulasan tersimpan | 400 bila tidak valid | Nilai tambah (bila dikerjakan) |

Contoh satu item `kos.json`:

```json
{
  "id": "1",
  "nama": "Kos Melati Indah (contoh)",
  "area": "Sukapura",
  "tipe": "Putri",
  "hargaBulanan": 1250000,
  "kamarMandiDalam": true,
  "jarakKm": 0.8,
  "diperbarui": "2026-10-28T09:00:00.000"
}
```

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

| Cari | Detail | Form Ulasan | Favorit |
|------|--------|-------------|---------|
| ![Cari](screenshots/01_cari.png) | ![Detail](screenshots/02_detail.png) | ![Form](screenshots/03_form_ulasan.png) | ![Favorit](screenshots/04_favorit.png) |

| Profil | Gagal memuat | Mode gelap |
|--------|--------------|------------|
| ![Profil](screenshots/05_profil.png) | ![Gagal](screenshots/06_gagal.png) | ![Gelap](screenshots/07_gelap.png) |

---

## 10. Tabel Pemenuhan Fitur

> Kolom File:baris diisi setelah kode final di-merge. Path relatif terhadap `app/` kecuali diawali `server/`.

### 10.1 Fitur wajib (Bagian 3)

| Poin | File:baris | Keterangan |
|------|-----------|------------|
| P01–P02 Proyek dibuat dengan `flutter create --org id.ac.telkomuniversity`, paket bukan `com.example` | android/app/build.gradle(.kts):_ | applicationId `id.ac.telkomuniversity.kosdekat` |
| P01–P02 Nama aplikasi di launcher sesuai tema (bukan `flutter_application_1`) | android/app/src/main/AndroidManifest.xml:_ | Label "KosDekat" |
| P01–P02 Berjalan di emulator/HP Android, ≥ 4 tangkapan layar dari perangkat | screenshots/ | _n_ tangkapan layar dari _emulator/HP_ |
| P01–P02 `flutter analyze` bersih (tanpa error maupun warning) | - | No issues found! |
| P03 StatelessWidget & StatefulWidget buatan sendiri, setState mengubah tampilan | lib/_:_ | _ |
| P03 TextField + TextEditingController di-dispose | lib/halaman/halaman_form_ulasan.dart:_ | Komentar ulasan |
| P03 ≥ 2 jenis tombol Material 3 | lib/_:_ | FilledButton, IconButton, FloatingActionButton |
| P03 ChoiceChip / FilterChip / SegmentedButton | lib/halaman/tab_cari.dart:_ | SegmentedButton tipe kos |
| P03 SnackBar | lib/_:_ | "Ulasan tersimpan" |
| P04 Model ≥ 6 field (DateTime & bool) | lib/model/kos.dart:_ | 8 field, `diperbarui` DateTime, `kamarMandiDalam` bool |
| P04 Kartu buatan sendiri (Row, Column, Expanded, Stack) | lib/widget/kartu_kos.dart:_ | `KartuKos` |
| P04 ListView.builder | lib/halaman/tab_cari.dart:_ | Daftar kos |
| P04 NavigationBar ≥ 3 tab + IndexedStack | lib/halaman/halaman_utama.dart:_ | Cari · Favorit · Profil |
| P05 Halaman detail menerima objek lewat konstruktor | lib/halaman/halaman_detail_kos.dart:_ | `HalamanDetailKos(kos: ...)` |
| P05 Form tambah → `Navigator.pop(context, data)` → `await` → muncul di daftar | lib/halaman/halaman_detail_kos.dart:_ | Ulasan tampil di Detail & Profil |
| P05 Cek `mounted` setelah `await` | lib/halaman/halaman_detail_kos.dart:_ | `if (!mounted) return;` |
| P05 ≥3 widget test | `test/widget_test.dart:10,29` dan `test/halaman_login_test.dart:30,43,54,78,105` | 8 widget test (2 tema, 1 kartu kos, 5 login dan Profil) |
| P06 ColorScheme.fromSeed + darkTheme | lib/tema/tema_kosdekat.dart:_ | Seed `#______` |
| P06 Warna dari `Theme.of(context).colorScheme` (≤ 3 pengecualian) | lib/_:_ | Pengecualian: warna bintang |
| P06 Font kustom | pubspec.yaml:_ | _nama font_ |
| P06 Ikon launcher sendiri (flutter_launcher_icons) | pubspec.yaml:_ | assets/icon/ikon_kosdekat.png |
| P06 Gambar aset lokal di pubspec.yaml | pubspec.yaml:_ | assets/images/ |
| P07 `server/` shelf + shelf_router, data ≥ 12 item JSON | server/bin/server.dart:_ | server/data/kos.json: _n_ item |
| P07 ≥ 3 endpoint GET | server/bin/server.dart:_ | `GET /kos`, `GET /kos/<id>`, `GET /area` |
| P07 http + dart-define | lib/service/kos_service.dart:8 | API_URL dari `--dart-define` |
| P07 fromJson/toJson + konversi DateTime | lib/model/kos.dart:_ | ISO 8601 |
| P07 FutureBuilder 3 keadaan + tombol Coba lagi | lib/halaman/tab_cari.dart:_ | memuat / gagal / berhasil |
| P07 Test MockClient | test/kos_service_test.dart:32 | Menguji KosService tanpa server |
| P07 Minimal satu test memakai MockClient | test/kos_service_test.dart | Menguji `KosService` tanpa server |

### 10.2 Fitur khas KosDekat (Bagian 5)

| Poin | File:baris | Keterangan |
|------|-----------|------------|
| Model `Kos` sesuai tema | lib/model/kos.dart:_ | id, nama, area, tipe, hargaBulanan, kamarMandiDalam, jarakKm, diperbarui |
| Tab Cari · Favorit · Profil | lib/halaman/halaman_utama.dart:_ | |
| Form ulasan: nama kos, rating 1–5 bintang yang bisa diketuk, komentar | lib/halaman/halaman_form_ulasan.dart:_ | Model `Ulasan` terpisah |
| SegmentedButton Putra/Putri/Campur | lib/halaman/tab_cari.dart:_ | |
| Urutan berdasarkan harga atau jarak | lib/halaman/tab_cari.dart:_ | Termurah / Terdekat |
| Harga format Rupiah "Rp1.250.000/bln" | lib/util/format_rupiah.dart:_ | Diuji di test/format_rupiah_test.dart |
| Endpoint khas `GET /area` | server/bin/server.dart:_ | Dipakai di lib/widget/ringkasan_area.dart |

### 10.3 Nilai tambah (Bagian 7)

| Poin | File:baris | Keterangan |
|------|-----------|------------|
| POST ulasan ke server (+5) | _ | _dikerjakan / tidak_ |
| Pull-to-refresh (+2) | _ | _dikerjakan / tidak_ |
| Hero kartu → detail (+3) | _ | _dikerjakan / tidak_ |

---

## 11. Catatan Desain

- **Model `Ulasan` terpisah.** Model `Kos` dari ketentuan tidak memiliki rating/komentar, sedangkan form tambah berupa ulasan. Ulasan disimpan sebagai model `Ulasan` (kosId, namaKos, rating, komentar, tanggal) di State aplikasi, lalu ditampilkan di halaman Detail dan tab Profil.
- **State di HalamanUtama.** Daftar kos (Future), id favorit, dan daftar ulasan disimpan di `HalamanUtama` agar tab Favorit dan Profil memakai data yang sama tanpa memanggil server ulang.
- **Warna.** Semua warna widget diambil dari `colorScheme` hasil `ColorScheme.fromSeed`. Warna bintang rating disimpan di `ThemeExtension` dan dicatat sebagai pengecualian.
- **Referensi visual:** gaya diadaptasi dari shot Dribbble "Papa Kost – Mobile Rental Apartment" ke Material 3. Token lengkap ada di [docs/design/design.md](docs/design/design.md).

---

## 12. Atribusi Aset

| Aset | Sumber | Lisensi |
|---|---|---|
| Font _nama font_ | _tautan Google Fonts_ | SIL Open Font License |
| Ikon launcher | Dibuat sendiri oleh tim | - |
| Ilustrasi kos | _sumber_ | _lisensi_ |
| Ikon antarmuka | Material Icons (bawaan Flutter) | Apache 2.0 |
