//ini hosting
class ApiConfig {
  static const String host = 'https://floodcare.my.id';

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
