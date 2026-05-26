import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/duration_format.dart';
import '../../blocs/audio_player/audio_player_bloc.dart';
import 'waveform_strip.dart';

class MediaTray extends StatelessWidget {
  const MediaTray({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final track = state.track;
        final duration = state.visibleDuration;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.graphic_eq,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track?.title ?? 'Select a practice track',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          track?.description ??
                              'Encrypted loops load only after selection',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.isLoading)
                    const SizedBox.square(
                      dimension: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              WaveformStrip(
                progress: state.progress,
                activeColor: theme.colorScheme.secondary,
                inactiveColor: theme.colorScheme.outline,
              ),
              const SizedBox(height: 8),
              Slider(
                value: state.position.inMilliseconds
                    .clamp(0, duration.inMilliseconds)
                    .toDouble(),
                max: duration.inMilliseconds <= 0
                    ? 1
                    : duration.inMilliseconds.toDouble(),
                onChanged: state.canControl
                    ? (value) {
                        context.read<AudioPlayerBloc>().add(
                          AudioSeekRequested(
                            Duration(milliseconds: value.round()),
                          ),
                        );
                      }
                    : null,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(state.position.toClockLabel()),
                  Text(duration.toClockLabel()),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: state.canControl
                        ? () {
                            context.read<AudioPlayerBloc>().add(
                              state.isPlaying
                                  ? const AudioPausePressed()
                                  : const AudioPlayPressed(),
                            );
                          }
                        : null,
                    icon: Icon(
                      state.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    label: Text(state.isPlaying ? 'Pause' : 'Play'),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Stop',
                    onPressed: state.canControl
                        ? () {
                            context.read<AudioPlayerBloc>().add(
                              const AudioStopPressed(),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.stop),
                  ),
                  IconButton.filledTonal(
                    tooltip: state.loopEnabled ? 'Loop on' : 'Loop off',
                    onPressed: () {
                      context.read<AudioPlayerBloc>().add(
                        const AudioLoopToggled(),
                      );
                    },
                    icon: Icon(
                      state.loopEnabled ? Icons.repeat_on : Icons.repeat,
                    ),
                  ),
                  _MetricChip(
                    icon: Icons.speed,
                    label: track == null ? '-- BPM' : '${track.bpm} BPM',
                  ),
                  _MetricChip(
                    icon: state.audioProtected
                        ? Icons.enhanced_encryption
                        : Icons.lock_open,
                    label: state.audioProtected ? 'Secured' : 'Open',
                  ),
                ],
              ),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  state.errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}
