import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/audio_player/audio_player_bloc.dart';
import '../../blocs/security/security_bloc.dart';
import '../../blocs/track_selector/track_selector_bloc.dart';
import '../../widgets/diagnostics/diagnostics_panel.dart';
import '../../widgets/media_tray/media_tray.dart';
import '../../widgets/track_list/track_list.dart';

class PracticeDeckPage extends StatelessWidget {
  const PracticeDeckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TrackSelectorBloc, TrackSelectorState>(
      listenWhen: (previous, current) =>
          previous.selectedTrack?.id != current.selectedTrack?.id &&
          current.selectedTrack != null,
      listener: (context, state) {
        final track = state.selectedTrack;
        if (track != null) {
          context.read<AudioPlayerBloc>().add(AudioTrackLoaded(track));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Practice Deck'),
          actions: const [_SecurityAppBarStatus(), SizedBox(width: 12)],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 860;
              final padding = compact ? 16.0 : 24.0;

              if (compact) {
                return ListView(
                  padding: EdgeInsets.all(padding),
                  children: const [
                    MediaTray(),
                    SizedBox(height: 16),
                    TrackList(),
                    SizedBox(height: 16),
                    DiagnosticsPanel(),
                  ],
                );
              }

              return Padding(
                padding: EdgeInsets.all(padding),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      flex: 3,
                      child: SingleChildScrollView(child: MediaTray()),
                    ),
                    const SizedBox(width: 20),
                    SizedBox(
                      width: 390,
                      child: ListView(
                        children: const [
                          TrackList(),
                          SizedBox(height: 16),
                          DiagnosticsPanel(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SecurityAppBarStatus extends StatelessWidget {
  const _SecurityAppBarStatus();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SecurityBloc, SecurityState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final secured = state.status == SecurityStatus.secured;

        return Tooltip(
          message: secured ? 'Secure mode active' : 'Secure mode limited',
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: secured
                  ? const Color(0xff2f7d4f).withValues(alpha: .12)
                  : theme.colorScheme.secondary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  secured ? Icons.verified_user : Icons.shield_outlined,
                  size: 18,
                  color: secured
                      ? const Color(0xff2f7d4f)
                      : theme.colorScheme.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  secured ? 'Secured' : 'Limited',
                  style: theme.textTheme.labelLarge,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
