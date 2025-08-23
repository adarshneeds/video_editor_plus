import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:video_editor_plus/ffmpeg/ffmpeg_command_executor.dart';
import 'package:video_editor_plus/models/file_format.dart';
import 'package:video_editor_plus/ffmpeg/ffmpeg_statistics.dart';
import 'package:video_editor_plus/video_editor.dart';

class ExportServices {
  static Future<String> ioOutputPath(String filePath, FileFormat format) async {
    final tempPath = (await getTemporaryDirectory()).path;
    final name = path.basenameWithoutExtension(filePath);
    final epoch = DateTime.now().millisecondsSinceEpoch;
    return "$tempPath/${name}_$epoch.${format.extension}";
  }

  static Future<XFile> exportVideo({
    required VideoEditorController controller,
    void Function(FFmpegStatistics)? onStatistics,
    VideoExportFormat outputFormat = VideoExportFormat.mp4,
    double scale = 1.0,
    String customInstruction = '',
    VideoExportPreset preset = VideoExportPreset.none,
    bool isFiltersEnabled = true,
  }) async {
    final inputPath = controller.file.path;
    final outputPath = await ioOutputPath(inputPath, outputFormat);

    final config = controller.createVideoFFmpegConfig();
    final execute = config.createExportCommand(
      inputPath: inputPath,
      outputPath: outputPath,
      scale: scale,
      customInstruction: customInstruction,
      preset: preset,
      isFiltersEnabled: isFiltersEnabled,
    );

    debugPrint('run export video command : [$execute]');

    return const FFmpegCommandExecutor().executeFFmpegIO(
      execute: execute,
      outputPath: outputPath,
      outputMimeType: outputFormat.mimeType,
      onStatistics: onStatistics,
    );
  }

  static Future<XFile> extractCover({
    required VideoEditorController controller,
    void Function(FFmpegStatistics)? onStatistics,
    CoverExportFormat outputFormat = CoverExportFormat.jpg,
    double scale = 1.0,
    int quality = 100,
    bool isFiltersEnabled = true,
  }) async {
    // file generated from the thumbnail library or video source
    final coverFile = await VideoThumbnail.thumbnailFile(
      imageFormat: ImageFormat.JPEG,
      thumbnailPath: kIsWeb ? null : (await getTemporaryDirectory()).path,
      video: controller.file.path,
      timeMs: controller.selectedCoverVal?.timeMs ?? controller.startTrim.inMilliseconds,
      quality: quality,
    );

    final inputPath = coverFile.path;
    final outputPath = await ioOutputPath(coverFile.path, outputFormat);

    var config = controller.createCoverFFmpegConfig();
    final execute = config.createExportCommand(
      inputPath: inputPath,
      outputPath: outputPath,
      scale: scale,
      quality: quality,
      isFiltersEnabled: isFiltersEnabled,
    );

    debugPrint('VideoEditor - run export cover command : [$execute]');

    return const FFmpegCommandExecutor().executeFFmpegIO(
      execute: execute,
      outputPath: outputPath,
      outputMimeType: outputFormat.mimeType,
    );
  }
}
