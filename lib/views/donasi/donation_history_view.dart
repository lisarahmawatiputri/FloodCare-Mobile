import 'package:flutter/material.dart';
import 'package:floodcare_mobile/models/donation_history_model.dart';
import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/viewmodels/donation_history_viewmodel.dart';
import 'package:floodcare_mobile/views/donasi/payment_webview.dart';

class DonationHistoryView extends StatefulWidget {
  const DonationHistoryView({super.key});

  @override
  State<DonationHistoryView> createState() => _DonationHistoryViewState();
}

class _DonationHistoryViewState extends State<DonationHistoryView> {
  final DonationHistoryViewModel viewModel = DonationHistoryViewModel();

  @override
  void initState() {
    super.initState();

    viewModel.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    viewModel.fetchDonationHistory();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<void> openPayment(DonationHistory donation) async {
    final snapUrl = donation.snapUrl;

    if (snapUrl == null || snapUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link pembayaran tidak tersedia'),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentWebView(
          snapUrl: snapUrl,
          // title: 'Pembayaran Donasi',
        ),
      ),
    );

    if (!mounted) return;

    await viewModel.refreshPaymentStatus(
      donationId: donation.id,
    );
  }

  Widget statusBadge(DonationHistory donation) {
    final color = viewModel.statusColor(donation.status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        donation.statusLabel,
        style: TextStyle(
          fontFamily: 'interbold',
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget continuePaymentButton(DonationHistory donation) {
    return GestureDetector(
      onTap: viewModel.isCheckingStatus ? null : () => openPayment(donation),
      child: Container(
        height: 42,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: orangeGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6A00).withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: viewModel.isCheckingStatus
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.2,
                  ),
                )
              : const Text(
                  'Lanjutkan Pembayaran',
                  style: TextStyle(
                    fontFamily: 'interbold',
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }

  Widget donationCard(DonationHistory donation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: orangeGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.volunteer_activism_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donation.programTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'jakartabold',
                        fontSize: 14,
                        height: 1.25,
                        color: Color(0xFF1F2933),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      viewModel.formatDate(donation.createdAt),
                      style: const TextStyle(
                        fontFamily: 'interregular',
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              statusBadge(donation),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Nominal',
                  style: TextStyle(
                    fontFamily: 'interregular',
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const Spacer(),
                Text(
                  viewModel.formatRupiah(donation.amount),
                  style: const TextStyle(
                    fontFamily: 'interbold',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2933),
                  ),
                ),
              ],
            ),
          ),

          if (donation.orderId.isNotEmpty) ...[
            const SizedBox(height: 9),
            Text(
              'Order ID: ${donation.orderId}',
              style: const TextStyle(
                fontFamily: 'interregular',
                fontSize: 11,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],

          if (donation.canContinuePayment) ...[
            const SizedBox(height: 14),
            continuePaymentButton(donation),
          ],
        ],
      ),
    );
  }

  Widget emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 90),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 54,
              color: Color(0xFFCBD5E1),
            ),
            SizedBox(height: 14),
            Text(
              'Belum ada riwayat donasi.',
              style: TextStyle(
                fontFamily: 'intermedium',
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              viewModel.errorMessage ?? 'Gagal memuat riwayat donasi',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'intermedium',
                fontSize: 14,
                color: Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: viewModel.fetchDonationHistory,
              child: Container(
                height: 44,
                width: 150,
                decoration: BoxDecoration(
                  gradient: orangeGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6A00).withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Coba Lagi',
                    style: TextStyle(
                      fontFamily: 'interbold',
                      fontSize: 13,
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
    );
  }

  Widget loadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Color(0xFF1F2933),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Riwayat Donasi',
                      style: TextStyle(
                        fontFamily: 'jakartaextrabold',
                        fontSize: 22,
                        color: Color(0xFF1F2933),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Builder(
                builder: (context) {
                  if (viewModel.isLoading && viewModel.histories.isEmpty) {
                    return loadingState();
                  }

                  if (viewModel.errorMessage != null &&
                      viewModel.histories.isEmpty) {
                    return errorState();
                  }

                  if (viewModel.histories.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: viewModel.fetchDonationHistory,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: emptyState(),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: viewModel.fetchDonationHistory,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: viewModel.histories.length,
                      itemBuilder: (context, index) {
                        final donation = viewModel.histories[index];

                        return donationCard(donation);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}