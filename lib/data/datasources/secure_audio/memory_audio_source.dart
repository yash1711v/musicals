import 'dart:math' as math;
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';

class MemoryAudioSource extends StreamAudioSource {
  MemoryAudioSource({
    required this.bytes,
    required this.contentType,
    super.tag,
  });

  final Uint8List bytes;
  final String contentType;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final offset = start ?? 0;
    final limit = math.min(end ?? bytes.length, bytes.length);
    final chunk = Uint8List.sublistView(bytes, offset, limit);

    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: chunk.length,
      offset: offset,
      stream: Stream.value(chunk),
      contentType: contentType,
    );
  }
}
