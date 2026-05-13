import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:floodcare_mobile/utils/colors.dart';

class VideoDetailPage extends StatefulWidget {
  final Map<String, dynamic> video;

  const VideoDetailPage({super.key, required this.video});

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool isInitialized = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final videoUrl = widget.video['video_url']?.toString() ?? '';
    if (videoUrl.isEmpty) {
      setState(() => hasError = true);
      return;
    }

    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: _buildThumbnail(),
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFC65A1E),
          handleColor: const Color(0xFFC65A1E),
          backgroundColor: const Color(0xFFE5E7EB),
          bufferedColor: const Color(0xFFCBD5E1),
        ),
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
        ],
      );

      setState(() => isInitialized = true);
    } catch (e) {
      debugPrint('Error init video: $e');
      setState(() => hasError = true);
    }
  }

  Widget _buildThumbnail() {
    final thumbnail = widget.video['thumbnail']?.toString() ?? '';
    if (thumbnail.startsWith('http')) {
      return Image.network(
        thumbnail,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderThumb(),
      );
    }
    return _placeholderThumb();
  }

  Widget _placeholderThumb() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Icon(Icons.play_circle_outline, color: Colors.white54, size: 64),
      ),
    );
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.video['title']?.toString() ?? 'Tanpa Judul';
    final description = widget.video['description']?.toString() ?? '';
    final date = widget.video['date']?.toString() ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          Container(
            color: Colors.black,
            width: double.infinity,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: isInitialized
                  ? Chewie(controller: _chewieController!)
                  : hasError
                      ? _buildErrorPlayer()
                      : _buildLoadingPlayer(),
            ),
          ),

          // --- KONTEN BAWAH ---
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1F2933),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // FloodCare branding + tanggal
                  Row(
                    children: [
                      // Logo/avatar FloodCare
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: orangeGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'FC',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'FloodCare',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2933),
                            ),
                          ),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 14),
                    const Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2933),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      // AppBar custom di atas video
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Video Edukasi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingPlayer() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFFC65A1E)),
      ),
    );
  }

  Widget _buildErrorPlayer() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.white54, size: 48),
            SizedBox(height: 8),
            Text(
              'Video tidak dapat diputar',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}