import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:super_tic_tac_toe_flutter/main.dart';
import 'package:super_tic_tac_toe_flutter/providers/game_state_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Initial game load test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => GameStateProvider()),
        ],
        child: const SuperTicTacToeApp(),
      ),
    );

    // Verify that our reset button is present
    expect(find.text('Reset Game'), findsOneWidget);

    // Check initial state tells O it's their turn
    expect(find.text('⭘\'s Turn'), findsOneWidget);
  });
}
