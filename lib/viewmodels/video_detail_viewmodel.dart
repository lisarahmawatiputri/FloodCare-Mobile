import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:floodcare_mobile/config/api_config.dart';
import 'package:floodcare_mobile/models/edukasi_video_model.dart';
import 'package:video_player/video_player.dart';

class VideoDetailViewModel extends ChangeNotifier {
  final EdukasiVideo video;

  VideoDetailViewModel({
    required this.video,
  });

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  bool isInitialized = false;
  bool isLoading = true;
  bool hasError = false;

  Future<void> initPlayer() async {
    final rawVideoUrl = video.videoUrl.trim();

    if (rawVideoUrl.isEmpty) {
      isLoading = false;
      hasError = true;
      notifyListeners();
      return;
    }

    try {
      final videoUrl = ApiConfig.getImageUrl(rawVideoUrl);

      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );

      await videoPlayerController!.initialize();

      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFC65A1E),
          handleColor: const Color(0xFFC65A1E),
          backgroundColor: const Color(0xFFE5E7EB),
          bufferedColor: const Color(0xFFCBD5E1),
        ),
        deviceOrientationsAfterFullScreen: const [
          DeviceOrientation.portraitUp,
        ],
      );

      isInitialized = true;
      hasError = false;
    } catch (e) {
      debugPrint('Error init video: $e');
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    chewieController?.dispose();
    videoPlayerController?.dispose();
    super.dispose();
  }
}