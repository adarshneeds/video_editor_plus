import 'package:video_editor_plus/video_editor.dart';

abstract class FFmpegCommandConfig {
  const FFmpegCommandConfig({required this.crop, required this.rotation});

  /// Used to provide crop values to Ffmpeg ([see more](https://ffmpeg.org/ffmpeg-filters.html#crop))
  /// The result is in the format `crop=w:h:x:y`
  final String crop;

  /// FFmpeg crop value ([see more](https://ffmpeg.org/ffmpeg-filters.html#transpose-1))
  /// The result is in the format `transpose=2` (repeated for every 90 degrees rotations)
  final String rotation;

  /// Returns the `-filter:v` command to use in ffmpeg execution
  String getExportFilters({
    VideoExportFormat? videoFormat,
    double scale = 1.0,
    bool isFiltersEnabled = true,
    required bool forImage,
  }) {
    if (!isFiltersEnabled) return "";

    final bool isGif = videoFormat?.extension == VideoExportFormat.gif.extension;
    final List<String> filters = [];

    if (rotation.isNotEmpty) filters.add(rotation);
    if (crop.isNotEmpty) filters.add(crop);
    if (scale != 1.0) {
      filters.add("scale=trunc(iw*$scale/2)*2:trunc(ih*$scale/2)*2");
    }

    filters.add("scale=trunc(iw/2)*2:trunc(ih/2)*2");
    filters.add("pad=ceil(iw/2)*2:ceil(ih/2)*2");
    filters.add("setsar=1");

    if (!isGif) filters.add("format=yuv420p");
    if (isGif) {
      final int fps = videoFormat is GifExportFormat ? videoFormat.fps : VideoExportFormat.gif.fps;
      filters.add("fps=$fps");
    }

    final String filterChain = filters.join(",");

    if (forImage) {
      // 🔥 Image export: NO libx264, NO video encoding, just grab a frame
      return "-vf \"$filterChain\" -frames:v 1 -f image2";
    }

    // 🔥 Video export: use libx264
    final String gifLoop = isGif ? " -loop 0" : "";
    return "-vf \"$filterChain\" -c:v libx264 -pix_fmt yuv420p$gifLoop";
  }
}

class VideoFFmpegCommandConfig extends FFmpegCommandConfig {
  const VideoFFmpegCommandConfig({required this.trimCommand, required super.crop, required super.rotation});

  /// ffmpeg command to apply the trim start and end parameters
  /// [see ffmpeg doc](https://trac.ffmpeg.org/wiki/Seeking#Cuttingsmallsections)
  final String trimCommand;

  /// Create an FFmpeg command string to export a video with the specified parameters.
  ///
  /// The [inputPath] specifies the location of the input video file to be exported.
  ///
  /// The [outputPath] specifies the path where the exported video file should be saved.
  ///
  /// The [outputFormat] of the video to be exported, by default [VideoExportFormat.mp4].
  /// You can export as a GIF file by using [VideoExportFormat.gif] or with
  /// [GifExportFormat()] which allows you to control the frame rate of the exported GIF file.
  ///
  /// The [scale] is `scale=width*scale:height*scale` and reduce or increase video size.
  ///
  /// The [customInstruction] param can be set to add custom commands to the FFmpeg eexecution
  /// (i.e. `-an` to mute the generated video), some commands require the GPL package
  ///
  /// The [preset] is the `compress quality` **(Only available on GPL package)**.
  /// A slower preset will provide better compression (compression is quality per filesize).
  /// [More info about presets](https://trac.ffmpeg.org/wiki/Encode/H.264)
  ///
  /// Set [isFiltersEnabled] to `false` if you do not want to apply any changes
  String createExportCommand({
    required String inputPath,
    required String outputPath,
    VideoExportFormat outputFormat = VideoExportFormat.mp4,
    double scale = 1.0,
    String customInstruction = '',
    VideoExportPreset preset = VideoExportPreset.none,
    bool isFiltersEnabled = true,
  }) {
    final filter =
        getExportFilters(videoFormat: outputFormat, scale: scale, isFiltersEnabled: isFiltersEnabled, forImage: false);

    return '-i $inputPath $customInstruction $filter ${preset.ffmpegPreset} $trimCommand -y $outputPath';
  }
}

class CoverFFmpegCommandConfig extends FFmpegCommandConfig {
  CoverFFmpegCommandConfig({required super.crop, required super.rotation});

  /// Create an FFmpeg command string to export a cover image from the specified video.
  ///
  /// The [inputPath] specifies the location of the input video file to extract the cover image from.
  ///
  /// The [outputPath] specifies the path where the exported cover image file should be saved.
  ///
  /// The [scale] is `scale=width*scale:height*scale` and reduce or increase cover size.
  ///
  /// The [quality] of the exported image (from 0 to 100 ([more info](https://pub.dev/packages/video_thumbnail)))
  ///
  /// Set [isFiltersEnabled] to `false` if you do not want to apply any changes
  String createExportCommand({
    required String inputPath,
    required String outputPath,
    double scale = 1.0,
    int quality = 100,
    bool isFiltersEnabled = true,
  }) {
    final filter = getExportFilters(scale: scale, isFiltersEnabled: isFiltersEnabled, forImage: true);

    return "-i $inputPath $filter -y $outputPath";
  }
}
