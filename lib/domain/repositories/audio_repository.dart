import '../entities/audio_track_entity.dart';

abstract class AudioRepository {
  Stream<Duration> get positionStream;

  Stream<Duration> get durationStream;

  Stream<bool> get playingStream;

  Stream<bool> get completedStream;

  Future<List<AudioTrackEntity>> getTracks();

  Future<void> loadTrack(AudioTrackEntity track);

  Future<void> play();

  Future<void> pause();

  Future<void> stop();

  Future<void> seek(Duration position);

  Future<void> setLoop(bool enabled);

  Future<bool> isAudioProtected();
}
