import '../../domain/entities/audio_track_entity.dart';
import '../../domain/repositories/audio_repository.dart';
import '../datasources/local/local_track_data_source.dart';
import '../datasources/secure_audio/secure_audio_service.dart';

class AudioRepositoryImpl implements AudioRepository {
  AudioRepositoryImpl({
    required LocalTrackDataSource localTrackDataSource,
    required SecureAudioService secureAudioService,
  }) : _localTrackDataSource = localTrackDataSource,
       _secureAudioService = secureAudioService;

  final LocalTrackDataSource _localTrackDataSource;
  final SecureAudioService _secureAudioService;
  AudioTrackEntity? _currentTrack;

  @override
  Stream<Duration> get positionStream => _secureAudioService.positionStream;

  @override
  Stream<Duration> get durationStream => _secureAudioService.durationStream;

  @override
  Stream<bool> get playingStream => _secureAudioService.playingStream;

  @override
  Stream<bool> get completedStream => _secureAudioService.completedStream;

  @override
  Future<List<AudioTrackEntity>> getTracks() {
    return _localTrackDataSource.getTracks();
  }

  @override
  Future<void> loadTrack(AudioTrackEntity track) async {
    _currentTrack = track;
    await _secureAudioService.load(track);
  }

  @override
  Future<void> play() {
    return _secureAudioService.play();
  }

  @override
  Future<void> pause() {
    return _secureAudioService.pause();
  }

  @override
  Future<void> stop() {
    return _secureAudioService.stop();
  }

  @override
  Future<void> seek(Duration position) {
    return _secureAudioService.seek(position);
  }

  @override
  Future<void> setLoop(bool enabled) {
    return _secureAudioService.setLoop(enabled);
  }

  @override
  Future<bool> isAudioProtected() async {
    final track = _currentTrack;
    if (track == null) {
      return true;
    }

    return _secureAudioService.isProtected(track);
  }

  @override
  Future<bool> isTrackCached(AudioTrackEntity track) async {
    return _secureAudioService.isCached(track);
  }
}
