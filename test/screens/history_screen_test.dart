import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:twela/design/format.dart';
import 'package:twela/design/theme.dart';
import 'package:twela/l10n/generated/app_localizations.dart';
import 'package:twela/models/transaction.dart';
import 'package:twela/providers/twela_provider.dart';
import 'package:twela/screens/transactions/history_screen.dart';
import 'package:twela/services/storage_service.dart';

/// The ledger used to drop every row of 1,000 or more: the sign check parsed
/// the grouped string, threw `FormatException`, and release painted one grey
/// `ErrorWidget` slab where the day's entries should be. These tests hold the
/// whole screen — not just the formatter — to that.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;
  late TwelaProvider ledger;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService();
    await storage.init();
    ledger = TwelaProvider(storage);
  });

  TwelaTransaction entry({
    required double amount,
    required TransactionType type,
    required String note,
    DateTime? date,
  }) =>
      TwelaTransaction(
        id: const Uuid().v4(),
        amount: amount,
        type: type,
        walletType: WalletType.cash,
        categoryId: 'food',
        note: note,
        date: date ?? DateTime.now(),
      );

  Widget harness() => ChangeNotifierProvider<TwelaProvider>.value(
        value: ledger,
        child: MaterialApp(
          theme: buildInbTheme(Brightness.light),
          locale: const Locale('ar', 'LY'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ar', 'LY')],
          home: const HistoryScreen(),
        ),
      );

  testWidgets('rows of 1,000+ render instead of an error slab', (tester) async {
    await ledger.addTransaction(entry(
      amount: 1500,
      type: TransactionType.expense,
      note: 'غداء',
    ));
    await ledger.addTransaction(entry(
      amount: 2500,
      type: TransactionType.income,
      note: 'راتب',
    ));
    await ledger.addTransaction(entry(
      amount: 3000,
      type: TransactionType.savings,
      note: 'هدف',
    ));

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('غداء'), findsOneWidget);
    expect(find.text('راتب'), findsOneWidget);
    expect(find.text('هدف'), findsOneWidget);
    expect(find.text('\u22121,500.00'), findsWidgets);
    expect(find.text('+2,500.00'), findsWidgets);
    expect(find.text('\u22123,000.00'), findsWidgets);
  });

  testWidgets('the day header keeps its weekday and long date', (tester) async {
    final today = DateTime(2026, 11, 16, 21, 40);
    await ledger.addTransaction(entry(
      amount: 4200,
      type: TransactionType.expense,
      note: 'قهوة',
      date: today,
    ));

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.text('${formatWeekday(today)} · ${formatDateLong(today)}'),
      findsOneWidget,
    );
    expect(find.text('\u22124,200.00'), findsWidgets);
  });
}
