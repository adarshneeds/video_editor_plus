import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_editor_example/crop_screen.dart';

class PickVideoScreen extends StatefulWidget {
  const PickVideoScreen({super.key});

  @override
  State<PickVideoScreen> createState() => _PickVideoScreenState();
}

class _PickVideoScreenState extends State<PickVideoScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickVideo,
              child: const Text(
                "Pick Video From Gallery",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);

      if (mounted && file != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (BuildContext context) => CropScreen(file: file)),
        );
      }
    } catch (error) {
      debugPrint("Error picking video: $error");
    }
  }
}
