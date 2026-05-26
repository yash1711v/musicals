import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/audio_track_entity.dart';
import '../../../domain/repositories/audio_repository.dart';
import '../../../domain/usecases/audio_controls.dart';
import '../../../domain/usecases/load_track.dart';

enum AudioPlaybackStatus { initial, loading, ready, playing, paused, failure }

sealed class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();

  @override
  List<Object?> get props => [];
}

final class AudioTrackLoaded extends AudioPlayerEvent {
  const AudioTrackLoaded(this.track);

  final AudioTrackEntity track;

  @override
  List<Object?> get props => [track];
}

final class AudioPlayPressed extends AudioPlayerEvent {
  const AudioPlayPressed();
}

final class AudioPausePressed extends AudioPlayerEvent {
  const AudioPausePressed();
}

final class AudioStopPressed extends AudioPlayerEvent {
  const AudioStopPressed();
}

final class AudioLoopToggled extends AudioPlayerEvent {
  const AudioLoopToggled();
}

final class AudioSeekRequested extends AudioPlayerEvent {
  const AudioSeekRequested(this.position);

  final Duration position;

  @override
  List<Object?> get props => [position];
}

final class AudioPositionChanged extends AudioPlayerEvent {
  const AudioPositionChanged(this.position);

  final Duration position;

  @override
  List<Object?> get props => [position];
}

final class AudioDurationChanged extends AudioPlayerEvent {
  const AudioDurationChanged(this.duration);

  final Duration duration;

  @override
  List<Object?> get props => [duration];
}

final class AudioPlayingChanged extends AudioPlayerEvent {
  const AudioPlayingChanged(this.playing);

  final bool playing;

  @override
  List<Object?> get props => [playing];
}

final class AudioPlaybackCompleted extends AudioPlayerEvent {
  const AudioPlaybackCompleted();
}

class AudioPlayerState extends Equatable {
  const AudioPlayerState({
    required this.status,
    required this.track,
    required this.position,
    required this.duration,
    required this.loopEnabled,
    required this.audioProtected,
    required this.errorMessage,
  });

  const AudioPlayerState.initial()
    : status = AudioPlaybackStatus.initial,
      track = null,
      position = Duration.zero,
      duration = Duration.zero,
      loopEnabled = false,
      audioProtected = true,
      errorMessage = null;

  final AudioPlaybackStatus status;
  final AudioTrackEntity? track;
  final Duration position;
  final Duration duration;
  final bool loopEnabled;
  final bool audioProtected;
  final String? errorMessage;

  bool get isLoading => status == AudioPlaybackStatus.loading;

  bool get isPlaying => status == AudioPlaybackStatus.playing;

  bool get canControl => track != null && !isLoading;

  Duration get visibleDuration {
    final trackDuration = track?.duration ?? Duration.zero;
    return duration == Duration.zero ? trackDuration : duration;
  }

  double get progress {
    final total = visibleDuration.inMilliseconds;
    if (total <= 0) {
      return 0;
    }

    return (position.inMilliseconds / total).clamp(0.0, 1.0);
  }

  AudioPlayerState copyWith({
    AudioPlaybackStatus? status,
    AudioTrackEntity? track,
    Duration? position,
    Duration? duration,
    bool? loopEnabled,
    bool? audioProtected,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AudioPlayerState(
      status: status ?? this.status,
      track: track ?? this.track,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      loopEnabled: loopEnabled ?? this.loopEnabled,
      audioProtected: audioProtected ?? this.audioProtected,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    track,
    position,
    duration,
    loopEnabled,
    audioProtected,
    errorMessage,
  ];
}

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  AudioPlayerBloc({
    required LoadTrack loadTrack,
    required PlayAudio playAudio,
    required PauseAudio pauseAudio,
    required StopAudio stopAudio,
    required SeekAudio seekAudio,
    required SetAudioLoop setAudioLoop,
    required AudioRepository repository,
  }) : _loadTrack = loadTrack,
       _playAudio = playAudio,
       _pauseAudio = pauseAudio,
       _stopAudio = stopAudio,
       _seekAudio = seekAudio,
       _setAudioLoop = setAudioLoop,
       _repository = repository,
       super(const AudioPlayerState.initial()) {
    on<AudioTrackLoaded>(_onAudioTrackLoaded);
    on<AudioPlayPressed>(_onAudioPlayPressed);
    on<AudioPausePressed>(_onAudioPausePressed);
    on<AudioStopPressed>(_onAudioStopPressed);
    on<AudioLoopToggled>(_onAudioLoopToggled);
    on<AudioSeekRequested>(_onAudioSeekRequested);
    on<AudioPositionChanged>(_onAudioPositionChanged);
    on<AudioDurationChanged>(_onAudioDurationChanged);
    on<AudioPlayingChanged>(_onAudioPlayingChanged);
    on<AudioPlaybackCompleted>(_onAudioPlaybackCompleted);

    _positionSubscription = _repository.positionStream.listen(
      (position) => add(AudioPositionChanged(position)),
    );
    _durationSubscription = _repository.durationStream.listen(
      (duration) => add(AudioDurationChanged(duration)),
    );
    _playingSubscription = _repository.playingStream.listen(
      (playing) => add(AudioPlayingChanged(playing)),
    );
    _completedSubscription = _repository.completedStream.listen((completed) {
      if (completed) {
        add(const AudioPlaybackCompleted());
      }
    });
  }

  final LoadTrack _loadTrack;
  final PlayAudio _playAudio;
  final PauseAudio _pauseAudio;
  final StopAudio _stopAudio;
  final SeekAudio _seekAudio;
  final SetAudioLoop _setAudioLoop;
  final AudioRepository _repository;

  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<Duration> _durationSubscription;
  late final StreamSubscription<bool> _playingSubscription;
  late final StreamSubscription<bool> _completedSubscription;

  Future<void> _onAudioTrackLoaded(
    AudioTrackLoaded event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AudioPlaybackStatus.loading,
        track: event.track,
        position: Duration.zero,
        duration: event.track.duration,
        clearError: true,
      ),
    );

