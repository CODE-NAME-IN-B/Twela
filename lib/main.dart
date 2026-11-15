import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'providers/twela_provider.dart';
import 'providers/debt_provider.dart';
import 'providers/routine_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/savings_provider.dart';
import 'providers/person_provider.dart';
import 'providers/app_settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge to edge: the app draws behind the system bars and every screen
  // insets itself with SafeArea (see lib/design/screen.dart).
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  await initializeDateFormatting('ar', null);

  final storageService = StorageService();
  await storageService.init();

  await NotificationService.init();

  // TwelaProvider first so it can be injected into dependent providers.
  final twelaProvider = TwelaProvider(storageService);
  // DebtProvider next: savings goals settle debts, so savings needs it.
  final debtProvider = DebtProvider(storageService, twelaProvider);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider.value(value: storageService),
        ChangeNotifierProvider.value(value: twelaProvider),
        ChangeNotifierProvider.value(value: debtProvider),
        ChangeNotifierProvider(create: (_) => RoutineProvider(storageService)),
        ChangeNotifierProvider(
          create: (_) =>
              SavingsProvider(storageService, twelaProvider, debtProvider),
        ),
        ChangeNotifierProvider(create: (_) => PersonProvider(storageService)),
        ChangeNotifierProvider(
            create: (_) => AppSettingsProvider(storageService)),
      ],
      child: const TwelaApp(),
    ),
  );
}
