import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:floodcare_mobile/models/edukasi_video_model.dart';
import 'package:floodcare_mobile/utils/colors.dart';
import 'package:floodcare_mobile/viewmodels/video_detail_viewmodel.dart';

class VideoDetailPage extends StatefulWidget {
  final EdukasiVideo video;

  const VideoDetailPage({
    super.key,
    required this.video,
  });

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late final VideoDetailViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = VideoDetailViewModel(video: widget.video);
    viewModel.initPlayer();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;

    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
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
          body: Column(
            children: [
              Container(
                color: Colors.black,
                width: double.infinity,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: viewModel.isInitialized &&
                          viewModel.chewieController != null
                      ? Chewie(controller: viewModel.chewieController!)
                      : viewModel.hasError
                          ? _buildErrorPlayer()
                          : _buildLoadingPlayer(),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1F2933),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
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
                                video.date,
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
                      if (video.description.isNotEmpty) ...[
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
                          video.description,
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
        );
      },
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