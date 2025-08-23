import 'package:flutter/material.dart';
import 'package:video_editor_example/cover_screen.dart';
import 'package:video_editor_example/editor_next_button.dart';
import 'package:video_editor_plus/video_editor.dart';

class TrimmerScreen extends StatelessWidget {
  const TrimmerScreen({super.key, required this.controller});
  final VideoEditorController controller;
  final int cropGridViewerKey = 0;

  String _formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

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
        actions: [
          ValueListenableBuilder(
              valueListenable: controller.video,
              builder: (context, value, child) {
                return Row(
                  children: [
                    const SizedBox(width: 20),
                    Text(_formatter(controller.startTrim), style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 18),
                    AnimatedBuilder(
                      animation: Listenable.merge([controller, controller.video]),
                      builder: (_, __) {
                        final duration = controller.videoDuration.inSeconds;
                        final pos = controller.trimPosition * duration;
                        return Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                            child: (pos.isFinite)
                                ? Text(
                                    _formatter(Duration(seconds: pos.toInt())),
                                    style: const TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 18),
                    Text(_formatter(controller.endTrim), style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 20),
                  ],
                );
              }),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ValueListenableBuilder(
            valueListenable: controller.video,
            builder: (context, value, child) {
              return (controller.initialized)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: 9 / 16,
                                child: CropGridViewer.preview(
                                  key: ValueKey(cropGridViewerKey),
                                  controller: controller,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 24),
                                  child: TrimSlider(
                                    controller: controller,
                                    height: 60,
                                    horizontalMargin: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 60,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([controller, controller.video]),
                            builder: (_, __) {
                              return Row(
                                children: [
                                  const SizedBox(width: 24),
                                  ValueListenableBuilder(
                                    valueListenable: controller.video,
                                    builder: (context, value, child) {
                                      return value.isPlaying
                                          ? GestureDetector(
                                              onTap: () => controller.video.pause(),
                                              child: const Icon(Icons.pause_rounded, size: 32),
                                            )
                                          : GestureDetector(
                                              onTap: () => controller.video.play(),
                                              child: const Icon(Icons.play_arrow_rounded, size: 32),
                                            );
                                    },
                                  ),
                                  const SizedBox(width: 32),
                                  const Spacer(),
                                  ValueListenableBuilder(
                                    valueListenable: controller.video,
                                    builder: (context, value, child) {
                                      return Text(
                                        "${controller.endTrim.inSeconds - controller.startTrim.inSeconds}s",
                                        style: const TextStyle(color: Colors.white60),
                                      );
                                    },
                                  ),
                                  const Spacer(),
                                  EditorNextButton(onPressed: () => _onNextPressed(context)),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3));
            },
          ),
        ),
      ),
    );
  }

  void _onNextPressed(BuildContext context) {
    controller.video.pause();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CoverScreen(controller: controller),
      ),
    );
  }
}
