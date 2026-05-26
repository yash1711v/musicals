import '../entities/audio_track_enty.dart';

abstract class AudioRepository {
  Future<List<AudioTrackEntity>> getTracks();

  Future<void> playTrack(String id);

  Future<void> pause();

  Future<void> stop();

  Future<void> seek(Duration position);

  Future<void> setLoop(bool enabled);
}