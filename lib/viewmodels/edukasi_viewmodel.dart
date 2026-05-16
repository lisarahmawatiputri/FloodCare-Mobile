import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:floodcare_mobile/config/api_config.dart';
import 'package:floodcare_mobile/models/edukasi_article_model.dart';
import 'package:floodcare_mobile/models/edukasi_video_model.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class EdukasiViewModel extends ChangeNotifier {
  final List<String> categories = const [
    'Semua',
    'Artikel',
    'Video',
  ];

  int selectedCategory = 0;
  String searchQuery = '';

  bool isLoadingArticles = false;
  bool isLoadingVideos = false;

  String? articleErrorMessage;
  String? videoErrorMessage;

  List<EdukasiArticle> articles = [];
  List<EdukasiVideo> videos = [];

  List<EdukasiArticle> get filteredArticles {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return articles;
    }

    return articles.where((article) {
      return article.title.toLowerCase().contains(query) ||
          article.description.toLowerCase().contains(query) ||
          article.category.toLowerCase().contains(query);
    }).toList();
  }

  List<EdukasiVideo> get filteredVideos {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return videos;
    }

    return videos.where((video) {
      return video.title.toLowerCase().contains(query) ||
          video.description.toLowerCase().contains(query);
    }).toList();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void setCategory(int index) {
    selectedCategory = index;
    notifyListeners();
  }

  void showArticlesOnly() {
    selectedCategory = 1;
    notifyListeners();
  }

  void showVideosOnly() {
    selectedCategory = 2;
    notifyListeners();
  }

  Future<void> loadData() async {
    await Future.wait([
      fetchArticles(),
      fetchVideos(),
    ]);
  }

  Future<void> fetchArticles() async {
    isLoadingArticles = true;
    articleErrorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/artikel');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        articleErrorMessage = 'Gagal mengambil artikel';
        return;
      }

      final List<dynamic> data = _extractList(response.body);

      articles = data
          .whereType<Map>()
          .map((item) {
            return EdukasiArticle.fromJson(
              Map<String, dynamic>.from(item),
            );
          })
          .toList();
    } catch (e) {
      debugPrint('Error fetch artikel: $e');
      articleErrorMessage = 'Terjadi kesalahan saat mengambil artikel';
    } finally {
      isLoadingArticles = false;
      notifyListeners();
    }
  }

  Future<void> fetchVideos() async {
    isLoadingVideos = true;
    videoErrorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/video');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        videoErrorMessage = 'Gagal mengambil video';
        return;
      }

      final List<dynamic> data = _extractList(response.body);

      videos = data
          .whereType<Map>()
          .map((item) {
            return EdukasiVideo.fromJson(
              Map<String, dynamic>.from(item),
            );
          })
          .toList();
    } catch (e) {
      debugPrint('Error fetch video: $e');
      videoErrorMessage = 'Terjadi kesalahan saat mengambil video';
    } finally {
      isLoadingVideos = false;
      notifyListeners();
    }
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

  String getMediaUrl(String path) {
    if (path.trim().isEmpty) {
      return '';
    }

    return ApiConfig.getImageUrl(path);
  }

  Future<String?> openArticle(EdukasiArticle article) async {
    final urlString = article.url.trim();

    if (urlString.isEmpty) {
      return 'URL tidak tersedia';
    }

    final uri = Uri.tryParse(urlString);

    if (uri == null) {
      return 'URL tidak valid';
    }

    final canOpen = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!canOpen) {
      return 'Tidak bisa membuka halaman';
    }

    return null;
  }
}