import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:floodcare_mobile/views/camera/report_photo_preview_view.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView>
    with SingleTickerProviderStateMixin {
  CameraController? cameraController;
  List<CameraDescription> cameras = [];

  bool isCameraReady = false;
  bool isTakingPicture = false;
  String? errorMessage;

  late AnimationController scanController;

  @override
  void initState() {
    super.initState();

    scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat();

    initCamera();
  }

  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();

      if (cameras.isEmpty) {
        if (!mounted) return;

        setState(() {
          errorMessage = 'Kamera tidak ditemukan';
          isCameraReady = false;
        });
        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await cameraController!.initialize();

      if (!mounted) return;

      setState(() {
        isCameraReady = true;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Gagal membuka kamera:\n$e';
        isCameraReady = false;
      });
    }
  }

      Future<void> takePicture() async {
      if (cameraController == null ||
          !cameraController!.value.isInitialized ||
          isTakingPicture) {
        return;
      }

      try {
        setState(() {
          isTakingPicture = true;
        });

        final image = await cameraController!.takePicture();

        if (!mounted) return;

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportPhotoPreviewView(
              imagePath: image.path,
            ),
          ),
        );

        if (!mounted) return;

        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lanjut ke form laporan'),
            ),
          );

          // Nanti di sini bisa diarahkan ke form laporan:
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => ReportFormView(imagePath: result),
          //   ),
          // );
        }
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: $e'),
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            isTakingPicture = false;
          });
        }
      }
    }

  @override
  void dispose() {
    cameraController?.dispose();
    scanController.dispose();
    super.dispose();
  }

  Widget cameraPreview() {
    if (errorMessage != null) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Text(
          errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.4,
            fontFamily: 'intermedium',
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (!isCameraReady || cameraController == null) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final cameraSize = cameraController!.value.previewSize!;

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: cameraSize.height,
          height: cameraSize.width,
          child: CameraPreview(cameraController!),
        ),
      ),
    );
  }

  Widget scannerFrame() {
    const double frameWidth = 260;
    const double frameHeight = 250;

    const double stripWidth = 220;
    const double stripHeight = 42;

    const double minTop = 18;
    const double maxTop = 190;

    return Center(
      child: SizedBox(
        width: frameWidth,
        height: frameHeight,
        child: Stack(
          children: [
            const ScannerCorner(
              alignment: Alignment.topLeft,
              top: true,
              left: true,
            ),
            const ScannerCorner(
              alignment: Alignment.topRight,
              top: true,
              left: false,
            ),
            const ScannerCorner(
              alignment: Alignment.bottomLeft,
              top: false,
              left: true,
            ),
            const ScannerCorner(
              alignment: Alignment.bottomRight,
              top: false,
              left: false,
            ),
            AnimatedBuilder(
              animation: scanController,
              builder: (context, child) {
                final double t = scanController.value;

                bool isVisible = false;
                bool movingDown = true;
                double topPosition = minTop;
                double fadeProgress = 0.0;

                if (t >= 0.0 && t < 0.42) {
                  // turun dari atas ke bawah
                  final progress = t / 0.42;
                  isVisible = true;
                  movingDown = true;
                  topPosition = minTop + ((maxTop - minTop) * progress);
                  fadeProgress = progress;
                } else if (t >= 0.50 && t < 0.92) {
                  // naik dari bawah ke atas
                  final progress = (t - 0.50) / 0.42;
                  isVisible = true;
                  movingDown = false;
                  topPosition = maxTop - ((maxTop - minTop) * progress);
                  fadeProgress = progress;
                }

                if (!isVisible) {
                  return const SizedBox.shrink();
                }

                // awalnya terang, lalu pelan-pelan hilang
                final double opacity = (1.0 - fadeProgress).clamp(0.0, 1.0);

                return Positioned(
                  top: topPosition,
                  left: (frameWidth - stripWidth) / 2,
                  child: Opacity(
                    opacity: opacity,
                    child: Container(
                      width: stripWidth,
                      height: stripHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          begin: movingDown
                              ? Alignment.topCenter
                              : Alignment.bottomCenter,
                          end: movingDown
                              ? Alignment.bottomCenter
                              : Alignment.topCenter,
                          colors: [
                            const Color(0xFFFF6A00).withOpacity(0.85),
                            const Color(0xFFFF6A00).withOpacity(0.35),
                            const Color(0xFFFF6A00).withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget topBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 18, top: 12, right: 18),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomControls() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 108,
        color: const Color(0xFFE8E8E8),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                controlSmallButton(
                  icon: Icons.camera_alt_outlined,
                  onTap: () {},
                ),
                GestureDetector(
                  onTap: takePicture,
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFD9D9D9),
                        width: 4,
                      ),
                    ),
                    child: isTakingPicture
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.black54,
                            ),
                          )
                        : null,
                  ),
                ),
                controlSmallButton(
                  icon: Icons.mail_outline_rounded,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget controlSmallButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFF2F2F2F),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [cameraPreview(), scannerFrame(), topBar(), bottomControls()],
      ),
    );
  }
}

class ScannerCorner extends StatelessWidget {
  final Alignment alignment;
  final bool top;
  final bool left;

  const ScannerCorner({
    super.key,
    required this.alignment,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: SizedBox(
        width: 58,
        height: 58,
        child: Stack(
          children: [
            Positioned(
              top: top ? 0 : null,
              bottom: top ? null : 0,
              left: left ? 0 : null,
              right: left ? null : 0,
              child: Container(
                width: 38,
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6A00),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Positioned(
              top: top ? 0 : null,
              bottom: top ? null : 0,
              left: left ? 0 : null,
              right: left ? null : 0,
              child: Container(
                width: 6,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6A00),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
