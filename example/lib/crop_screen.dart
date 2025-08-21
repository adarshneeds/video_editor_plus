import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_editor_example/trimmer_screen.dart';
import 'package:video_editor_plus/video_editor.dart';

class CropScreen extends StatefulWidget {
  const CropScreen({super.key, required this.file});
  final XFile file;

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  late final VideoEditorController _controller;

  @override
  void initState() {
    super.initState();
    // Controller initialization
    _controller = VideoEditorController.file(
      widget.file,
      minDuration: const Duration(seconds: 1),
      maxDuration: const Duration(seconds: 40),
      trimStyle: const TrimSliderStyle(
        edgesSize: 24,
        borderRadius: 12.0,
        leftIcon: Icons.drag_indicator_outlined,
        rightIcon: Icons.drag_indicator_outlined,
        iconColor: Colors.black87,
        onTrimmedColor: Colors.white,
        onTrimmingColor: Colors.white,
        background: Colors.transparent,
      ),
      cropStyle: const CropGridStyle(),
      coverStyle: const CoverSelectionStyle(
        selectedBorderColor: Colors.yellow,
      ),
    );
    _controller.initialize().then((_) {
      // Set preferred crop aspect ratio
      _controller.preferredCropAspectRatio = Fraction.fromString("9/16").toDouble();
      _controller.video.play();
    }).catchError((error) {
      if (mounted) Navigator.pop(context);
    }, test: (e) => e is VideoMinDurationError);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 60,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 21),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ValueListenableBuilder(
              valueListenable: _controller.video,
              builder: (context, value, child) {
                return (_controller.initialized)
                    ? Column(
                        children: [
                          Expanded(
                            child: CropGridViewer.edit(
                              controller: _controller,
                              rotateCropArea: false,
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                            ),
                          ),
                          const SizedBox(height: 12),
                          NextButton(onPressed: () => _onNextPressed(context)),
                        ],
                      )
                    : const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3));
              }),
        ),
      ),
    );
  }

  void _onNextPressed(BuildContext context) {
    // Validate crop parameters set in the crop view
    _controller.applyCacheCrop();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrimmerScreen(controller: _controller),
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  const NextButton({super.key, required this.onPressed});
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.only(left: 28, right: 16, top: 10, bottom: 10),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black),
          label: const Text("Next", style: TextStyle(color: Colors.black)),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
