import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class TestExportScreen extends StatefulWidget {
  const TestExportScreen({super.key, required this.file, required this.cover});
  final XFile file;
  final XFile cover;

  @override
  State<TestExportScreen> createState() => _TestExportScreenState();
}

class _TestExportScreenState extends State<TestExportScreen> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.file.path));
    _controller.initialize().then((_) {
      _controller.play();
      _controller.setLooping(true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, value, child) {
              return (_controller.value.isInitialized)
                  ? Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator());
            },
          ),
          const SizedBox(height: 10),
          Image.file(
            File(widget.cover.path),
            fit: BoxFit.fitHeight,
            height: 100,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
