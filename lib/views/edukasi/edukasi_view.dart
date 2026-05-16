import 'package:flutter/material.dart';
import 'package:floodcare_mobile/models/edukasi_article_model.dart';
import 'package:floodcare_mobile/models/edukasi_video_model.dart';
import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/viewmodels/edukasi_viewmodel.dart';
import 'package:floodcare_mobile/views/edukasi/video_detail_page.dart';

class EdukasiView extends StatefulWidget {
  const EdukasiView({super.key});

  @override
  State<EdukasiView> createState() => _EdukasiViewState();
}

class _EdukasiViewState extends State<EdukasiView> {
  late final EdukasiViewModel viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    viewModel = EdukasiViewModel();
    viewModel.loadData();
  }

  @override
  void dispose() {
    viewModel.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _openArticle(EdukasiArticle article) async {
    final message = await viewModel.openArticle(article);

    if (!mounted || message == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget safeAssetImage({
    required String image,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
  }) {
    final mediaUrl = viewModel.getMediaUrl(image);

    if (mediaUrl.startsWith('http')) {
      return Image.network(
        mediaUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _placeholderImage(width, height);
        },
        errorBuilder: (context, error, stackTrace) {
          return _placeholderImage(width, height);
        },
      );
    }

    if (image.trim().isEmpty) {
      return _placeholderImage(width, height);
    }

    return Image.asset(
      image,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return _placeholderImage(width, height);
      },
    );
  }

  Widget _placeholderImage(double width, double height) {
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        final filteredArticles = viewModel.filteredArticles;
        final filteredVideos = viewModel.filteredVideos;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _searchBox(),

                  const SizedBox(height: 14),

                  _categoryTabs(),

                  const SizedBox(height: 24),

                  if (viewModel.selectedCategory == 0) ...[
                    _popularCard(),
                    const SizedBox(height: 26),
                  ],

                  if (viewModel.selectedCategory == 0 ||
                      viewModel.selectedCategory == 1) ...[
                    _sectionHeader(
                      title: 'Artikel Terbaru',
                      showLihatSemua: viewModel.selectedCategory == 0,
                      onTap: () {
                        viewModel.showArticlesOnly();
                        _scrollToTop();
                      },
                    ),
                    const SizedBox(height: 14),
                    if (viewModel.isLoadingArticles)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (filteredArticles.isNotEmpty)
                      ...filteredArticles.map((article) {
                        return _articleCard(article);
                      })
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          viewModel.articleErrorMessage ??
                              'Tidak ada artikel ditemukan.',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],

                  if (viewModel.selectedCategory == 0 ||
                      viewModel.selectedCategory == 2) ...[
                    _sectionHeader(
                      title: 'Video Terbaru',
                      showLihatSemua: viewModel.selectedCategory == 0,
                      onTap: () {
                        viewModel.showVideosOnly();
                        _scrollToTop();
                      },
                    ),
                    const SizedBox(height: 14),
                    if (viewModel.isLoadingVideos)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (filteredVideos.isNotEmpty)
                      ...filteredVideos.map((video) {
                        return _videoCard(video);
                      })
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          viewModel.videoErrorMessage ??
                              (viewModel.searchQuery.isNotEmpty
                                  ? 'Tidak ada video ditemukan.'
                                  : 'Belum ada video tersedia.'),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _searchBox() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF94A3B8), size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: viewModel.setSearchQuery,
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
        itemCount: viewModel.categories.length,
        itemBuilder: (context, index) {
          final isSelected = viewModel.selectedCategory == index;

          return GestureDetector(
            onTap: () => viewModel.setCategory(index),
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
                  viewModel.categories[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
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
            color: Colors.black.withValues(alpha:0.08),
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
                    Colors.black.withValues(alpha: 0.92),
                    Colors.black.withValues(alpha: 0.76),
                    Colors.black.withValues(alpha: 0.35),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
    bool showLihatSemua = true,
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
        if (showLihatSemua)
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

  Widget _articleCard(EdukasiArticle article) {
    return GestureDetector(
      onTap: () => _openArticle(article),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.04),
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
                  image: article.image,
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
                      article.category,
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
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: Color(0xFFCBD5E1),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article.date,
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
                    article.title,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.25,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1F2933),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    article.description.isEmpty
                        ? 'Tidak ada deskripsi'
                        : article.description,
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
      ),
    );
  }

  Widget _videoCard(EdukasiVideo video) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoDetailPage(video: video),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.04),
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
                  image: video.thumbnail,
                  width: double.infinity,
                  height: 170,
                ),
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha:0.18)),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.75),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Color(0xFFC65A1E),
                        size: 36,
                      ),
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
                      color: Colors.black.withValues(alpha:0.65),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      video.duration,
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
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: Color(0xFFCBD5E1),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        video.date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    video.title,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1F2933),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'TONTON VIDEO ›',
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
      ),
    );
  }
}