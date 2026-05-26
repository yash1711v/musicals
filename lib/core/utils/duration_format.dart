extension DurationFormat on Duration {
  String toClockLabel() {
    final totalSeconds = inSeconds.clamp(0, 359999);
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
