import '../../../domain/entities/audio_track_entity.dart';

class LocalTrackDataSource {
  Future<List<AudioTrackEntity>> getTracks() async {
    return const [
      AudioTrackEntity(
        id: 'c_major_scale',
        title: 'C Major Scale Backing Loop',
        bpm: 90,
        duration: Duration(seconds: 12),
        encryptedPath: '8fb2c91d7a4e.secure',
        description: 'Clean piano pulse for scale practice',
      ),
      AudioTrackEntity(
        id: 'blues_improv',
        title: 'Blues Improvisation Track',
        bpm: 120,
        duration: Duration(seconds: 8),
        encryptedPath: '34ac0df1e7b9.secure',
        description: 'Shuffle feel for short phrasing drills',
      ),
      AudioTrackEntity(
        id: 'minor_arpeggio',
        title: 'Minor Arpeggio Pulse',
        bpm: 105,
        duration: Duration(seconds: 16),
        encryptedPath: 'b71e43ad99f0.secure',
        description: 'Even subdivision loop for arpeggios',
      ),
    ];
  }
}
