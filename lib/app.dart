import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/transactions/add_transaction_screen.dart';
import 'screens/transactions/history_screen.dart';
import 'screens/budget/settings_screen.dart';
import 'screens/budget/routine_settings_screen.dart';
import 'screens/debts/debts_screen.dart';
import 'screens/debts/add_debt_screen.dart';
import 'screens/debts/debt_detail_screen.dart';
import 'screens/stats/stats_screen.dart';

class TwelaApp extends StatelessWidget {
  const TwelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Twela',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeProvider.themeMode,
          locale: const Locale('ar', 'LY'),
          initialRoute: '/onboarding',
          routes: {
            '/onboarding': (context) => const OnboardingScreen(),
            '/home': (context) => const MainScreen(),
            '/add-transaction': (context) => const AddTransactionScreen(),
            '/history': (context) => const HistoryScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/routine-settings': (context) => const RoutineSettingsScreen(),
            '/debts': (context) => const DebtsScreen(),
            '/add-debt': (context) => const AddDebtScreen(),
            '/stats': (context) => const StatsScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/debt-detail') {
              final debt = settings.arguments as dynamic;
              return MaterialPageRoute(
                builder: (context) => DebtDetailScreen(debt: debt),
              );
            }
            return null;
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    HistoryScreen(),
    DebtsScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, 'الرئيسية'),
                _buildNavItem(1, Icons.receipt_long_outlined, Icons.receipt_long, 'السجل'),
                _buildNavItem(2, Icons.people_outline, Icons.people, 'الديون'),
                _buildNavItem(3, Icons.bar_chart_outlined, Icons.bar_chart, 'الإحصائيات'),
                _buildNavItem(4, Icons.settings_outlined, Icons.settings, 'الإعدادات'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/add-transaction'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final theme = Theme.of(context);
    final isSelected = _currentIndex == index;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;
    final tertiaryColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(isDark ? 0.15 : 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? primaryColor : tertiaryColor,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? primaryColor : tertiaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get isDark => Theme.of(context).brightness == Brightness.dark;
}
