import '../../../domain/entities/audio_track_entity.dart';

class LocalTrackDataSource {
  Future<List<AudioTrackEntity>> getTracks() async {
    return const [
      AudioTrackEntity(
        id: 'local_sample_loop',
        title: 'Local Sample Backing Loop',
        bpm: 96,
        duration: Duration(seconds: 8),
        assetPath: 'assets/audio/sample_backing_loop.wav',
        encryptedPath: 'local_sample_backing_loop.secure',
        description: 'Bundled local audio encrypted before playback',
      ),
    ];
  }
}
