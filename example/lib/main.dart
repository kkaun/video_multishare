// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_multishare/video_multishare.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Multishare Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const VideoShareScreen(),
    );
  }
}

class VideoShareScreen extends StatefulWidget {
  const VideoShareScreen({super.key});

  @override
  _VideoShareScreenState createState() => _VideoShareScreenState();
}

class _VideoShareScreenState extends State<VideoShareScreen> {
  String? _pickedVideoPath;

  void _pickVideo() async {
    // Pick a file with a restriction to video/mp4 only
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedVideoPath = result.files.single.path!;
      });
      _showMessageSnackbar("Video is picked successfully");
    } else {
      _showMessageSnackbar("No video selected or invalid format");
    }
  }

  void _shareVideo(BuildContext context) async {
    // An example of plugin usage.
    // The focus is being made on basic internal plugin video validation,
    // rather then doing it in-app, in order to preserve minimalistic approach:
    await VideoMultishare.requestShareOptions(
      context: context,
      videoPath: _pickedVideoPath ?? "",
      onShareResult: (message) {
        _showMessageSnackbar(message);
      },
    );
  }

  void _showMessageSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Multishare Test")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _pickVideo,
              child: const Text("Pick a Video"),
            ),
            const SizedBox(height: 16),
            if (_pickedVideoPath != null) ...[
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  "Picked Video Path: $_pickedVideoPath",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: () => _shareVideo(context),
              child: const Text("Share"),
            ),
          ],
        ),
      ),
    );
  }
}
