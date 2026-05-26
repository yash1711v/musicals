import 'package:equatable/equatable.dart';

class AudioTrackEntity extends Equatable {
  const AudioTrackEntity({
    required this.id,
    required this.title,
    required this.bpm,
    required this.duration,
    required this.encryptedPath,
    required this.description,
  });

  final String id;
  final String title;
  final int bpm;
  final Duration duration;
  final String encryptedPath;
  final String description;

  @override
  List<Object> get props => [
    id,
    title,
    bpm,
    duration,
    encryptedPath,
    description,
  ];
}
