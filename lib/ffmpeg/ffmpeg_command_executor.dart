import 'dart:async';
import 'package:cross_file/cross_file.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/return_code.dart';
import 'package:video_editor_plus/ffmpeg/ffmpeg_statistics.dart';

class FFmpegCommandExecutor {
  const FFmpegCommandExecutor();

  Future<XFile> executeFFmpegIO({
    required String execute,
    required String outputPath,
    String? outputMimeType,
    Duration? videoDuration, // pass video duration here
    void Function(double progress)? onProgress, // progress callback
    void Function(FFmpegStatistics)? onStatistics,
  }) {
    final completer = Completer<XFile>();

    FFmpegKit.executeAsync(
      execute,
      (session) async {
        final code = await session.getReturnCode();

        if (ReturnCode.isSuccess(code)) {
          completer.complete(XFile(outputPath, mimeType: outputMimeType));
        } else {
          final state = FFmpegKitConfig.sessionStateToString(
            await session.getState(),
          );
          completer.completeError(
            Exception(
              'FFmpeg process exited with state $state and return code $code.'
              '${await session.getOutput()}',
            ),
          );
        }
      },
      null,
      (stats) {
        final stat = FFmpegStatistics.fromIOStatistics(stats);

        // Calculate progress %
        if (videoDuration != null) {
          final time = stat.time; // in milliseconds
          if (time > 0) {
            final progress = (time / videoDuration.inMilliseconds).clamp(0.0, 1.0) * 100;
            onProgress?.call(progress);
          }
        }

        // Keep existing statistics callback
        if (onStatistics != null) {
          onStatistics(stat);
        }
      },
    );

    return completer.future;
  }
}
