import 'package:flutter/material.dart';
import 'package:floodcare_mobile/models/donation_program_model.dart';
import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/viewmodels/donation_viewmodel.dart';
import 'package:floodcare_mobile/views/donasi/donation_detail_view.dart';
import 'dart:async';

class DonasiView extends StatefulWidget {
  const DonasiView({super.key});

  @override
  State<DonasiView> createState() => _DonasiViewState();
}

class _DonasiViewState extends State<DonasiView> {
  final DonationViewModel donationViewModel = DonationViewModel();
  final TextEditingController searchController = TextEditingController();
  Timer? refreshTimer;

  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    donationViewModel.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    searchController.addListener(() {
      if (mounted) {
        setState(() {
          searchQuery = searchController.text.trim().toLowerCase();
        });
      }
    });

    donationViewModel.fetchDonationPrograms();
    refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) {
        donationViewModel.fetchDonationPrograms();
      },
    );
  }
  @override
  void dispose() {
    refreshTimer?.cancel();
    searchController.dispose();
    donationViewModel.dispose();
    super.dispose();
  }

  Future<void> openDonationDetail(DonationProgram program) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DonationDetailView(program: program),
      ),
    );

    if (!mounted) return;

    await donationViewModel.fetchDonationPrograms();
  }

  List<DonationProgram> get filteredProgramsBySearch {
    final programs = donationViewModel.sortedFilteredPrograms;

    if (searchQuery.isEmpty) {
      return programs;
    }

    return programs.where((program) {
      final title = program.title.toLowerCase();
      final location = program.location.toLowerCase();
      final category = program.category.toLowerCase();

      return title.contains(searchQuery) ||
          location.contains(searchQuery) ||
          category.contains(searchQuery);
    }).toList();
  }

  Widget programImage({
    required String image,
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    const fallback = 'assets/images/donasi1.png';

    final fixedUrl = donationViewModel.fixImageUrl(image);

    Widget child;

    if (fixedUrl.isEmpty) {
      child = Image.asset(
        fallback,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    } else {
      child = Image.network(
        fixedUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Gagal load image: $fixedUrl');
          debugPrint('Error: $error');

          return Image.asset(
            fallback,
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
        },
      );
    }

    if (borderRadius == null) {
      return child;
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: child,
    );
  }

  Widget buildSearchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFFD7E7F5),
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: searchController,
        style: const TextStyle(
          fontFamily: 'intermedium',
          fontSize: 14,
          color: Color(0xFF374151),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: 'Cari program donasi banjir...',
          hintStyle: const TextStyle(
            fontFamily: 'interregular',
            fontSize: 14,
            color: Color(0xFF9CA3AF),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF9CA3AF),
            size: 22,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    searchController.clear();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget featuredCard(DonationProgram program) {
    return GestureDetector(
      onTap: () => openDonationDetail(program),
      child: Container(
        margin: const EdgeInsets.only(bottom: 28),
        height: 232,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.14),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Stack(
          children: [
            programImage(
              image: program.image,
              width: double.infinity,
              height: 232,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.05),
                    Colors.black.withOpacity(0.72),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: lightorange,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text(
                      'TERBARU',
                      style: TextStyle(
                        fontFamily: 'interbold',
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    program.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'jakartabold',
                      color: Colors.white,
                      fontSize: 20,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: donationViewModel.progressValue(program),
                      minHeight: 5,
                      color: lightorange,
                      backgroundColor: Colors.white.withOpacity(0.35),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Terkumpul',
                            style: TextStyle(
                              fontFamily: 'interregular',
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            donationViewModel.formatRupiah(
                              program.collectedAmount,
                            ),
                            style: const TextStyle(
                              fontFamily: 'interbold',
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Target',
                            style: TextStyle(
                              fontFamily: 'interregular',
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            donationViewModel.formatRupiah(
                              program.targetAmount,
                            ),
                            style: const TextStyle(
                              fontFamily: 'interbold',
                              color: Colors.white,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget programListCard(DonationProgram program) {
    final progress = donationViewModel.progressValue(program);
    final percent = (progress * 100).round();

    return GestureDetector(
      onTap: () => openDonationDetail(program),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            programImage(
              image: program.image,
              width: 86,
              height: 86,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'jakartabold',
                      fontSize: 14,
                      height: 1.25,
                      color: Color(0xFF1F2933),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      color: const Color(0xFF4B49B6),
                      backgroundColor: const Color(0xFFEFF2F5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          donationViewModel.formatRupiah(
                            program.collectedAmount,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'intermedium',
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          fontFamily: 'intermedium',
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 34,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Center(
                      child: Text(
                        'DONASI SEKARANG',
                        style: TextStyle(
                          fontFamily: 'interbold',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: lightorange,
                        ),
                      ),
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

  Widget emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 60),
        child: Text(
          'Belum ada program donasi.',
          style: TextStyle(
            fontFamily: 'intermedium',
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget searchEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 60),
        child: Text(
          'Program yang kamu cari tidak ditemukan.',
          style: TextStyle(
            fontFamily: 'intermedium',
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              donationViewModel.errorMessage ?? 'Gagal memuat data donasi',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'intermedium',
                fontSize: 14,
                color: Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: donationViewModel.fetchDonationPrograms,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  final List<DonationProgram> displayedPrograms = filteredProgramsBySearch;

  final DonationProgram? latestProgram =
      displayedPrograms.isEmpty ? null : displayedPrograms.first;

  final List<DonationProgram> otherPrograms = displayedPrograms.length > 1
      ? displayedPrograms.sublist(1)
      : <DonationProgram>[];

  return Scaffold(
    backgroundColor: const Color(0xFFF8FAFC),
    body: SafeArea(
      child: Builder(
        builder: (context) {
          if (donationViewModel.isLoading &&
              donationViewModel.programs.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (donationViewModel.errorMessage != null &&
              donationViewModel.programs.isEmpty) {
            return errorState();
          }

          return RefreshIndicator(
            onRefresh: donationViewModel.fetchDonationPrograms,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bantu Sesama',
                    style: TextStyle(
                      fontFamily: 'jakartaextrabold',
                      fontSize: 28,
                      color: Color(0xFF1F2933),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pilih program donasi aktif untuk membantu pemulihan pasca banjir.',
                    style: TextStyle(
                      fontFamily: 'interregular',
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 24),
                  buildSearchBar(),
                  const SizedBox(height: 28),
                  if (donationViewModel.programs.isEmpty)
                    emptyState()
                  else if (displayedPrograms.isEmpty)
                    searchEmptyState()
                  else ...[
                    if (latestProgram != null) featuredCard(latestProgram),
                    ...otherPrograms.map(programListCard),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}
}