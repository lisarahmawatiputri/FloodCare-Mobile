import 'dart:convert';
import 'package:floodcare_mobile/config/api_config.dart';
import 'package:floodcare_mobile/models/edukasi_article_model.dart';
import 'package:floodcare_mobile/models/edukasi_video_model.dart';
import 'package:http/http.dart' as http;

class EdukasiService {
  // Samain dengan IP backend kamu.
  // Nanti kalau mau pakai ApiConfig, tinggal ganti bagian ini.
  static const String _baseHost = 'http://192.168.1.8:8000';

  Future<List<EdukasiArticle>> fetchArticles() async {
    final url = Uri.parse('$_baseHost/api/artikel');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil artikel');
    }

    final data = _extractList(response.body);

    return data
        .whereType<Map>()
        .map((item) => EdukasiArticle.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<EdukasiVideo>> fetchVideos() async {
    final url = Uri.parse('$_baseHost/api/video');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil video');
    }

    final data = _extractList(response.body);

    return data
        .whereType<Map>()
        .map((item) => EdukasiVideo.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
  Future<EdukasiArticle?> fetchLatestArticle() async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/artikel-terbaru');

  final response = await http.get(
    uri,
    headers: {
      'Accept': 'application/json',
    },
  );

  final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

  if (response.statusCode == 200) {
    if (body == null) return null;

    if (body is List) {
      if (body.isEmpty) return null;
      return EdukasiArticle.fromJson(body.first);
    }

    if (body is Map<String, dynamic>) {
      final data = body['data'];

      if (data is List) {
        if (data.isEmpty) return null;
        return EdukasiArticle.fromJson(data.first);
      }

      if (data is Map<String, dynamic>) {
        return EdukasiArticle.fromJson(data);
      }

      return EdukasiArticle.fromJson(body);
    }

    return null;
  }

  throw Exception('Gagal mengambil artikel terbaru');
}

Future<EdukasiVideo?> fetchLatestVideo() async {
  final uri = Uri.parse('${ApiConfig.baseUrl}/video-terbaru');

  final response = await http.get(
    uri,
    headers: {
      'Accept': 'application/json',
    },
  );

  final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

  if (response.statusCode == 200) {
    if (body == null) return null;

    if (body is Map<String, dynamic>) {
      final data = body['data'];

      if (data is Map<String, dynamic>) {
        return EdukasiVideo.fromJson(data);
      }

      return EdukasiVideo.fromJson(body);
    }

    return null;
  }

  throw Exception('Gagal mengambil video terbaru');
}

  List<dynamic> _extractList(String body) {
    final decoded = jsonDecode(body);

    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];

      if (data is List) {
        return data;
      }
    }

    return [];
  }
}