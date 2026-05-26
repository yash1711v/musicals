import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/audio_track_entity.dart';
import '../../../domain/usecases/get_tracks.dart';

sealed class TrackSelectorEvent extends Equatable {
  const TrackSelectorEvent();

  @override
  List<Object?> get props => [];
}

final class TrackListRequested extends TrackSelectorEvent {
  const TrackListRequested();
}

final class TrackChosen extends TrackSelectorEvent {
  const TrackChosen(this.track);

  final AudioTrackEntity track;

  @override
  List<Object?> get props => [track];
}

class TrackSelectorState extends Equatable {
  const TrackSelectorState({
    required this.tracks,
    required this.selectedTrack,
    required this.isLoading,
    required this.errorMessage,
  });

  const TrackSelectorState.initial()
    : tracks = const [],
      selectedTrack = null,
      isLoading = false,
      errorMessage = null;

  final List<AudioTrackEntity> tracks;
  final AudioTrackEntity? selectedTrack;
  final bool isLoading;
  final String? errorMessage;

  TrackSelectorState copyWith({
    List<AudioTrackEntity>? tracks,
    AudioTrackEntity? selectedTrack,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TrackSelectorState(
      tracks: tracks ?? this.tracks,
      selectedTrack: selectedTrack ?? this.selectedTrack,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [tracks, selectedTrack, isLoading, errorMessage];
}

class TrackSelectorBloc extends Bloc<TrackSelectorEvent, TrackSelectorState> {
  TrackSelectorBloc({required GetTracks getTracks})
    : _getTracks = getTracks,
      super(const TrackSelectorState.initial()) {
    on<TrackListRequested>(_onTrackListRequested);
    on<TrackChosen>(_onTrackChosen);
  }

  final GetTracks _getTracks;

  Future<void> _onTrackListRequested(
    TrackListRequested event,
    Emitter<TrackSelectorState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final tracks = await _getTracks();
      emit(state.copyWith(tracks: tracks, isLoading: false, clearError: true));
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Tracks could not be loaded',
        ),
      );
    }
  }

  void _onTrackChosen(TrackChosen event, Emitter<TrackSelectorState> emit) {
    emit(state.copyWith(selectedTrack: event.track, clearError: true));
  }
}
