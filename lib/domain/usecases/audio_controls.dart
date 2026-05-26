import '../repositories/audio_repository.dart';

class PlayAudio {
  const PlayAudio(this.repository);

  final AudioRepository repository;

  Future<void> call() {
    return repository.play();
  }
}

class PauseAudio {
  const PauseAudio(this.repository);

  final AudioRepository repository;

  Future<void> call() {
    return repository.pause();
  }
}

class StopAudio {
  const StopAudio(this.repository);

  final AudioRepository repository;

  Future<void> call() {
    return repository.stop();
  }
}

class SeekAudio {
  const SeekAudio(this.repository);

  final AudioRepository repository;

  Future<void> call(Duration position) {
    return repository.seek(position);
  }
}

class SetAudioLoop {
  const SetAudioLoop(this.repository);

  final AudioRepository repository;

  Future<void> call(bool enabled) {
    return repository.setLoop(enabled);
  }
}
