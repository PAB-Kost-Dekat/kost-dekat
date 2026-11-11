class Ulasan {
  const Ulasan({
    required this.kosId,
    required this.namaKos,
    required this.rating,
    required this.komentar,
    required this.tanggal,
  }) : assert(rating >= 1 && rating <= 5);

  final String kosId;
  final String namaKos;
  final int rating;
  final String komentar;
  final DateTime tanggal;

  factory Ulasan.fromJson(Map<String, dynamic> json) => Ulasan(
    kosId: json['kosId'] as String,
    namaKos: json['namaKos'] as String,
    rating: json['rating'] as int,
    komentar: json['komentar'] as String,
    tanggal: DateTime.parse(json['tanggal'] as String),
  );

  Map<String, dynamic> toJson() => {
    'kosId': kosId,
    'namaKos': namaKos,
    'rating': rating,
    'komentar': komentar,
    'tanggal': tanggal.toIso8601String(),
  };
}
