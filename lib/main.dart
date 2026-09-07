import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'providers/twela_provider.dart';
import 'providers/debt_provider.dart';
import 'providers/routine_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  await NotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TwelaProvider(storageService)),
        ChangeNotifierProvider(create: (_) => DebtProvider(storageService)),
        ChangeNotifierProvider(create: (_) => RoutineProvider(storageService)),
      ],
      child: const TwelaApp(),
    ),
  );
}
