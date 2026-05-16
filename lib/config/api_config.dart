class ApiConfig {
  // Untuk Android Emulator
  // static const String host = 'http://10.0.2.2:8000';

  // Kalau test di HP fisik, ganti jadi IP laptop kamu, contoh:
  static const String host = 'http://192.168.1.12:8000';

  // Kalau test Flutter Web/Chrome lokal, pakai:
  // static const String host = 'http://127.0.0.1:8000';

  static const String baseUrl = '$host/api';
  static const String storageUrl = '$host/storage';

  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    if (cleanPath.startsWith('storage/')) {
      return '$host/$cleanPath';
    }

    return '$storageUrl/$cleanPath';
  }
}