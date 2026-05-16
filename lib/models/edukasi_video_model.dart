class EdukasiVideo {
  final String title;
  final String description;
  final String thumbnail;
  final String date;
  final String duration;
  final String videoUrl;

  const EdukasiVideo({
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.date,
    required this.duration,
    required this.videoUrl,
  });

  factory EdukasiVideo.fromJson(Map<String, dynamic> json) {
    return EdukasiVideo(
      title: _readString(json, ['title', 'judul'], fallback: 'Tanpa Judul'),
      description: _readString(json, ['description', 'deskripsi']),
      thumbnail: _readString(json, ['thumbnail', 'image', 'gambar', 'foto']),
      date: _readString(json, ['date', 'tanggal', 'created_at'], fallback: '-'),
      duration: _readString(json, ['duration', 'durasi'], fallback: '00:00'),
      videoUrl: _readString(json, ['video_url', 'video', 'url', 'link']),
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