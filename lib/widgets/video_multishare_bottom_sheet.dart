import 'dart:io';
import 'package:flutter/material.dart';

import 'package:video_multishare/share_methods/share_methods.dart';

class VideoMultiShareBottomSheet extends StatelessWidget {
  final String videoPath;

  /// Callback to send the result message back to the consumer app.
  final void Function(String message) onShareResult;

  const VideoMultiShareBottomSheet({
    super.key,
    required this.videoPath,
    required this.onShareResult,
  });

  void _share(
      BuildContext context, Future<bool> Function(String) shareMethod) async {
    final navigator = Navigator.of(context);
    try {
      final success = await shareMethod(videoPath);
      final message = success
          ? "Video is successfully composed. Sharing is progress..."
          : "Failed to share the video to the selected platform";
      if (navigator.mounted) {
        navigator.pop();
      }
      onShareResult(message);
    } catch (e) {
      if (navigator.mounted) {
        navigator.pop();
      }
      onShareResult("An error occurred: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final shareMethods =
        Platform.isAndroid ? androidShareMethods : iosShareMethods;
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, // Align title to the left
        children: [
          const Text(
            "Share Video",
            style: TextStyle(
              fontSize: 20, // Slightly bigger font size
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16.0, // Space between elements horizontally
              runSpacing: 16.0, // Space between rows
              children: shareMethods.map((method) {
                return SizedBox(
                  width: 62,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => _share(context,
                            method["method"] as Future<bool> Function(String)),
                        child: CircleAvatar(
                          radius: 30,
                          child: Icon(method["icon"] as IconData, size: 30),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        method["label"] as String,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
