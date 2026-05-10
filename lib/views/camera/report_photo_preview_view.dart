import 'dart:io';
import 'package:floodcare_mobile/views/camera/report_detail_view.dart';
import 'package:flutter/material.dart';

class ReportPhotoPreviewView extends StatelessWidget {
  final String imagePath;

  const ReportPhotoPreviewView({
    super.key,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 28),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 7),
                              Text(
                                'Foto Ulang',
                                style: TextStyle(
                                  fontFamily: 'interbold',
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReportDetailView(
                                imagePath: imagePath,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6A00),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6A00).withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Lanjut isi Laporan',
                                style: TextStyle(
                                  fontFamily: 'interbold',
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 7),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
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
}