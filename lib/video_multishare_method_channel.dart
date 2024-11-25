import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'video_multishare_platform_interface.dart';

/// An implementation of [VideoMultisharePlatform] that uses method channels.
class MethodChannelVideoMultishare extends VideoMultisharePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final MethodChannel methodChannel =
      const MethodChannel('com.kkaun.video_multi_share');

  Future<bool> _invokePlatformMethod(
      String methodName, String videoPath) async {
    try {
      final result = await methodChannel.invokeMethod<bool>(methodName, {
        'videoPath': videoPath,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint(
          'Error while calling $methodName on native platform: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> shareToInstagramStory(String videoPath) async {
    return _invokePlatformMethod('shareToInstagramStory', videoPath);
  }

  @override
  Future<bool> shareToInstagramReels(String videoPath) async {
    return _invokePlatformMethod('shareToInstagramReels', videoPath);
  }

  @override
  Future<bool> shareToInstagramDirect(String videoPath) async {
    return _invokePlatformMethod('shareToInstagramDirect', videoPath);
  }

  @override
  Future<bool> shareToFacebookPost(String videoPath) async {
    return _invokePlatformMethod('shareToFacebookPost', videoPath);
  }

  @override
  Future<bool> shareToFacebookStory(String videoPath) async {
    return _invokePlatformMethod('shareToFacebookStory', videoPath);
  }

  @override
  Future<bool> shareToYouTubeShorts(String videoPath) async {
    return _invokePlatformMethod('shareToYouTubeShorts', videoPath);
  }

  @override
  Future<bool> shareToTikTok(String videoPath) async {
    return _invokePlatformMethod('shareToTikTok', videoPath);
  }

  @override
  Future<bool> shareToWhatsApp(String videoPath) async {
    return _invokePlatformMethod('shareToWhatsApp', videoPath);
  }

  @override
  Future<bool> shareToSnapchat(String videoPath) async {
    return _invokePlatformMethod('shareToSnapchat', videoPath);
  }
}
