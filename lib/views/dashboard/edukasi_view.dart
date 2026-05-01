import 'package:flutter/material.dart';
import 'package:floodcare_mobile/utils/colors.dart';

class EdukasiView extends StatefulWidget {
  const EdukasiView({super.key});

  @override
  State<EdukasiView> createState() => _EdukasiViewState();
}

class _EdukasiViewState extends State<EdukasiView> {
  int selectedCategory = 0;

  final List<String> categories = [
    'Semua',
    'Artikel',
    'Video',
  ];

  final List<Map<String, dynamic>> articles = [
    {
      'category': 'KESELAMATAN',
      'title': 'Panduan Evakuasi Saat Banjir Melanda',
      'description':
          'Pelajari langkah-langkah penting untuk menyelamatkan diri dan keluarga saat terjadi banjir.',
      'readTime': '5 mnt baca',
      'date': '12 Okt 2023',
      //'image': 'assets/images/edukasi1.png',
    },
    {
      'category': 'LINGKUNGAN',
      'title': 'Pentingnya Menjaga Drainase untuk Mencegah Genangan Air',
      'description':
          'Langkah sederhana yang bisa dilakukan setiap rumah tangga untuk menjaga aliran air tetap lancar saat hujan.',
      'readTime': '6 mnt baca',
      'date': '08 Okt 2023',
      //'image': 'assets/images/edukasi2.png',
    },
  ];

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

    Widget safeAssetImage({
    required String image,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (image.trim().isEmpty) {
      return Container(
        width: width,
        height: height,
        color: const Color(0xFFE5E7EB),
        child: const Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFF9CA3AF),
            size: 34,
          ),
        ),
      );
    }

    return Image.asset(
      image,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) {
        return Container(
          width: width,
          height: height,
          color: const Color(0xFFE5E7EB),
          child: const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Color(0xFF9CA3AF),
              size: 34,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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

              _popularCard(),

              const SizedBox(height: 26),

              _sectionHeader(
                title: 'Artikel Terbaru',
                onTap: () {},
              ),

              const SizedBox(height: 14),

              ...articles.map((article) {
                return _articleCard(article);
              }),

              const SizedBox(height: 20),

              _sectionHeader(
                title: 'Video Terbaru',
                onTap: () {},
              ),

              const SizedBox(height: 14),

              ...videos.map((video) {
                return _videoCard(video);
              }),
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
      child: const Row(
        children: [
          Icon(
            Icons.search,
            color: Color(0xFF94A3B8),
            size: 24,
          ),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
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
                    article['category'],
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
                      article['readTime'],
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
                      article['date'],
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
                  article['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.25,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1F2933),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  article['description'],
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
                    video['duration'],
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
              video['title'],
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