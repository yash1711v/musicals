import '../entities/audio_track_entity.dart';
import '../repositories/audio_repository.dart';

class LoadTrack {
  const LoadTrack(this.repository);

  final AudioRepository repository;

  Future<void> call(AudioTrackEntity track) {
    return repository.loadTrack(track);
  }
}
