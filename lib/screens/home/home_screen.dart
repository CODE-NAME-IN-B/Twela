import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../design/format.dart';
import '../../design/motion.dart';
import '../../design/screen.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/debt_provider.dart';
import '../../providers/savings_provider.dart';
import '../../providers/twela_provider.dart';
import '../../widgets/balance_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.embedded = false,
    this.bottomBarHeight = 0,
    this.onOpenSettings,
    this.onOpenMovement,
  });

  /// When true the tab shell owns the scaffold; this screen renders only its body.
  final bool embedded;
  final double bottomBarHeight;
  final VoidCallback? onOpenSettings;

  /// Opens the movement sheet from the balance island's notch.
  final VoidCallback? onOpenMovement;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    final appSettings = context.watch<AppSettingsProvider>();

    // The list must stop exactly where the glass bar starts, so the last tile
    // is never hidden behind it.
    final bottomPadding = widget.embedded
        ? widget.bottomBarHeight + S.md
        : MediaQuery.of(context).padding.bottom + S.lg;

    final content = ColoredBox(
      color: c.paper,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.only(
            start: 20, top: 16, end: 20, bottom: bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: S.xs),
            _buildTagline(context),
            if (appSettings.showGlyphBar) ...[
              const SizedBox(height: S.md),
              _buildGlyphBar(context),
            ],
            const SizedBox(height: S.lg),
            BalanceCard(onAction: widget.onOpenMovement),
            const SizedBox(height: S.lg),
            _buildBento(context),
            const SizedBox(height: S.lg),
            _buildQuickActions(context),
          ],
        ),
      ),
    );

    if (widget.embedded) {
      return InbScreen(embedded: true, child: Reveal(child: content));
    }

    return Scaffold(backgroundColor: c.paper, body: SafeArea(child: content));
  }

  /// Greeting + the wordmark on the start side (right in RTL), settings on
  /// the end side — one 48 px target, no top navigation bar.
  Widget _buildHeader(BuildContext context) {
    final c = context.inb;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: c.muted,
                    ),
              ),
              const SizedBox(height: 2),
              // The wordmark: Unbounded displayStyle, 700, tight tracking.
              Text('Twela', style: displayStyle(context, size: 58)),
            ],
          ),
        ),
        const SizedBox(width: S.sm),
        PressScale(
          onTap: () {
            if (widget.onOpenSettings != null) {
              widget.onOpenSettings!();
            } else {
              Navigator.pushNamed(context, '/settings');
            }
          },
          child: Semantics(
            button: true,
            label: 'الإعدادات',
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(R.inner),
                border: Border.all(color: c.line),
              ),
              child: const Icon(LucideIcons.settings, size: 22),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagline(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.tagline,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: context.inb.muted,
          ),
    );
  }

  /// The owner's fixed line for the dawn slot; the rest of the day keeps its
  /// own greeting so the screen never lies about the hour.
  String _getGreeting() {
    final hour = DateTime.now().hour;
    final l10n = AppLocalizations.of(context)!;

    if (hour >= 5 && hour < 7) {
      return l10n.moodDawn;
    } else if (hour >= 7 && hour < 12) {
      return l10n.moodMorning;
    } else if (hour >= 12 && hour < 14) {
      return l10n.moodNoon;
    } else if (hour >= 14 && hour < 17) {
      return l10n.moodEvening;
    } else if (hour >= 17 && hour < 19) {
      return l10n.moodRest;
    } else if (hour >= 19 && hour < 22) {
      return l10n.moodNiceEvening;
    } else {
      return l10n.moodGoodEvening;
    }
  }

  /// Budget / days-left line: a slim surface row, not a card of its own.
  Widget _buildGlyphBar(BuildContext context) {
    final c = context.inb;
    return Consumer<TwelaProvider>(
      builder: (context, provider, _) {
        final now = DateTime.now();
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        final daysLeft = daysInMonth - now.day;
        final monthlyBudget = provider.budgetSettings.monthlyBudgetTotal;
        final monthSpent = provider.monthSpent;
        final l10n = AppLocalizations.of(context)!;

        String message;
        IconData icon;
        Color tone;

        if (monthlyBudget != null && monthlyBudget > 0) {
          final percent = ((monthSpent / monthlyBudget) * 100).round();
          if (percent >= 100) {
            message = l10n.budgetExceeded;
            icon = LucideIcons.triangleAlert;
            tone = context.sem.warning;
          } else if (percent >= 80) {
            message = l10n.reachedPercentOfBudget(percent);
            icon = LucideIcons.info;
            tone = c.indigo;
          } else {
            message = l10n.spentPercentOfBudget(percent);
            icon = LucideIcons.circleCheck;
            tone = context.sem.income;
          }
        } else {
          message = l10n.daysLeftInMonth(daysLeft);
          icon = LucideIcons.calendarDays;
          tone = c.muted;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: S.md, vertical: 12),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(R.inner),
            border: Border.all(color: c.line),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: tone),
              const SizedBox(width: S.sm),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontFamily: InbFonts.arabic,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.muted,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// The bento: one long tile at ~55% (الحصالة) and two small radius-18
  /// tiles stacked in the rest — all `surface`, no card inside a card, and
  /// the rose stays on the frame alone.
  Widget _buildBento(BuildContext context) {
    final c = context.inb;
    final sem = context.sem;

    return Consumer3<TwelaProvider, SavingsProvider, DebtProvider>(
      builder: (context, twela, savings, debts, _) {
        final l10n = AppLocalizations.of(context)!;
        final owedToMe = debts.collectibleDebts.fold(
          0.0,
          (sum, d) => sum + d.remaining,
        );
        final ratio = savings.totalTarget > 0
            ? (savings.totalSaved / savings.totalTarget).clamp(0.0, 1.0)
            : 0.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 11,
              child: BentoCard(
                onTap: () => Navigator.pushNamed(context, '/savings'),
                padding: const EdgeInsets.all(S.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _TileIcon(
                            icon: LucideIcons.piggyBank, tone: sem.savings),
                        const SizedBox(width: S.sm),
                        Expanded(
                          child: Text(
                            l10n.savingsGoal,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: InbFonts.arabic,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: c.fg,
                            ),
                          ),
                        ),
                        if (savings.activeGoals.isNotEmpty)
                          InbBadge('${savings.activeGoals.length}'),
                      ],
                    ),
                    const SizedBox(height: S.md),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Money(savings.totalSaved, size: 24),
                    ),
                    const SizedBox(height: S.sm),
                    InbProgress(value: ratio, color: sem.savings),
                    const SizedBox(height: S.xs),
                    Text(
                      '${l10n.savedSoFar} · ${formatPercent(ratio)}',
                      style: microStyle(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: S.sm),
            Expanded(
              flex: 9,
              child: Column(
                children: [
                  _SmallTile(
                    title: l10n.spentToday,
                    icon: LucideIcons.arrowDownLeft,
                    amount: twela.todaySpent,
                    tone: c.fg,
                    trailing: twela.budgetSettings.dailySpendingLimit != null
                        ? formatPercent(
                            twela.budgetSettings.dailySpendingLimit! > 0
                                ? twela.todaySpent /
                                    twela.budgetSettings.dailySpendingLimit!
                                : 0,
                          )
                        : null,
                    trailingTone: c.muted,
                  ),
                  const SizedBox(height: S.sm),
                  _SmallTile(
                    title: l10n.myDebts,
                    icon: LucideIcons.handCoins,
                    amount: owedToMe,
                    tone: sem.debt,
                    onTap: () => Navigator.pushNamed(context, '/debts'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// One outline capsule per action, four across: دخل / مصروف / ادخار / دين.
  Widget _buildQuickActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final actions = <_QuickAction>[
      _QuickAction(
        icon: LucideIcons.arrowUpRight,
        label: l10n.quickIncome,
        tone: context.sem.income,
        onTap: () => Navigator.pushNamed(
          context,
          '/add-transaction',
          arguments: {'type': 'income'},
        ),
      ),
      _QuickAction(
        icon: LucideIcons.arrowDownLeft,
        label: l10n.quickExpense,
        tone: context.inb.fg,
        onTap: () => Navigator.pushNamed(context, '/add-transaction'),
      ),
      _QuickAction(
        icon: LucideIcons.piggyBank,
        label: l10n.quickSavings,
        tone: context.sem.savings,
        onTap: () => Navigator.pushNamed(context, '/savings'),
      ),
      _QuickAction(
        icon: LucideIcons.handCoins,
        label: l10n.quickDebt,
        tone: context.sem.debt,
        onTap: () => Navigator.pushNamed(context, '/add-debt'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.quickActions, style: arabicDisplay(context, size: 24)),
        const SizedBox(height: S.md),
        Row(
          children: [
            for (final action in actions) ...[
              if (action != actions.first) const SizedBox(width: S.sm),
              Expanded(child: action.build(context)),
            ],
          ],
        ),
      ],
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.tone,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color tone;
  final VoidCallback onTap;

  Widget build(BuildContext context) {
    final c = context.inb;
    return PressScale(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: label,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: S.xs),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(R.pill),
            border: Border.all(color: c.line),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: tone),
              const SizedBox(height: S.xs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: InbFonts.arabic,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: c.fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({required this.icon, required this.tone});
  final IconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.paper,
        borderRadius: BorderRadius.circular(R.inner),
        border: Border.all(color: c.line),
      ),
      child: Icon(icon, size: 17, color: tone),
    );
  }
}

class _SmallTile extends StatelessWidget {
  const _SmallTile({
    required this.title,
    required this.icon,
    required this.amount,
    required this.tone,
    this.trailing,
    this.trailingTone,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final double amount;
  final Color tone;
  final String? trailing;
  final Color? trailingTone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.inb;
    return BentoCard(
      onTap: onTap,
      radius: R.inner,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: tone),
              const SizedBox(width: S.xs),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: InbFonts.arabic,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: c.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: S.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Money(amount, size: 17, color: tone),
          ),
          if (trailing != null) ...[
            const SizedBox(height: 2),
            Text(
              trailing!,
              style: microStyle(context, color: trailingTone),
            ),
          ],
        ],
      ),
    );
  }
}
