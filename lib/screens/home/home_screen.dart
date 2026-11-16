import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../design/screen.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../providers/twela_provider.dart';
import '../../providers/savings_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/daftar_theme.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/daftar_card.dart';
import '../../widgets/wallet_mini_card.dart';
import '../../widgets/limit_progress_bar.dart';
import '../../utils/motivational_messages.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design/format.dart';
import '../../design/motion.dart';

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
  late final String _motivationalMessage;

  @override
  void initState() {
    super.initState();
    _motivationalMessage = getRandomMotivationalMessage();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appSettings = context.watch<AppSettingsProvider>();

    final content = Container(
      decoration: BoxDecoration(color: context.inb.paper),
      child: RefreshIndicator(
        onRefresh: () async {},
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsetsDirectional.only(
              start: 20, top: 16, end: 20, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, theme, isDark),
              const SizedBox(height: 6),
              _buildMotivationalMessage(context, theme, isDark),
              if (appSettings.showGlyphBar) ...[
                const SizedBox(height: 12),
                _buildGlyphBar(context, theme, isDark),
              ],
              const SizedBox(height: 24),
              BalanceCard(onAction: widget.onOpenMovement),
              const SizedBox(height: 20),
              _buildWalletCards(context),
              const SizedBox(height: 20),
              _buildSavingsTile(context),
              const SizedBox(height: 24),
              _buildTodaySpending(context, theme, isDark),
              const SizedBox(height: 24),
              _buildQuickActions(context, theme, isDark),
            ],
          ),
        ),
      ),
    );

    if (widget.embedded) {
      return InbScreen(embedded: true, child: Reveal(child: content));
    }

    return Scaffold(
      backgroundColor:
          isDark ? DaftarTheme.darkSurface : DaftarTheme.lightSurface,
      body: SafeArea(child: content),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    final logoAsset = isDark
        ? 'assets/logo/twela_logo_mono.png'
        : 'assets/logo/twela_logo.png';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.primary.withAlpha(25)
                    : AppColors.primarySurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary.withAlpha(38),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  logoAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.primary,
                      size: 22,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Twela',
                  style: displayStyle(context, size: 34),
                ),
              ],
            ),
          ],
        ),
        _buildNotificationButton(context, theme, isDark),
      ],
    );
  }

  Widget _buildMotivationalMessage(
      BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primary.withAlpha(15)
            : AppColors.primary.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withAlpha(30),
          width: 1,
        ),
      ),
      child: Text(
        _motivationalMessage,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          fontStyle: FontStyle.italic,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 7) {
      return AppLocalizations.of(context)!.moodDawn;
    } else if (hour >= 7 && hour < 12) {
      return AppLocalizations.of(context)!.moodMorning;
    } else if (hour >= 12 && hour < 14) {
      return AppLocalizations.of(context)!.moodNoon;
    } else if (hour >= 14 && hour < 17) {
      return AppLocalizations.of(context)!.moodEvening;
    } else if (hour >= 17 && hour < 19) {
      return AppLocalizations.of(context)!.moodRest;
    } else if (hour >= 19 && hour < 22) {
      return AppLocalizations.of(context)!.moodNiceEvening;
    } else {
      return AppLocalizations.of(context)!.moodGoodEvening;
    }
  }

  Widget _buildNotificationButton(
      BuildContext context, ThemeData theme, bool isDark) {
    return PressScale(
      onTap: () {
        if (widget.onOpenSettings != null) {
          widget.onOpenSettings!();
        } else {
          Navigator.pushNamed(context, '/settings');
        }
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.primary.withAlpha(25)
              : AppColors.primarySurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withAlpha(30),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.settings_outlined,
          color: AppColors.primary,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildGlyphBar(BuildContext context, ThemeData theme, bool isDark) {
    return Consumer<TwelaProvider>(
      builder: (context, provider, _) {
        final now = DateTime.now();
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        final daysLeft = daysInMonth - now.day;
        final monthlyBudget = provider.budgetSettings.monthlyBudgetTotal;
        final monthSpent = provider.monthSpent;

        String message;
        IconData icon;

        if (monthlyBudget != null && monthlyBudget > 0) {
          final percent = ((monthSpent / monthlyBudget) * 100).round();
          if (percent >= 100) {
            message = AppLocalizations.of(context)!.budgetExceeded;
            icon = Icons.warning_amber_outlined;
          } else if (percent >= 80) {
            message =
                AppLocalizations.of(context)!.reachedPercentOfBudget(percent);
            icon = Icons.info_outline;
          } else {
            message =
                AppLocalizations.of(context)!.spentPercentOfBudget(percent);
            icon = Icons.check_circle_outline;
          }
        } else {
          message = AppLocalizations.of(context)!.daysLeftInMonth(daysLeft);
          icon = Icons.calendar_today_outlined;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withAlpha(128)
                : context.inb.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorder.withAlpha(128)
                  : AppColors.border.withAlpha(180),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletCards(BuildContext context) {
    return Consumer<TwelaProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            Expanded(
              child: WalletMiniCard(
                title: AppLocalizations.of(context)!.cash,
                amount: provider.cashBalance,
                icon: Icons.money_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: WalletMiniCard(
                title: AppLocalizations.of(context)!.bank,
                amount: provider.bankBalance,
                icon: Icons.account_balance_outlined,
                color: AppColors.success,
              ),
            ),
          ],
        );
      },
    );
  }

  /// The rose savings tile: the single promo tile per screen rule, and the
  /// only entry point to the savings feature from home.
  Widget _buildSavingsTile(BuildContext context) {
    return Consumer<SavingsProvider>(
      builder: (context, savings, _) {
        final c = context.inb;
        return BentoCard(
          tone: BentoTone.rose,
          onTap: () => Navigator.pushNamed(context, '/savings'),
          padding: const EdgeInsets.all(S.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.onRose.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(R.inner),
                ),
                child: Icon(Icons.savings_outlined, color: c.onRose, size: 20),
              ),
              const SizedBox(width: S.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.savingsGoal,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: InbFonts.arabic,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: c.onRose,
                            ),
                          ),
                        ),
                        InbBadge('${savings.activeGoals.length}'),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.savedSoFar,
                          style: TextStyle(
                            fontFamily: InbFonts.arabic,
                            fontSize: 12,
                            color: c.onRose.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(width: S.sm),
                        Money(
                          savings.totalSaved,
                          size: 14,
                          color: c.onRose,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: S.sm),
              Icon(Icons.chevron_right, size: 18, color: c.onRose),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodaySpending(
      BuildContext context, ThemeData theme, bool isDark) {
    return Consumer<TwelaProvider>(
      builder: (context, provider, _) {
        final dailyLimit = provider.budgetSettings.dailySpendingLimit;
        final todaySpent = provider.todaySpent;

        return DaftarCard(
          showDiagonalCut: false,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primary.withAlpha(38)
                              : AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withAlpha(30),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.spentToday,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Money(
                    todaySpent,
                    size: 18,
                    weight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ],
              ),
              if (dailyLimit != null) ...[
                const SizedBox(height: 16),
                LimitProgressBar(
                  current: todaySpent,
                  limit: dailyLimit,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${AppLocalizations.of(context)!.limit}: ',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        Money(
                          dailyLimit,
                          size: 13,
                          weight: FontWeight.w400,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ],
                    ),
                    Text(
                      dailyLimit > 0
                          ? '${((todaySpent / dailyLimit) * 100).toStringAsFixed(0)}%'
                          : '0%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(
      BuildContext context, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.quickActions,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickAction(
                context,
                theme: theme,
                isDark: isDark,
                icon: Icons.arrow_upward_rounded,
                label: AppLocalizations.of(context)!.addExpense,
                color: AppColors.expense,
                onTap: () => Navigator.pushNamed(context, '/add-transaction'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickAction(
                context,
                theme: theme,
                isDark: isDark,
                icon: Icons.arrow_downward_rounded,
                label: AppLocalizations.of(context)!.addIncome,
                color: AppColors.income,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/add-transaction',
                  arguments: {'type': 'income'},
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return PressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: context.inb.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color.withAlpha(38),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
