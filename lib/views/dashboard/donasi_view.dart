import 'package:flutter/material.dart';
import 'package:floodcare_mobile/models/donation_program_model.dart';
import 'package:floodcare_mobile/services/auth_service.dart';
import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/views/dashboard/donation_detail_view.dart';

class DonasiView extends StatefulWidget {
  const DonasiView({super.key});

  @override
  State<DonasiView> createState() => _DonasiViewState();
}

class _DonasiViewState extends State<DonasiView> {
  int selectedCategory = 0;
 Widget programImage({
  required String image,
  required double width,
  required double height,
}) {
  const fallback = 'assets/images/donasi1.png';

  if (image.isEmpty) {
    return Image.asset(
      fallback,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }

  String fixedUrl = image;

  if (fixedUrl.startsWith('http://127.0.0.1:8000')) {
    fixedUrl = fixedUrl.replaceFirst(
      'http://127.0.0.1:8000',
      'http://10.0.2.2:8000',
    );
  } else if (!fixedUrl.startsWith('http://') &&
      !fixedUrl.startsWith('https://')) {
    fixedUrl = 'http://10.0.2.2:8000/storage/$fixedUrl';
  }

  return Image.network(
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

  final List<String> categories = [
    "Semua",
    "Logistik",
    "Kesehatan",
    "Pendidikan",
  ];

  late Future<List<DonationProgram>> programsFuture;

  @override
  void initState() {
    super.initState();
    programsFuture = AuthService().getDonationPrograms();
  }
  void refreshPrograms() {
    setState(() {
      programsFuture = AuthService().getDonationPrograms();
    });
  }
  String formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FutureBuilder<List<DonationProgram>>(
          future: programsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: refreshPrograms,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final programs = snapshot.data ?? [];

            final emergency =
                programs.where((e) => e.isEmergency).toList();
            final normal =
                programs.where((e) => !e.isEmergency).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Bantu Sesama",
                    style: TextStyle(
                      fontFamily: 'jakartaextrabold',
                      fontSize: 28,
                      color: Color(0xFF1F2933),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Pilih program donasi aktif untuk membantu pemulihan pasca banjir.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // CATEGORY
                  SizedBox(
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
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? lightorange
                                  : Colors.white,
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            child: Text(
                              categories[index],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  ...emergency.map((program) {
                    return GestureDetector(
                     onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DonationDetailView(program: program),
                          ),
                        );

                        if (!mounted) return;
                          refreshPrograms();

                        setState(() {
                          programsFuture = AuthService().getDonationPrograms();
                        });
                      },
                     child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        height: 240,
                        child: Stack(
                          children: [
                            programImage(
                              image: program.image,
                              width: double.infinity,
                              height: 240,
                            ),

                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),

                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 16,
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    color: Colors.red,
                                    child: const Text(
                                      "DARURAT",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  Text(
                                    program.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  LinearProgressIndicator(
                                    value: (program.collectedAmount /
                                            program.targetAmount)
                                        .clamp(0.0, 1.0),
                                    color: lightorange,
                                  ),

                                  const SizedBox(height: 6),

                                  Row(
                                    children: [
                                      Text(
                                        formatRupiah(
                                            program.collectedAmount),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      const Spacer(),
                                      Text(
                                        formatRupiah(
                                            program.targetAmount),
                                        style: const TextStyle(
                                            color: Colors.white),
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
                  }),

                  // 🔥 NORMAL LIST
                  ...normal.map((program) {
                    return ListTile(
                      title: Text(program.title),
                      subtitle: Text(
                          formatRupiah(program.collectedAmount)),
                      trailing: const Text("Donasi"),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DonationDetailView(program: program),
                          ),
                        );

                        if (!mounted) return;

                        refreshPrograms();
                      },
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}