import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:floodcare_mobile/views/camera/report_location_view.dart';
import 'package:floodcare_mobile/utils/colors.dart';

class ReportDetailView extends StatefulWidget {
  final String imagePath;

  const ReportDetailView({
    super.key,
    required this.imagePath,
  });

  @override
  State<ReportDetailView> createState() => _ReportDetailViewState();
}

class _ReportDetailViewState extends State<ReportDetailView> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final manualWaterLevelController = TextEditingController();

  String selectedWaterLevel = '30-80';

  final List<String> waterLevels = [
    '<30',
    '30-80',
    '80-150',
    '>150',
  ];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    manualWaterLevelController.dispose();
    super.dispose();
  }

  void handleContinue() {
    FocusScope.of(context).unfocus();

    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul laporan wajib diisi')),
      );
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi kejadian wajib diisi')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportLocationView(
          imagePath: widget.imagePath,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          waterLevel: selectedWaterLevel,
          manualWaterLevel: manualWaterLevelController.text.trim().isEmpty
              ? null
              : manualWaterLevelController.text.trim(),
        ),
      ),
    );
  }

  Widget stepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          stepItem(
            number: '✓',
            label: 'UNGGAH',
            isActive: false,
            isDone: true,
          ),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 22),
              color: const Color(0xFFE5EAF0),
            ),
          ),
          stepItem(
            number: '2',
            label: 'DETAIL',
            isActive: true,
            isDone: false,
          ),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 22),
              color: const Color(0xFFE5EAF0),
            ),
          ),
          stepItem(
            number: '3',
            label: 'LOKASI',
            isActive: false,
            isDone: false,
          ),
        ],
      ),
    );
  }

  Widget stepItem({
    required String number,
    required String label,
    required bool isActive,
    required bool isDone,
  }) {
    final Color activeColor = const Color(0xFFFF6A00);
    final Color inactiveBorder = const Color(0xFFDDE6EE);
    final Color inactiveText = const Color(0xFFB3BDC9);

    return Column(
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive || isDone ? activeColor : inactiveBorder,
              width: 1.6,
            ),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontFamily: 'interbold',
                fontSize: isDone ? 20 : 15,
                color: isActive ? Colors.white : activeColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'interbold',
            fontSize: 10,
            letterSpacing: 0.4,
            color: isActive || isDone ? activeColor : inactiveText,
          ),
        ),
      ],
    );
  }

  Widget imagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        children: [
          Image.file(
            File(widget.imagePath),
            width: double.infinity,
            height: 205,
            fit: BoxFit.cover,
          ),
          Positioned(
            right: 14,
            bottom: 14,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_rounded,
                      size: 15,
                      color: Color(0xFF4B5563),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Ganti Foto',
                      style: TextStyle(
                        fontFamily: 'interbold',
                        fontSize: 12,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget inputLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'interbold',
        fontSize: 14,
        color: Color(0xFF374151),
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget textInput({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontFamily: 'interregular',
        fontSize: 14,
        color: Color(0xFF1F2937),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'interregular',
          fontSize: 14,
          color: Color(0xFFA8B3C3),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 18 : 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(3),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget waterLevelButton(String value) {
    final bool isSelected = selectedWaterLevel == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedWaterLevel = value;
        });
      },
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF6A00) : const Color(0xFFE1E8EF),
            width: isSelected ? 1.8 : 1.2,
          ),
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'interbold',
              fontSize: 14,
              color: isSelected
                  ? const Color(0xFFB64B16)
                  : const Color(0xFF374151),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget waterLevelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        inputLabel('Tinggi air (cm)'),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: waterLevels.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3.8,
          ),
          itemBuilder: (context, index) {
            return waterLevelButton(waterLevels[index]);
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text(
              'Lainnya:',
              style: TextStyle(
                fontFamily: 'intermedium',
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextFormField(
                  controller: manualWaterLevelController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: const TextStyle(
                    fontFamily: 'interregular',
                    fontSize: 13,
                    color: Color(0xFF1F2937),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Input manual',
                    hintStyle: const TextStyle(
                      fontFamily: 'interregular',
                      fontSize: 13,
                      color: Color(0xFFA8B3C3),
                    ),
                    suffixText: 'cm',
                    suffixStyle: const TextStyle(
                      fontFamily: 'intermedium',
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3),
                      borderSide: const BorderSide(
                        color: Color(0xFFE1E8EF),
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(3),
                      borderSide: const BorderSide(
                        color: Color(0xFFFF6A00),
                        width: 1.6,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectedWaterLevel = 'manual';
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget formCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          inputLabel('Judul Laporan'),
          const SizedBox(height: 10),
          textInput(
            controller: titleController,
            hint: 'Contoh: Banjir selutut di depan pos',
          ),
          const SizedBox(height: 24),
          inputLabel('Deskripsi Kejadian'),
          const SizedBox(height: 10),
          textInput(
            controller: descriptionController,
            hint: 'Ceritakan detail kejadian...',
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          waterLevelSection(),
        ],
      ),
    );
  }

  Widget continueButton() {
    return GestureDetector(
      onTap: handleContinue,
      child: Container(
        height: 58,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: orangeGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6A00).withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Lanjut ke Lokasi',
            style: TextStyle(
              fontFamily: 'interbold',
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomNote() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 28),
      child: Text(
        'Pastikan data yang Anda masukkan sudah benar\nsebelum melanjutkan ke pemilihan lokasi.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'interregular',
          fontSize: 12,
          height: 1.6,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 18, 28, 30),
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
                    size: 25,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              const SizedBox(height: 34),
              stepIndicator(),
              const SizedBox(height: 30),
              imagePreview(),
              formCard(),
              const SizedBox(height: 30),
              continueButton(),
              const SizedBox(height: 16),
              bottomNote(),
            ],
          ),
        ),
      ),
    );
  }
}