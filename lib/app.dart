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
import 'screens/savings/savings_screen.dart';
import 'screens/savings/add_savings_goal_screen.dart';
import 'screens/data/data_export_screen.dart';

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
            '/savings': (context) => const SavingsScreen(),
            '/add-savings-goal': (context) => const AddSavingsGoalScreen(),
            '/data-export': (context) => const DataExportScreen(),
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
    SizedBox(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            _showActionSheet(context);
          } else {
            setState(() {
              _currentIndex = index > 2 ? index : index;
            });
          }
        },
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'إضافة',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _buildActionItem(
              context,
              icon: Icons.arrow_downward_rounded,
              label: 'إضافة دخل',
              color: const Color(0xFF149C6D),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, '/add-transaction', arguments: {'type': 'income'});
              },
            ),
            _buildActionItem(
              context,
              icon: Icons.arrow_upward_rounded,
              label: 'إضافة مصروف',
              color: theme.colorScheme.primary,
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, '/add-transaction');
              },
            ),
            _buildActionItem(
              context,
              icon: Icons.handshake_outlined,
              label: 'أعطيت مالًا لشخص',
              color: const Color(0xFFF59E0B),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, '/add-debt', arguments: {'type': 'gave'});
              },
            ),
            _buildActionItem(
              context,
              icon: Icons.receipt_long_outlined,
              label: 'استلمت مالًا من شخص',
              color: const Color(0xFF8B5CF6),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, '/add-debt', arguments: {'type': 'received'});
              },
            ),
            _buildActionItem(
              context,
              icon: Icons.savings_outlined,
              label: 'إضافة ادخار',
              color: const Color(0xFF06B6D4),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, '/savings');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final surfaceColor = theme.colorScheme.surface;
    final tertiaryColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildItem(context, 0, Icons.home_outlined, Icons.home, 'الرئيسية', primaryColor, tertiaryColor, isDark),
              _buildItem(context, 1, Icons.receipt_long_outlined, Icons.receipt_long, 'السجل', primaryColor, tertiaryColor, isDark),
              _buildCenterAdd(context, primaryColor, isDark),
              _buildItem(context, 3, Icons.bar_chart_outlined, Icons.bar_chart, 'الإحصائيات', primaryColor, tertiaryColor, isDark),
              _buildItem(context, 4, Icons.settings_outlined, Icons.settings, 'الإعدادات', primaryColor, tertiaryColor, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
    Color primaryColor,
    Color tertiaryColor,
    bool isDark,
  ) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withOpacity(isDark ? 0.15 : 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? primaryColor : tertiaryColor,
                size: 22,
              ),
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

  Widget _buildCenterAdd(BuildContext context, Color primaryColor, bool isDark) {
    return GestureDetector(
      onTap: () => onTap(2),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'إضافة',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
