import '../../../domain/entities/audio_track_entity.dart';

class LocalTrackDataSource {
  Future<List<AudioTrackEntity>> getTracks() async {
    return const [
      AudioTrackEntity(
        id: 'sample_9s',
        title: 'Warmup Backing Loop',
        bpm: 90,
        duration: Duration(milliseconds: 9587),
        assetPath: 'assets/audio/sample-9s.wav',
        encryptedPath: 'sample_9s.secure',
        description: 'Local WAV asset encrypted before playback',
      ),
      AudioTrackEntity(
        id: 'sample_12s',
        title: 'Groove Practice Loop',
        bpm: 108,
        duration: Duration(milliseconds: 12783),
        assetPath: 'assets/audio/sample-12s.wav',
        encryptedPath: 'sample_12s.secure',
        description: 'Cached in memory after first secure load',
      ),
      AudioTrackEntity(
        id: 'sample_15s',
        title: 'Extended Practice Loop',
        bpm: 120,
        duration: Duration(milliseconds: 19174),
        assetPath: 'assets/audio/sample-15s.wav',
        encryptedPath: 'sample_15s.secure',
        description: 'Player source is replaced on every switch',
      ),
    ];
  }
}
