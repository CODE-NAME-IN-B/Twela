import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider.value(value: storageService),
        ChangeNotifierProvider(create: (_) => TwelaProvider(storageService)),
        ChangeNotifierProxyProvider<TwelaProvider, DebtProvider>(
          create: (_) => DebtProvider(storageService),
          update: (_, twelaProvider, debtProvider) =>
              debtProvider!..attachLedger(twelaProvider),
        ),
        ChangeNotifierProvider(create: (_) => RoutineProvider(storageService)),
        ChangeNotifierProxyProvider<TwelaProvider, SavingsProvider>(
          create: (_) => SavingsProvider(storageService),
          update: (_, twelaProvider, savingsProvider) =>
              savingsProvider!..attachLedger(twelaProvider),
        ),
        ChangeNotifierProvider(create: (_) => PersonProvider(storageService)),
      ],
      child: const TwelaApp(),
    ),
  );
}
