import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiConfig {
  static const String _port = '8000';

  // Android Studio Emulator:
  // static const String _host = '10.0.2.2';

  // HP fisik / Waydroid:
  static const String _host = '192.168.240.1';

  // Web / laptop sendiri:
  // static const String _host = '127.0.0.1';

  static String get baseHost {
    if (kIsWeb) {
      return 'http://127.0.0.1:$_port';
    }

    if (Platform.isAndroid) {
      return 'http://$_host:$_port';
    }

    return 'http://127.0.0.1:$_port';
  }

  static String get baseUrl {
    return '$baseHost/api';
  }

  static String get storageUrl {
    return '$baseHost/storage';
  }

  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    return '$storageUrl/$path';
  }
}