import 'dart:math' as math;
import 'dart:typed_data';

import '../../../domain/entities/audio_track_entity.dart';

class AudioSampleSynthesizer {
  Uint8List build(AudioTrackEntity track) {
    const sampleRate = 44100;
    const channels = 1;
    const bitsPerSample = 16;
    final totalSamples = sampleRate * track.duration.inSeconds;
    final dataSize = totalSamples * channels * bitsPerSample ~/ 8;
    final bytes = BytesBuilder(copy: false)..add(_header(dataSize, sampleRate));
    final sampleData = ByteData(dataSize);
    final voices = _voices(track.id);
    final beatSeconds = 60 / track.bpm;

    for (var i = 0; i < totalSamples; i++) {
      final time = i / sampleRate;
      final beat = (time / beatSeconds).floor();
      final beatPhase = (time / beatSeconds) - beat;
      final chord = voices[beat % voices.length];
      final envelope = math.pow(math.sin(math.pi * beatPhase), 2).toDouble();
      final accent = beat % 4 == 0 ? 1.0 : .72;
      var value = 0.0;

      for (final frequency in chord) {
        value += math.sin(2 * math.pi * frequency * time) / chord.length;
      }

      final kickWindow = beatPhase < .32 ? 1 - beatPhase / .32 : 0.0;
      final kick =
          math.sin(2 * math.pi * 55 * time) *
          math.pow(kickWindow, 2).toDouble() *
          (beat % 2 == 0 ? .26 : .12);
      final tickWindow = beatPhase < .028 ? 1 - beatPhase / .028 : 0.0;
      final tick = math.sin(2 * math.pi * 880 * time) * tickWindow * .045;
      final mixed = (value * envelope * accent * .34) + kick + tick;
      final pcm = (mixed.clamp(-1.0, 1.0) * 32767).round();

      sampleData.setInt16(i * 2, pcm, Endian.little);
    }

    bytes.add(sampleData.buffer.asUint8List());
    return bytes.toBytes();
  }

  Uint8List _header(int dataSize, int sampleRate) {
    const channels = 1;
    const bitsPerSample = 16;
    final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    final blockAlign = channels * bitsPerSample ~/ 8;
    final header = ByteData(44);

    _setAscii(header, 0, 'RIFF');
    header.setUint32(4, 36 + dataSize, Endian.little);
    _setAscii(header, 8, 'WAVE');
    _setAscii(header, 12, 'fmt ');
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    _setAscii(header, 36, 'data');
    header.setUint32(40, dataSize, Endian.little);

    return header.buffer.asUint8List();
  }

  void _setAscii(ByteData data, int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      data.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  List<List<double>> _voices(String id) {
    return switch (id) {
      'blues_improv' => const [
        [196.0, 293.66, 349.23],
        [220.0, 329.63, 392.0],
        [196.0, 293.66, 440.0],
        [174.61, 261.63, 349.23],
      ],
      'minor_arpeggio' => const [
        [220.0, 261.63, 329.63],
        [246.94, 293.66, 392.0],
        [196.0, 261.63, 329.63],
        [164.81, 246.94, 329.63],
      ],
      _ => const [
        [261.63, 329.63, 392.0],
        [293.66, 349.23, 440.0],
        [329.63, 392.0, 493.88],
        [261.63, 349.23, 440.0],
      ],
    };
  }
}
