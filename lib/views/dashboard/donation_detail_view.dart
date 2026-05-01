import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:floodcare_mobile/models/donation_program_model.dart';
import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/services/auth_service.dart';
import 'package:floodcare_mobile/views/dashboard/payment_webview.dart';

class DonationDetailView extends StatefulWidget {
  final DonationProgram program;

  const DonationDetailView({
    super.key,
    required this.program,
  });

  @override
  State<DonationDetailView> createState() => _DonationDetailViewState();
}

class _DonationDetailViewState extends State<DonationDetailView> {
  final customAmountController = TextEditingController();
  final messageController = TextEditingController();

  final AuthService authService = AuthService();

  bool isLoading = false;
  bool isAnonymous = false;
  bool isCustomSelected = false;

  int? selectedAmount;

  final List<int> amounts = [
    10000,
    25000,
    50000,
    100000,
  ];

  @override
  void dispose() {
    customAmountController.dispose();
    messageController.dispose();
    super.dispose();
  }

  String formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  int getFinalAmount() {
    if (isCustomSelected) {
      final raw = customAmountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(raw) ?? 0;
    }

    return selectedAmount ?? 0;
  }

  Widget programImage({
    required String image,
    required double width,
    required double height,
  }) {
    const defaultImage = 'assets/images/donasi1.png';

    if (image.isEmpty) {
      return Image.asset(
        defaultImage,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return Image.network(
        image,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Image.asset(
            defaultImage,
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
        },
      );
    }

    return Image.asset(
      image,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Image.asset(
          defaultImage,
          width: width,
          height: height,
          fit: BoxFit.cover,
        );
      },
    );
  }

  Future<void> handleContinue() async {
    final amount = getFinalAmount();

    if (amount < 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal donasi adalah Rp 10.000'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final data = await authService.createDonationPayment(
        programDonasiId: widget.program.id,
        amount: amount,
        pesan: messageController.text.trim().isEmpty
            ? null
            : messageController.text.trim(),
        isAnonymous: isAnonymous,
      );

      final snapUrl = data['snap_url'];

      if (snapUrl == null) {
        throw Exception('Snap URL tidak ditemukan');
      }

      if (!mounted) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebView(snapUrl: snapUrl),
        ),
      );

      if (!mounted) return;

      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran berhasil')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran sedang diproses')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final program = widget.program;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.arrow_back,
                      size: 26,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              // CARD PROGRAM
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: programImage(
                        image: program.image,
                        width: 88,
                        height: 88,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'DARURAT BANJIR',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFFF4B3E),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            program.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.25,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2933),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              const Text(
                'Pilih Nominal Donasi',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2933),
                ),
              ),

              const SizedBox(height: 14),

              // NOMINAL GRID
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: amounts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.05,
                ),
                itemBuilder: (context, index) {
                  final amount = amounts[index];
                  final isSelected =
                      selectedAmount == amount && !isCustomSelected;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedAmount = amount;
                        isCustomSelected = false;
                        customAmountController.clear();
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isSelected ? orangeGradient : null,
                        color: isSelected ? null : Colors.white,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : const Color(0xFFD6E3EA),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          formatRupiah(amount),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF263238),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 22),

              const Text(
                'Nominal Lainnya',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5D4037),
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: customAmountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onTap: () {
                  setState(() {
                    isCustomSelected = true;
                    selectedAmount = null;
                  });
                },
                decoration: InputDecoration(
                  prefixText: 'Rp  ',
                  hintText: 'Min. 10.000',
                  prefixStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6B7280),
                  ),
                  hintStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6B7280),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 19,
                    horizontal: 16,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: const BorderSide(
                      color: Color(0xFFD6E3EA),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(7),
                    borderSide: BorderSide(
                      color: lightorange,
                      width: 1.8,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // PESAN DUKUNGAN
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE0E1FF),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 17,
                          color: Color(0xFF5364C8),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Tulis Pesan Dukungan (Opsional)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF5364C8),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    TextFormField(
                      controller: messageController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            'Tulis doa atau kata-kata penyemangat\nuntuk korban banjir...',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFA5B0C2),
                          height: 1.4,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.65),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        SizedBox(
                          width: 22,
                          height: 22,
                          child: Checkbox(
                            value: isAnonymous,
                            activeColor: lightorange,
                            side: const BorderSide(
                              color: Color(0xFFD1D5DB),
                            ),
                            onChanged: (value) {
                              setState(() {
                                isAnonymous = value ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Donasi sebagai anonim',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5F6368),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // INFO BOX
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDEBF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFFFF7A1A),
                      size: 21,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Donasi Anda akan disalurkan 100% untuk pengadaan buku, alat tulis, dan fasilitas belajar darurat bagi siswa terdampak banjir.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.55,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              GestureDetector(
                onTap: isLoading ? null : handleContinue,
                child: Container(
                  height: 58,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: orangeGradient,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Text(
                      isLoading ? 'Loading...' : 'Lanjutkan Donasi',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}