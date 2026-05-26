import 'package:just_audio/just_audio.dart';

import '../../../domain/entities/audio_track_entity.dart';
import 'memory_audio_source.dart';
import 'secure_audio_vault.dart';

class SecureAudioService {
  SecureAudioService({
    required AudioPlayer player,
    required SecureAudioVault vault,
  }) : _player = player,
       _vault = vault;

  final AudioPlayer _player;
  final SecureAudioVault _vault;
  bool _loopEnabled = false;

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<Duration> get durationStream =>
      _player.durationStream.map((duration) => duration ?? Duration.zero);

  Stream<bool> get playingStream => _player.playingStream.distinct();

  Stream<bool> get completedStream => _player.processingStateStream
      .map((state) => state == ProcessingState.completed)
      .distinct();

  Future<void> load(AudioTrackEntity track) async {
    await _player.stop();
    await _player.seek(Duration.zero);
    final bytes = await _vault.loadDecryptedBytes(track);
    final source = MemoryAudioSource(
      bytes: bytes,
      contentType: 'audio/wav',
      tag: track,
    );
    await _player.setAudioSource(source, preload: true);
    await setLoop(_loopEnabled);
  }

  Future<void> play() {
    return _player.play();
  }

  Future<void> pause() {
    return _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
    await _player.seek(Duration.zero);
  }

  Future<void> seek(Duration position) {
    return _player.seek(position);
  }

  Future<void> setLoop(bool enabled) async {
    _loopEnabled = enabled;
    await _player.setLoopMode(enabled ? LoopMode.one : LoopMode.off);
  }

  Future<bool> isProtected(AudioTrackEntity track) {
    return _vault.isProtected(track);
  }

  bool isCached(AudioTrackEntity track) {
    return _vault.isCached(track);
  }

  Future<void> dispose() {
    return _player.dispose();
  }
}
