import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_editor_example/editor_next_button.dart';
import 'package:video_editor_example/test_export_screen.dart';
import 'package:video_editor_plus/video_editor.dart';

class CoverScreen extends StatelessWidget {
  const CoverScreen({super.key, required this.controller});
  final VideoEditorController controller;

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
              valueListenable: controller.selectedCoverNotifier,
              builder: (context, value, child) {
                if (value == null) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3));
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 9 / 16,
                        child: CoverViewer(controller: controller),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      height: 120,
                      child: CoverSelection(
                        controller: controller,
                        size: 120,
                        quantity: 4,
                        quality: 30,
                        selectedCoverBuilder: (cover, size) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              cover,
                              const Icon(
                                Icons.check_circle,
                                color: Colors.yellow,
                              )
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    EditorNextButton(onPressed: () => _onNextPressed(context)),
                  ],
                );
              }),
        ),
      ),
    );
  }

  Future<void> _onNextPressed(BuildContext context) async {
    final XFile file = await ExportServices.exportVideo(
        controller: controller,
        onProgress: (progress) {
          // You can use this progress value to show a progress indicator if needed
          debugPrint('Export Video Progress: $progress%');
        });
    final XFile cover = await ExportServices.extractCover(
        controller: controller,
        onProgress: (progress) {
          // You can use this progress value to show a progress indicator if needed
          debugPrint('Extract Cover Progress: $progress%');
        });
    if (context.mounted == false) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TestExportScreen(file: file, cover: cover)),
    );
  }
}
