import 'dart:io';
import 'package:flutter/material.dart';

import 'video_multishare_platform_interface.dart';
import 'widgets/video_multishare_bottom_sheet.dart';

class VideoMultishare {
  /// Displays the share options bottom sheet
  /// with further share process on option press.
  static Future<void> requestShareOptions({
    required BuildContext context,
    required String videoPath,
    required void Function(String message) onShareResult,
  }) async {
    final isValid = await VideoMultishare.isVideoLengthValid(videoPath);
    if (videoPath.isEmpty ||
        !videoPath.toLowerCase().contains(".mp4") ||
        isValid) {
      onShareResult("Please select a valid video/.mp4 file to share");
    } else {
      showModalBottomSheet(
        context: context,
        builder: (_) => VideoMultiShareBottomSheet(
          videoPath: videoPath,
          onShareResult: onShareResult,
        ),
        isScrollControlled: true,
      );
    }
  }

  /// Checks if the video length is not more than 60 seconds.
  static Future<bool> isVideoLengthValid(String videoPath) async {
    try {
      final result = await Process.run(
        'ffprobe',
        [
          '-v',
          'error',
          '-show_entries',
          'format=duration',
          '-of',
          'default=noprint_wrappers=1:nokey=1',
          videoPath
        ],
      );

      if (result.exitCode == 0) {
        final duration = double.tryParse(result.stdout.toString().trim());
        return duration != null && duration <= 60.0;
      } else {
        return false; // ffprobe failed to retrieve video duration
      }
    } catch (e) {
      return false; // Error occurred during execution
    }
  }

  /// Shares a video to Instagram Story.
  static Future<bool> shareToInstagramStory(String videoPath) {
    return VideoMultisharePlatform.instance.shareToInstagramStory(videoPath);
  }

  /// Shares a video to Instagram Reels (still, with Instagram options restriction).
  static Future<bool> shareToInstagramReels(String videoPath) {
    return VideoMultisharePlatform.instance.shareToInstagramReels(videoPath);
  }

  /// Shares a video to Instagram Direct (still, with Instagram options restriction).
  static Future<bool> shareToInstagramDirect(String videoPath) {
    return VideoMultisharePlatform.instance.shareToInstagramDirect(videoPath);
  }

  /// Shares a video to Facebook Post.
  static Future<bool> shareToFacebookPost(String videoPath) {
    return VideoMultisharePlatform.instance.shareToFacebookPost(videoPath);
  }

  /// Shares a video to Facebook Story.
  static Future<bool> shareToFacebookStory(String videoPath) {
    return VideoMultisharePlatform.instance.shareToFacebookStory(videoPath);
  }

  /// Shares a video to YouTube Shorts.
  static Future<bool> shareToYouTubeShorts(String videoPath) {
    return VideoMultisharePlatform.instance.shareToYouTubeShorts(videoPath);
  }

  /// Shares a video to TikTok.
  static Future<bool> shareToTikTok(String videoPath) {
    return VideoMultisharePlatform.instance.shareToTikTok(videoPath);
  }

  /// Shares a video to WhatsApp.
  static Future<bool> shareToWhatsApp(String videoPath) {
    return VideoMultisharePlatform.instance.shareToWhatsApp(videoPath);
  }

  /// Shares a video to Snapchat.
  static Future<bool> shareToSnapchat(String videoPath) {
    return VideoMultisharePlatform.instance.shareToSnapchat(videoPath);
  }
}
