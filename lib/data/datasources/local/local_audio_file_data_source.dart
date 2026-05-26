import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../../../domain/entities/audio_track_entity.dart';

class LocalAudioFileDataSource {
  Future<Uint8List> load(AudioTrackEntity track) async {
    final data = await rootBundle.load(track.assetPath);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
