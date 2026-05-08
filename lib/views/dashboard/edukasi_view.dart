import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:floodcare_mobile/utils/colors.dart'; 

class EdukasiView extends StatefulWidget {
  const EdukasiView({super.key});

  @override
  State<EdukasiView> createState() => _EdukasiViewState();
}

class _EdukasiViewState extends State<EdukasiView> {
  int selectedCategory = 0;
  String searchQuery = '';
  
  // State untuk API Artikel
  List<Map<String, dynamic>> articles = [];
  bool isLoading = true; 

  final List<String> categories = [
    'Semua',
    'Artikel',
    'Video',
  ];

  // Data dummy untuk video (karena belum disambung ke API)
  final List<Map<String, dynamic>> videos = [
    {
      'title': 'Cara Aman Menghadapi Banjir di Rumah',
      'duration': '08:24',
      //'image': 'assets/images/video_banjir1.png',
    },
    {
      'title': 'Persiapan Tas Darurat Saat Bencana',
      'duration': '05:10',
      //'image': 'assets/images/video_banjir2.png',
    },
  ];

  // Fungsi untuk hit API
  Future<void> fetchArticles() async {
    try {
      // GANTI URL DI BAWAH INI DENGAN URL API ASLI DARI WEB KALIAN
      final url = Uri.parse('http://localhost:8000/api/artikel'); 
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        setState(() {
          // Konversi data dari JSON ke List<Map>
          articles = List<Map<String, dynamic>>.from(data);
          isLoading = false; 
        });
      } else {
        debugPrint('Gagal mengambil data. Status code: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Terjadi error saat hit API: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    
    fetchArticles();
  }

  Widget safeAssetImage({
  required String image,
  required double width,
  required double height,
  BoxFit fit = BoxFit.cover,
}) {
  // Jika image berawalan http, gunakan Image.network
  if (image.startsWith('http')) {
    return Image.network(
      image,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _placeholderImage(width, height),
    );
  }

  // Jika image kosong atau path lokal
  if (image.trim().isEmpty) {
    return _placeholderImage(width, height);
  }

  return Image.asset(
    image,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (context, error, stackTrace) => _placeholderImage(width, height),
  );
}

// Fungsi pembantu untuk tampilan jika gambar error/kosong
Widget _placeholderImage(double width, double height) {
  return Container(
    width: width,
    height: height,
    color: const Color(0xFFE5E7EB),
    child: const Center(
      child: Icon(Icons.image_not_supported_outlined, color: Color(0xFF9CA3AF), size: 34),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    // Logika Filter Data berdasarkan Pencarian
    final filteredArticles = articles.where((article) {
      final title = (article['title'] ?? '').toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      return title.contains(query); 
    }).toList();
    
    final filteredVideos = videos.where((video) {
      final title = (video['title'] ?? '').toString().toLowerCase();
      final query = searchQuery.toLowerCase();
      return title.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _searchBox(),
              const SizedBox(height: 14),
              _categoryTabs(),
              const SizedBox(height: 24),
              
              // Sembunyikan popular card jika sedang ngetik pencarian
              if (searchQuery.isEmpty) ...[
                _popularCard(),
                const SizedBox(height: 26),
              ],

              // --- BAGIAN ARTIKEL ---
              if ((selectedCategory == 0 || selectedCategory == 1)) ...[
                _sectionHeader(
                  title: 'Artikel Terbaru',
                  onTap: () {},
                ),
                const SizedBox(height: 14),
                
                // Loading indikator untuk API
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (filteredArticles.isNotEmpty)
                  ...filteredArticles.map((article) {
                    return _articleCard(article);
                  })
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Tidak ada artikel ditemukan.', 
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 20),
              ],

              // --- BAGIAN VIDEO ---
              if ((selectedCategory == 0 || selectedCategory == 2)) ...[
                _sectionHeader(
                  title: 'Video Terbaru',
                  onTap: () {},
                ),
                const SizedBox(height: 14),
                
                if (filteredVideos.isNotEmpty)
                  ...filteredVideos.map((video) {
                    return _videoCard(video);
                  })
                else if (searchQuery.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Tidak ada video ditemukan.', 
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: Color(0xFF94A3B8),
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Cari materi edukasi banjir...',
                hintStyle: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryTabs() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = selectedCategory == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = index;
              });
            },
            child: Container(
              width: 83,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                gradient: isSelected ? orangeGradient : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : const Color(0xFFDDE6ED),
                ),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _popularCard() {
    return Container(
      height: 178,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: safeAssetImage(
              image: 'assets/images/edukasi_popular.png',
              width: double.infinity,
              height: 178,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.92),
                    Colors.black.withOpacity(0.76),
                    Colors.black.withOpacity(0.35),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                gradient: orangeGradient,
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Text(
                'TERPOPULER',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 18,
            right: 26,
            top: 49,
            child: Text(
              'Panduan Lengkap\nMenghadapi Banjir di\nKawasan Perkotaan',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 21,
                height: 1.08,
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Positioned(
            left: 18,
            right: 24,
            top: 128,
            child: Text(
              'Langkah-langkah taktis untuk melindungi keluarga dan aset berharga saat debit air mulai naik.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.3,
                color: Color(0xFFE5E7EB),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1F2933),
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: const Text(
            'Lihat Semua →',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFFC65A1E),
            ),
          ),
        ),
      ],
    );
  }

  Widget _articleCard(Map<String, dynamic> article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              safeAssetImage(
                image: article['image']?.toString() ?? '',
                width: double.infinity,
                height: 165,
              ),
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    // Default string jika data category dari API null
                    article['category']?.toString() ?? 'ARTIKEL', 
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFFC65A1E),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Color(0xFFCBD5E1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      article['readTime']?.toString() ?? '- mnt baca',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: Color(0xFFCBD5E1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      article['date']?.toString() ?? '-',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  article['title']?.toString() ?? 'Tanpa Judul',
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1F2933),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  article['description']?.toString() ?? 'Tidak ada deskripsi',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'BACA SELENGKAPNYA ›',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFC65A1E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoCard(Map<String, dynamic> video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              safeAssetImage(
                image: video['image']?.toString() ?? '',
                width: double.infinity,
                height: 170,
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.18),
                ),
              ),
              Center(
                heightFactor: 3.5,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    video['duration']?.toString() ?? '00:00',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Text(
              video['title']?.toString() ?? 'Tanpa Judul',
              style: const TextStyle(
                fontSize: 16,
                height: 1.3,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1F2933),
              ),
            ),
          ),
        ],
      ),
    );
  }
}