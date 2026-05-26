import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'di/service_locator.dart';
import 'presentation/blocs/audio_player/audio_player_bloc.dart';
import 'presentation/blocs/security/security_bloc.dart';
import 'presentation/blocs/track_selector/track_selector_bloc.dart';
import 'presentation/pages/practice_deck/practice_deck_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const PracticeDeckApp());
}

class PracticeDeckApp extends StatelessWidget {
  const PracticeDeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<TrackSelectorBloc>()),
        BlocProvider(create: (_) => sl<AudioPlayerBloc>()),
        BlocProvider(create: (_) => sl<SecurityBloc>()),
      ],
      child: MaterialApp(
        title: 'Secure Practice Deck',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const PracticeDeckPage(),
      ),
    );
  }
}
