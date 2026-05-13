import 'package:flutter/material.dart';
import 'package:floodcare_mobile/models/donation_program_model.dart';
import 'package:floodcare_mobile/services/donation_service.dart';
import 'package:floodcare_mobile/config/api_config.dart';

class DonationViewModel extends ChangeNotifier {
  final DonationService _donationService = DonationService();

  bool isLoading = false;
  String? errorMessage;

  int selectedCategory = 0;

  final List<String> categories = [
    'Semua',
    'Logistik',
    'Kesehatan',
    'Pendidikan',
  ];

  List<DonationProgram> programs = [];

  List<DonationProgram> get filteredPrograms {
    if (selectedCategory == 0) {
      return programs;
    }

    final selected = categories[selectedCategory].toLowerCase();

    return programs.where((program) {
      return program.category.toLowerCase() == selected;
    }).toList();
  }

  List<DonationProgram> get sortedFilteredPrograms {
    final sorted = [...filteredPrograms];

    // id terbesar dianggap program terbaru
    sorted.sort((a, b) => b.id.compareTo(a.id));

    return sorted;
  }

  DonationProgram? get latestProgram {
    if (sortedFilteredPrograms.isEmpty) {
      return null;
    }

    return sortedFilteredPrograms.first;
  }

  List<DonationProgram> get otherPrograms {
    final latest = latestProgram;

    if (latest == null) {
      return [];
    }

    return sortedFilteredPrograms
        .where((program) => program.id != latest.id)
        .toList();
  }

  void setSelectedCategory(int index) {
    selectedCategory = index;
    notifyListeners();
  }

  Future<void> fetchDonationPrograms() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      programs = await _donationService.getDonationPrograms();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> createDonationPayment({
    required int programDonasiId,
    required int amount,
    String? pesan,
    bool isAnonymous = false,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final data = await _donationService.createDonationPayment(
        programDonasiId: programDonasiId,
        amount: amount,
        pesan: pesan,
        isAnonymous: isAnonymous,
      );

      return data;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String formatRupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}';
  }

  double progressValue(DonationProgram program) {
    if (program.targetAmount <= 0) {
      return 0;
    }

    return (program.collectedAmount / program.targetAmount).clamp(0.0, 1.0);
  }

  String fixImageUrl(String image) {
  return ApiConfig.getImageUrl(image);
}
}
