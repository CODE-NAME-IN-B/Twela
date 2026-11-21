import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

/// The ramp above the bar: paper fading into transparency plus a progressive
/// blur, so scrolling content dissolves under the bar instead of stopping at
/// a hard edge.
const double kNavScrimHeight = 76;

/// Diameter of the mint add button that sits beside the bar — never inside
/// it, so it can never be mistaken for a fifth destination.
const double kNavAddSize = 52;

class TwelaApp extends StatefulWidget {
  const TwelaApp({super.key});

  @override
  State<TwelaApp> createState() => _TwelaAppState();
}

class _TwelaAppState extends State<TwelaApp> {
  late final StorageService _storage = context.read<StorageService>();
  bool _bootFailed = false;

  @override
  void initState() {
    super.initState();
    _openStorage();
  }

  /// The first frame never waits on storage. While it opens, `builder` shows
  /// the INB boot skeleton; if opening fails, a real error state with
  /// «أعد المحاولة» — never a frozen splash.
  Future<void> _openStorage() async {
    try {
      await _storage.ensureInitialized();
      _bootFailed = false;
    } catch (_) {
      _bootFailed = true;
    }
    if (mounted) setState(() {});
  }

  void _retryBoot() {
    setState(() => _bootFailed = false);
    _openStorage();
  }

  @override
  Widget build(BuildContext context) {
    final storage = _storage;
    final ready = storage.isReady;
    // Evaluated only once storage is open — the routes below mount after the
    // gate opens, so this is the value the Navigator actually resolves.
    final onboardingComplete = ready && storage.getOnboardingComplete();

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
          // The boot gate: until storage is open the Navigator is not
          // mounted, so no route resolves against half-known state.
          builder: (context, child) => ready
              ? (child ?? const SizedBox.shrink())
              : _BootShell(failed: _bootFailed, onRetry: _retryBoot),
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
        bottomInset: bottomInset,
      ),
    );
  }

  void _goToSettings() {
    Navigator.of(context).pushNamed('/settings');
  }
}

/// The floating glass navigation: four destinations, and one separate mint
/// action beside the bar. The action never lives inside the bar, so the bar
/// stays a pure four-tab destination switcher.
class _GlassNav extends StatelessWidget {
  const _GlassNav({
    required this.index,
    required this.onSelected,
    required this.onAction,
    required this.bottomInset,
  });

  final int index;
  final ValueChanged<int> onSelected;
  final VoidCallback onAction;
  final double bottomInset;

  static const _items = <_NavItem>[
    _NavItem('الرئيسية', LucideIcons.house, LucideIcons.house),
    _NavItem('السجل', LucideIcons.receipt, LucideIcons.receipt),
    _NavItem('الديون', LucideIcons.handshake, LucideIcons.handshake),
    _NavItem('الإحصائيات', LucideIcons.chartPie, LucideIcons.chartPie),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.inb;

    return SizedBox(
      height: kNavBarHeight + S.sm + bottomInset,
      child: Stack(
        // The ramp paints above the bar, over the scrolling content.
        clipBehavior: Clip.none,
        children: [
          PositionedDirectional(
            start: -S.md,
            end: -S.md,
            top: -kNavScrimHeight,
            height: kNavScrimHeight,
            child: const _NavRamp(),
          ),
          PositionedDirectional(
            start: S.md,
            end: S.md,
            bottom: S.sm + bottomInset,
            height: kNavBarHeight,
            child: Row(
              children: [
                Expanded(
                  child: GlassBar(
                    height: kNavBarHeight,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final count = _items.length;
                        final slot = constraints.maxWidth / count;
                        return Stack(
                          children: [
                            AnimatedPositionedDirectional(
                              duration: Motion.base,
                              curve: Motion.emphasized,
                              start: slot * index + 5,
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
                                for (var i = 0; i < count; i++)
                                  Expanded(
                                    child: _NavButton(
                                      item: _items[i],
                                      selected: i == index,
                                      onTap: () => onSelected(i),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: S.sm),
                _NavAddButton(onTap: onAction),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The paper ramp under the bar: a gradient from transparent to paper with a
/// progressive blur on top of it.
class _NavRamp extends StatelessWidget {
  const _NavRamp();

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  c.paper.withValues(alpha: 0),
                  c.paper.withValues(alpha: 0.72),
                  c.paper,
                ],
                stops: const [0, 0.5, 1],
              ),
            ),
          ),
          ProgressiveBlur(height: kNavScrimHeight, maxSigma: 16),
        ],
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

/// The mint add button: a circle beside the bar, opening the movement sheet.
class _NavAddButton extends StatelessWidget {
  const _NavAddButton({required this.onTap});

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
        child: Container(
          width: kNavAddSize,
          height: kNavAddSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.mint,
            shape: BoxShape.circle,
            border: Border.all(color: c.line),
          ),
          child:
              const Icon(LucideIcons.plus, size: 26, color: Color(0xFF0E2A21)),
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

/// What the user meets before storage opens: warm paper with the Home layout
/// drawn as shimmering bones, or a real error state with a retry if storage
/// refuses to open. Never a frozen splash, never an English word.
class _BootShell extends StatelessWidget {
  const _BootShell({this.failed = false, this.onRetry});

  final bool failed;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final l10n = AppLocalizations.of(context);

    if (failed) {
      return ColoredBox(
        color: c.paper,
        child: SafeArea(
          child: InbErrorState(
            title: l10n?.loadFailedTitle ?? 'تعذّر تحميل بياناتك',
            retryLabel: l10n?.retry ?? 'أعد المحاولة',
            onRetry: onRetry,
          ),
        ),
      );
    }

    return ColoredBox(
      color: c.paper,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(S.md, S.lg, S.md, S.lg),
          child: Skeletonizer.zone(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting + wordmark.
                Bone.text(width: 168, fontSize: 44),
                const SizedBox(height: S.sm),
                // Tagline.
                Bone.text(width: 232, fontSize: 14),
                const SizedBox(height: S.lg),
                // The hero island inside its rose frame.
                Bone(height: 208, borderRadius: _bootRadius),
                const SizedBox(height: S.md),
                // The bento row.
                const Row(
                  children: [
                    Expanded(
                      child: Bone(height: 116, borderRadius: _bootRadius),
                    ),
                    SizedBox(width: S.sm),
                    Expanded(
                      child: Bone(height: 116, borderRadius: _bootRadius),
                    ),
                  ],
                ),
                const SizedBox(height: S.md),
                Bone.text(width: 140, fontSize: 22),
                const SizedBox(height: S.sm),
                const Row(
                  children: [
                    Expanded(
                      child: Bone(height: 56, borderRadius: _bootRadius),
                    ),
                    SizedBox(width: S.sm),
                    Expanded(
                      child: Bone(height: 56, borderRadius: _bootRadius),
                    ),
                    SizedBox(width: S.sm),
                    Expanded(
                      child: Bone(height: 56, borderRadius: _bootRadius),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const _bootRadius = BorderRadius.all(Radius.circular(R.card));
