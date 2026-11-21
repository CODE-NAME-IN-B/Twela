import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:twela/app.dart';
import 'package:twela/providers/app_settings_provider.dart';
import 'package:twela/providers/debt_provider.dart';
import 'package:twela/providers/person_provider.dart';
import 'package:twela/providers/routine_provider.dart';
import 'package:twela/providers/savings_provider.dart';
import 'package:twela/providers/theme_provider.dart';
import 'package:twela/providers/twela_provider.dart';
import 'package:twela/screens/onboarding/onboarding_screen.dart';
import 'package:twela/services/storage_service.dart';

/// The boot gate: on a cold start the Navigator must not resolve a route
/// until storage is open — and with onboarding already complete it must
/// land on Home, never back on the onboarding wizard.
void main() {
  testWidgets('cold boot lands on Home when onboarding is complete',
      (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final storage = StorageService(); // deliberately NOT inited: cold start
    final twela = TwelaProvider(storage);
    final debts = DebtProvider(storage, twela);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          Provider.value(value: storage),
          ChangeNotifierProvider.value(value: twela),
          ChangeNotifierProvider.value(value: debts),
          ChangeNotifierProvider(create: (_) => RoutineProvider(storage)),
          ChangeNotifierProvider(
              create: (_) => SavingsProvider(storage, twela, debts)),
          ChangeNotifierProvider(create: (_) => PersonProvider(storage)),
          ChangeNotifierProvider(create: (_) => AppSettingsProvider(storage)),
        ],
        child: const TwelaApp(),
      ),
    );

    // The test binding flushes microtasks eagerly, so by the time
    // `pumpWidget` returns the gate may already be open — elapse time so the
    // screens' `Reveal` entrance timers fire, then assert the outcome that
    // matters: the wizard must not return.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(storage.isReady, isTrue);
    expect(find.byType(OnboardingScreen), findsNothing,
        reason: 'onboarding was completed — the wizard must not return');
    expect(find.byType(MainScreen), findsOneWidget);
  });
}
