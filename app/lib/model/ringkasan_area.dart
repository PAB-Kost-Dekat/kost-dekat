class RingkasanArea {
  const RingkasanArea({
    required this.area,
    required this.jumlahKos,
    required this.hargaRataRata,
  });

  final String area;
  final int jumlahKos;
  final int hargaRataRata;

  factory RingkasanArea.fromJson(Map<String, dynamic> json) => RingkasanArea(
    area: json['area'] as String,
    jumlahKos: json['jumlahKos'] as int,
    hargaRataRata: json['hargaRataRata'] as int,
  );
}
