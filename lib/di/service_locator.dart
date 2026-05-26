import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';

import '../core/security/screen_security_service.dart';
import '../core/security/security_service.dart';
import '../data/datasources/local/local_track_data_source.dart';
import '../data/datasources/secure_audio/audio_sample_synthesizer.dart';
import '../data/datasources/secure_audio/secure_audio_service.dart';
import '../data/datasources/secure_audio/secure_audio_vault.dart';
import '../data/repositories/audio_repository_impl.dart';
import '../domain/repositories/audio_repository.dart';
import '../domain/usecases/audio_controls.dart';
import '../domain/usecases/get_tracks.dart';
import '../domain/usecases/load_track.dart';
import '../presentation/blocs/audio_player/audio_player_bloc.dart';
import '../presentation/blocs/security/security_bloc.dart';
import '../presentation/blocs/track_selector/track_selector_bloc.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  sl
    ..registerLazySingleton(() => const FlutterSecureStorage())
    ..registerLazySingleton(AudioSampleSynthesizer.new)
    ..registerLazySingleton(
      () => SecureAudioVault(secureStorage: sl(), synthesizer: sl()),
    )
    ..registerLazySingleton(
      () => SecureAudioService(player: AudioPlayer(), vault: sl()),
    )
    ..registerLazySingleton(LocalTrackDataSource.new)
    ..registerLazySingleton<AudioRepository>(
      () => AudioRepositoryImpl(
        localTrackDataSource: sl(),
        secureAudioService: sl(),
      ),
    )
    ..registerLazySingleton<SecurityService>(ScreenSecurityService.new)
    ..registerFactory(() => GetTracks(sl()))
    ..registerFactory(() => LoadTrack(sl()))
    ..registerFactory(() => PlayAudio(sl()))
    ..registerFactory(() => PauseAudio(sl()))
    ..registerFactory(() => StopAudio(sl()))
    ..registerFactory(() => SeekAudio(sl()))
    ..registerFactory(() => SetAudioLoop(sl()))
    ..registerFactory(
      () => TrackSelectorBloc(getTracks: sl())..add(const TrackListRequested()),
    )
    ..registerFactory(
      () => AudioPlayerBloc(
        loadTrack: sl(),
        playAudio: sl(),
        pauseAudio: sl(),
        stopAudio: sl(),
        seekAudio: sl(),
        setAudioLoop: sl(),
        repository: sl(),
      ),
    )
    ..registerFactory(
      () => SecurityBloc(securityService: sl())..add(const SecurityStarted()),
    );
}
