import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/track_selector/track_selector_bloc.dart';
import 'track_tile.dart';

class TrackList extends StatelessWidget {
  const TrackList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: BlocBuilder<TrackSelectorBloc, TrackSelectorState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Track Selector',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              if (state.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (state.errorMessage != null)
                Text(
                  state.errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                )
              else
                ...state.tracks.map(
                  (track) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TrackTile(
                      track: track,
                      selected: state.selectedTrack?.id == track.id,
                      onTap: () {
                        context.read<TrackSelectorBloc>().add(
                          TrackChosen(track),
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