    try {
      await _loadTrack(event.track);
      final protected = await _repository.isAudioProtected();
      emit(
        state.copyWith(
          status: AudioPlaybackStatus.ready,
          track: event.track,
          position: Duration.zero,
          duration: event.track.duration,
          audioProtected: protected,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AudioPlaybackStatus.failure,
          errorMessage: 'Audio could not be prepared',
        ),
      );
    }
  }

  Future<void> _onAudioPlayPressed(
    AudioPlayPressed event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (!state.canControl) {
      return;
    }

    try {
      await _playAudio();
      emit(state.copyWith(status: AudioPlaybackStatus.playing));
    } catch (error) {
      emit(
        state.copyWith(
          status: AudioPlaybackStatus.failure,
          errorMessage: 'Playback could not start',
        ),
      );
    }
  }

  Future<void> _onAudioPausePressed(
    AudioPausePressed event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (!state.canControl) {
      return;
    }

    await _pauseAudio();
    emit(state.copyWith(status: AudioPlaybackStatus.paused));
  }

  Future<void> _onAudioStopPressed(
    AudioStopPressed event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (!state.canControl) {
      return;
    }

    await _stopAudio();
    emit(
      state.copyWith(
        status: AudioPlaybackStatus.ready,
        position: Duration.zero,
      ),
    );
  }

  Future<void> _onAudioLoopToggled(
    AudioLoopToggled event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final enabled = !state.loopEnabled;
    await _setAudioLoop(enabled);
    emit(state.copyWith(loopEnabled: enabled));
  }

  Future<void> _onAudioSeekRequested(
    AudioSeekRequested event,
    Emitter<AudioPlayerState> emit,
  ) async {
    if (!state.canControl) {
      return;
    }

    await _seekAudio(event.position);
    emit(state.copyWith(position: event.position));
  }

  void _onAudioPositionChanged(
    AudioPositionChanged event,
    Emitter<AudioPlayerState> emit,
  ) {
    emit(state.copyWith(position: event.position));
  }

  void _onAudioDurationChanged(
    AudioDurationChanged event,
    Emitter<AudioPlayerState> emit,
  ) {
    if (event.duration != Duration.zero) {
      emit(state.copyWith(duration: event.duration));
    }
  }

  void _onAudioPlayingChanged(
    AudioPlayingChanged event,
    Emitter<AudioPlayerState> emit,
  ) {
    if (event.playing && state.status != AudioPlaybackStatus.playing) {
      emit(state.copyWith(status: AudioPlaybackStatus.playing));
    } else if (!event.playing && state.status == AudioPlaybackStatus.playing) {
      emit(state.copyWith(status: AudioPlaybackStatus.paused));
    }
  }

  void _onAudioPlaybackCompleted(
    AudioPlaybackCompleted event,
    Emitter<AudioPlayerState> emit,
  ) {
    if (!state.loopEnabled) {
      emit(
        state.copyWith(
          status: AudioPlaybackStatus.ready,
          position: state.visibleDuration,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _positionSubscription.cancel();
    await _durationSubscription.cancel();
    await _playingSubscription.cancel();
    await _completedSubscription.cancel();
    return super.close();
  }
}
