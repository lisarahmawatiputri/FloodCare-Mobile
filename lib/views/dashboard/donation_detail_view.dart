import 'package:flutter/material.dart';
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
  final AuthService authService = AuthService();
  bool isLoading = false;
  int? selectedAmount;
  bool isCustomSelected = false;
  Widget programImage({
  required String image,
  required double width,
  required double height,
}) {
  if (image.isEmpty) {
    return Image.asset(
      'assets/images/donasi1.png',
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
          'assets/images/donasi1.png',
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
  );
}

  final List<int> amounts = [
    10000,
    25000,
    50000,
    100000,
  ];

  String formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}';
  }

  int getFinalAmount() {
    if (isCustomSelected) {
      return int.tryParse(customAmountController.text.replaceAll('.', '')) ?? 0;
    }

    return selectedAmount ?? 0;
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
      pesan: null,
      isAnonymous: false,
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
  void dispose() {
    customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final program = widget.program;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(100),
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back),
              ),

              const SizedBox(height: 22),

              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: programImage(
                  image: widget.program.image,
                  width: double.infinity,
                  height: 190,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                program.title,
                style: const TextStyle(
                  fontFamily: 'jakartabold',
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                program.location,
                style: const TextStyle(
                  fontFamily: 'interregular',
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Pilih Nominal Donasi',
                style: TextStyle(
                  fontFamily: 'interbold',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: amounts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 2.3,
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
                        color: isSelected ? null : const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          formatRupiah(amount),
                          style: TextStyle(
                            fontFamily: 'interbold',
                            fontSize: 15,
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Atau masukkan nominal sendiri',
                style: TextStyle(
                  fontFamily: 'intermedium',
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: customAmountController,
                keyboardType: TextInputType.number,
                onTap: () {
                  setState(() {
                    isCustomSelected = true;
                    selectedAmount = null;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Minimal Rp 10.000',
                  prefixText: 'Rp ',
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 20,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: lightorange,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: Color(0xFFE0E0E0),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              GestureDetector(
                onTap:isLoading ? null : handleContinue,
                child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: orangeGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      isLoading ? "Loading..." : 'Continue',
                      style: const TextStyle(
                        fontFamily: 'interbold',
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