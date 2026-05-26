import '../entities/audio_track_entity.dart';
import '../repositories/audio_repository.dart';

class GetTracks {
  const GetTracks(this.repository);

  final AudioRepository repository;

  Future<List<AudioTrackEntity>> call() {
    return repository.getTracks();
  }
}
