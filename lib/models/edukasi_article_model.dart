class EdukasiArticle {
  final String title;
  final String description;
  final String image;
  final String date;
  final String category;
  final String url;

  const EdukasiArticle({
    required this.title,
    required this.description,
    required this.image,
    required this.date,
    required this.category,
    required this.url,
  });

  factory EdukasiArticle.fromJson(Map<String, dynamic> json) {
    return EdukasiArticle(
      title: _readString(json, ['title', 'judul'], fallback: 'Tanpa Judul'),
      description: _readString(json, ['description', 'deskripsi']),
      image: _readString(json, ['image', 'gambar', 'foto', 'thumbnail']),
      date: _readString(json, ['date', 'tanggal', 'created_at'], fallback: '-'),
      category: _readString(json, ['category', 'kategori'], fallback: 'ARTIKEL'),
      url: _readString(json, ['url', 'link']),
    );
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = json[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return fallback;
  }
}