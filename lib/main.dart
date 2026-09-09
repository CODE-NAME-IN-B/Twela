import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);

  final storageService = StorageService();
  await storageService.init();

  await NotificationService.init();

  // Create TwelaProvider first so it can be injected into dependent providers
  final twelaProvider = TwelaProvider(storageService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider.value(value: storageService),
        ChangeNotifierProvider.value(value: twelaProvider),
        ChangeNotifierProvider(create: (_) => DebtProvider(storageService, twelaProvider)),
        ChangeNotifierProvider(create: (_) => RoutineProvider(storageService)),
        ChangeNotifierProvider(create: (_) => SavingsProvider(storageService, twelaProvider)),
        ChangeNotifierProvider(create: (_) => PersonProvider(storageService)),
        ChangeNotifierProvider(create: (_) => AppSettingsProvider(storageService)),
      ],
      child: const TwelaApp(),
    ),
  );
}
