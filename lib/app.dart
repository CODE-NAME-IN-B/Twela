import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'design/motion.dart';
import 'design/theme.dart';
import 'design/tokens.dart';
import 'design/widgets.dart';
import 'providers/app_settings_provider.dart';
import 'providers/theme_provider.dart';
import 'services/storage_service.dart';
import 'services/update_service.dart';
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
import 'screens/savings/savings_detail_screen.dart';
import 'screens/savings/savings_editor_screen.dart';
import 'screens/savings/savings_withdraw_screen.dart';
import 'screens/data/data_export_screen.dart';
import 'l10n/generated/app_localizations.dart';
import 'models/debt.dart';
import 'models/transaction.dart';

/// Height of the floating glass navigation (without the system inset).
const double kNavBarHeight = 58;

class TwelaApp extends StatelessWidget {
  const TwelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.read<StorageService>();
    final onboardingComplete = storage.getOnboardingComplete();

    return Consumer2<ThemeProvider, AppSettingsProvider>(
      builder: (context, themeProvider, appSettings, _) {
        return MaterialApp(
          title: 'Twela',
          debugShowCheckedModeBanner: false,
          theme:
              buildInbTheme(Brightness.light, accent: appSettings.accentColor),
          darkTheme:
              buildInbTheme(Brightness.dark, accent: appSettings.accentColor),
          themeMode: themeProvider.themeMode,
          locale: const Locale('ar', 'LY'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ar', 'LY'),
            Locale('ar'),
            Locale('en'),
          ],
          initialRoute: onboardingComplete ? '/home' : '/onboarding',
          routes: {
            '/onboarding': (context) => const OnboardingScreen(),
            '/home': (context) => const MainScreen(),
            '/add-transaction': (context) {
              final args = ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
              return AddTransactionScreen(
                initialType:
                    args?['type'] == 'income' ? TransactionType.income : null,
              );
            },
            '/history': (context) => const HistoryScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/routine-settings': (context) => const RoutineSettingsScreen(),
            '/debts': (context) => const DebtsScreen(),
            '/add-debt': (context) => const AddDebtScreen(),
            '/stats': (context) => const StatsScreen(),
            '/savings': (context) => const SavingsScreen(),
            '/savings-edit': (context) {
              final args = ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
              return SavingsEditorScreen(goalId: args?['goalId'] as String?);
            },
            '/savings-detail': (context) {
              final args = ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
              return SavingsDetailScreen(
                  goalId: args?['goalId'] as String? ?? '');
            },
            '/savings-withdraw': (context) {
              final args = ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
              return SavingsWithdrawScreen(
                goalId: args?['goalId'] as String? ?? '',
                toDebt: args?['toDebt'] as bool? ?? false,
              );
            },
            '/data-export': (context) => const DataExportScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/debt-detail') {
              final debt = settings.arguments as Debt;
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

/// The tab shell: four destinations on a glass bar, plus the movement sheet.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.init();
      UpdateService.autoCheckForUpdate(context);
    });
  }

  void _goTo(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final reserved = kNavBarHeight + S.sm + bottomInset;

    return Scaffold(
      backgroundColor: c.paper,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
              embedded: true,
              bottomBarHeight: reserved,
              onOpenSettings: () => _goToSettings(),
              onOpenMovement: () => showMovementSheet(context)),
          HistoryScreen(embedded: true, bottomBarHeight: reserved),
          DebtsScreen(embedded: true, bottomBarHeight: reserved),
          StatsScreen(embedded: true, bottomBarHeight: reserved),
        ],
      ),
      bottomNavigationBar: _GlassNav(
        index: _currentIndex,
        onSelected: _goTo,
        onAction: () => showMovementSheet(context),
      ),
    );
  }

  void _goToSettings() {
    Navigator.of(context).pushNamed('/settings');
  }
}

/// The floating glass navigation: four destinations, one movement action.
/// The action lives inside the bar, so it can never cover a destination.
class _GlassNav extends StatelessWidget {
  const _GlassNav({
    required this.index,
    required this.onSelected,
    required this.onAction,
  });

  final int index;
  final ValueChanged<int> onSelected;
  final VoidCallback onAction;

