import 'package:flutter_test/flutter_test.dart';
import 'package:music_app/di/service_locator.dart';
import 'package:music_app/main.dart';
import 'package:music_app/presentation/blocs/track_selector/track_selector_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (!sl.isRegistered<TrackSelectorBloc>()) {
      await setupLocator();
    }
  });

  testWidgets('practice deck renders core sections', (tester) async {
    await tester.pumpWidget(const PracticeDeckApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Practice Deck'), findsOneWidget);
    expect(find.text('Track Selector'), findsOneWidget);
    expect(find.text('Security Diagnostics'), findsOneWidget);
  });
}
