import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'video_multishare_method_channel.dart';

abstract class VideoMultisharePlatform extends PlatformInterface {
  /// Constructs a VideoMultisharePlatform.
  VideoMultisharePlatform() : super(token: _token);

  static const notImplementedErrorDescr =
      ": has not been implemented and/or is not supported for required platform";

  static final Object _token = Object();

  static VideoMultisharePlatform _instance = MethodChannelVideoMultishare();

  /// The default instance of [VideoMultisharePlatform] to use.
  ///
  /// Defaults to [MethodChannelVideoMultishare].
  static VideoMultisharePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VideoMultisharePlatform].
  static set instance(VideoMultisharePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<bool> shareToInstagramStory(String videoPath) {
    throw UnimplementedError(
        'shareToInstagramStory() : $notImplementedErrorDescr');
  }

  Future<bool> shareToInstagramReels(String videoPath) {
    throw UnimplementedError(
        'shareToInstagramReels() : $notImplementedErrorDescr');
  }

  Future<bool> shareToInstagramDirect(String videoPath) {
    throw UnimplementedError(
        'shareToInstagramDirect() : $notImplementedErrorDescr');
  }

  Future<bool> shareToFacebookPost(String videoPath) {
    throw UnimplementedError(
        'shareToFacebookPost() : $notImplementedErrorDescr');
  }

  Future<bool> shareToFacebookStory(String videoPath) {
    throw UnimplementedError(
        'shareToFacebookStory() : $notImplementedErrorDescr');
  }

  Future<bool> shareToYouTubeShorts(String videoPath) {
    throw UnimplementedError(
        'shareToYouTubeShorts() : $notImplementedErrorDescr');
  }

  Future<bool> shareToTikTok(String videoPath) {
    throw UnimplementedError('shareToTikTok() : $notImplementedErrorDescr');
  }

  Future<bool> shareToWhatsApp(String videoPath) {
    throw UnimplementedError('shareToWhatsApp() : $notImplementedErrorDescr');
  }

  Future<bool> shareToSnapchat(String videoPath) {
    throw UnimplementedError('shareToSnapchat() : $notImplementedErrorDescr');
  }
}
