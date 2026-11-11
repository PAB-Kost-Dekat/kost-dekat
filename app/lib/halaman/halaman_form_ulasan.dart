import 'package:flutter/material.dart';

import '../model/ulasan.dart';
import '../tema/tema_kosdekat.dart';

/// Form tambah ulasan kos (SCRUM-29).
/// Mengembalikan objek [Ulasan] melalui `Navigator.pop(context, ulasan)`.
class HalamanFormUlasan extends StatefulWidget {
  const HalamanFormUlasan({
    super.key,
    required this.kosId,
    required this.namaKos,
  });

  final String kosId;
  final String namaKos;

  @override
  State<HalamanFormUlasan> createState() => _HalamanFormUlasanState();
}

class _HalamanFormUlasanState extends State<HalamanFormUlasan> {
  final _formKey = GlobalKey<FormState>();
  final _namaPengulasController = TextEditingController();
  final _komentarController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _namaPengulasController.dispose();
    _komentarController.dispose();
    super.dispose();
  }

  void _kirim() {
    if (!_formKey.currentState!.validate()) return;

    final ulasanBaru = Ulasan(
      kosId: widget.kosId,
      namaKos: _namaPengulasController.text.trim().isEmpty
          ? widget.namaKos
          : _namaPengulasController.text.trim(),
      rating: _rating,
      komentar: _komentarController.text.trim(),
      tanggal: DateTime.now(),
    );

    Navigator.pop(context, ulasanBaru);
  }

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;
    final warna = Theme.of(context).colorScheme;
    final warnaBintang =
        Theme.of(context).extension<WarnaKosDekat>()?.bintang ?? warna.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Tulis Ulasan')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(widget.namaKos, style: teks.titleLarge),
              const SizedBox(height: 16),
              Text('Rating', style: teks.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  final bintangKe = index + 1;
                  return IconButton(
                    tooltip: 'Rating $bintangKe bintang',
                    icon: Icon(
                      bintangKe <= _rating ? Icons.star : Icons.star_border,
                      color: warnaBintang,
                      size: 32,
                    ),
                    onPressed: () => setState(() => _rating = bintangKe),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _namaPengulasController,
                decoration: const InputDecoration(
                  labelText: 'Nama Anda (opsional)',
                  hintText: 'Biarkan kosong untuk nama kos',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _komentarController,
                decoration: const InputDecoration(
                  labelText: 'Komentar ulasan',
                  hintText: 'Ceritakan pengalaman tinggal di kos ini...',
                ),
                maxLines: 4,
                validator: (nilai) {
                  final komentar = nilai?.trim() ?? '';
                  if (komentar.isEmpty) {
                    return 'Komentar tidak boleh kosong';
                  }
                  if (komentar.length < 5) {
                    return 'Komentar minimal 5 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _kirim,
                icon: const Icon(Icons.send),
                label: const Text('Kirim Ulasan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