  static const _items = <_NavItem>[
    _NavItem('الرئيسية', Icons.home_outlined, Icons.home_rounded),
    _NavItem('السجل', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
    _NavItem('الديون', Icons.handshake_outlined, Icons.handshake_rounded),
    _NavItem('الإحصائيات', Icons.insights_outlined, Icons.insights_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    // Five slots: four destinations with the movement action in the centre,
    // so the action can never cover a destination.
    return Padding(
      padding: EdgeInsets.fromLTRB(S.md, 0, S.md, S.sm + bottomInset),
      child: GlassBar(
        height: kNavBarHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final count = _items.length;
            final slot = constraints.maxWidth / (count + 1);
            int slotOf(int destination) =>
                destination < 2 ? destination : destination + 1;
            return Stack(
              children: [
                AnimatedPositionedDirectional(
                  duration: Motion.base,
                  curve: Motion.emphasized,
                  start: slot * slotOf(index) + 5,
                  top: 5,
                  bottom: 5,
                  width: slot - 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: c.fg,
                      borderRadius: BorderRadius.circular(R.pill),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < count; i++) ...[
                      if (i == 2) Expanded(child: _NavAction(onTap: onAction)),
                      Expanded(
                        child: _NavButton(
                          item: _items[i],
                          selected: i == index,
                          onTap: () => onSelected(i),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.activeIcon);
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// The centre slot: a mint circle with a plus, opening the movement sheet.
class _NavAction extends StatelessWidget {
  const _NavAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return Semantics(
      button: true,
      label: 'إضافة حركة',
      child: PressScale(
        onTap: onTap,
        scale: 0.9,
        child: Center(
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.mint, shape: BoxShape.circle),
            child: Icon(Icons.add_rounded, size: 24, color: c.island),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton(
      {required this.item, required this.selected, required this.onTap});

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final color = selected ? c.paper : c.muted;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: PressScale(
        onTap: onTap,
        scale: 0.9,
        child: SizedBox(
          height: kNavBarHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? item.activeIcon : item.icon,
                  size: 20, color: color),
              const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: InbFonts.arabic,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The movement sheet: every action that adds something, in one place.
Future<void> showMovementSheet(BuildContext context) {
  final c = context.inb;
  final sem = context.sem;

  final actions = <_SheetAction>[
    _SheetAction(
      icon: Icons.south_west_rounded,
      label: 'إضافة مصروف',
      hint: 'سجّل ما أنفقته',
      color: sem.expense,
      onTap: () => Navigator.pushNamed(context, '/add-transaction'),
    ),
    _SheetAction(
      icon: Icons.north_east_rounded,
      label: 'إضافة دخل',
      hint: 'سجّل ما استلمته',
      color: sem.income,
      onTap: () => Navigator.pushNamed(
        context,
        '/add-transaction',
        arguments: {'type': 'income'},
      ),
    ),
    _SheetAction(
      icon: Icons.north_east_rounded,
      label: 'أعطيت مالًا لشخص',
      hint: 'دين في ذمتك',
      color: sem.debt,
      onTap: () => Navigator.pushNamed(context, '/add-debt',
          arguments: {'type': 'gave'}),
    ),
    _SheetAction(
      icon: Icons.south_west_rounded,
      label: 'استلمت مالًا من شخص',
      hint: 'دين لك',
      color: sem.debt,
      onTap: () => Navigator.pushNamed(context, '/add-debt',
          arguments: {'type': 'received'}),
    ),
    _SheetAction(
      icon: Icons.savings_outlined,
      label: 'الادخار',
      hint: 'الحصالة وإضافة هدف',
      color: sem.savings,
      onTap: () => Navigator.pushNamed(context, '/savings'),
    ),
  ];

  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => InbSheet(
      title: 'إضافة حركة',
      subtitle: 'اختر ما تريد تسجيله',
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(S.md, 0, S.md, S.md),
        children: [
          for (final action in actions)
            Padding(
              padding: const EdgeInsets.only(bottom: S.sm),
              child: PressScale(
                onTap: () {
                  Navigator.pop(ctx);
                  action.onTap();
                },
                child: Container(
                  padding: const EdgeInsets.all(S.md),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(R.inner),
                    border: Border.all(color: c.line),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: action.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(R.inner),
                        ),
                        child: Icon(action.icon, color: action.color, size: 20),
                      ),
                      const SizedBox(width: S.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action.label,
                              style: TextStyle(
                                fontFamily: InbFonts.arabic,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: c.fg,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              action.hint,
                              style: TextStyle(
                                fontFamily: InbFonts.arabic,
                                fontSize: 12,
                                color: c.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 18, color: c.muted),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: S.xs),
        ],
      ),
    ),
  );
}

class _SheetAction {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.hint,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String hint;
  final Color color;
  final VoidCallback onTap;
}
