import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:twela/providers/debt_provider.dart';
import 'package:twela/providers/twela_provider.dart';
import 'package:twela/services/storage_service.dart';

/// The four states per screen hang off `BootState`: this covers the two that
/// used not to exist — loading on a cold start, and the corrupt-storage
/// failure with a working «أعد المحاولة».
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('cold start', () {
    testWidgets(
        'a provider built before storage opens stays loading, then loads',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService(); // never inited — a real cold start
      final ledger = TwelaProvider(storage);

      expect(ledger.isLoading, isTrue);
      expect(ledger.loadFailed, isFalse);

      await storage.init();
      // Storage is open, but the data lands at the end of the next frame so
      // the screen has painted its skeleton first.
      expect(ledger.isLoading, isTrue);

      // Nothing else in this test schedules a frame (the app always does —
      // the boot gate flips right after storage opens).
      tester.binding.scheduleFrame();
      await tester.pump();
      expect(ledger.isLoading, isFalse);
      expect(ledger.loadFailed, isFalse);
      expect(ledger.categories, isNotEmpty);
    });

    test('warm storage loads synchronously, exactly as before', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      await storage.init();

      final ledger = TwelaProvider(storage);
      final debts = DebtProvider(storage, ledger);

      expect(ledger.isLoading, isFalse);
      expect(debts.isLoading, isFalse);
      expect(debts.debts, isEmpty);
    });

    test('ensureInitialized is idempotent', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = StorageService();
      final a = storage.ensureInitialized();
      final b = storage.ensureInitialized();
      expect(identical(a, b), isTrue);
      await a;
      expect(storage.isReady, isTrue);
      await storage.ensureInitialized();
      expect(storage.isReady, isTrue);
    });
  });

  group('corrupt storage', () {
    testWidgets('flags loadFailed and recovers on retry', (tester) async {
      SharedPreferences.setMockInitialValues({
        'transactions': '{not json at all',
      });
      final storage = StorageService();
      await storage.init();

      final ledger = TwelaProvider(storage);
      expect(ledger.isLoading, isFalse);
      expect(ledger.loadFailed, isTrue);

      // «أعد المحاولة»: fix the row, then retryBoot reloads it.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('transactions', '[]');
      ledger.retryBoot(storage, () => ledger.reloadData());

      expect(ledger.isLoading, isFalse);
      expect(ledger.loadFailed, isFalse);
      expect(ledger.transactions, isEmpty);
    });

    test('a second provider on the same storage fails independently', () async {
      SharedPreferences.setMockInitialValues({
        'debts': '][',
      });
      final storage = StorageService();
      await storage.init();

      final ledger = TwelaProvider(storage);
      final debts = DebtProvider(storage, ledger);

      expect(ledger.loadFailed, isFalse);
      expect(debts.loadFailed, isTrue);
    });
  });
}
