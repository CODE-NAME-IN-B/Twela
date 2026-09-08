import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/twela_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/wallet_mini_card.dart';
import '../../widgets/limit_progress_bar.dart';
import '../../utils/formatters.dart';
import '../../utils/motivational_messages.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: isDark
                  ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
                  : [theme.colorScheme.primary.withOpacity(0.08), Colors.white],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: () async {},
            color: theme.colorScheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
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
                const BalanceCard(),
                const SizedBox(height: 20),
                _buildWalletCards(context),
                const SizedBox(height: 24),
                _buildTodaySpending(context, theme, isDark),
                const SizedBox(height: 24),
                _buildQuickActions(context, theme, isDark),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    final logoAsset = isDark ? 'assets/logo/twela_logo_mono.png' : 'assets/logo/twela_logo.png';

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
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.15),
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
                      color: theme.colorScheme.primary,
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
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Twela',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
        _buildNotificationButton(context, theme, isDark),
      ],
    );
  }

  Widget _buildMotivationalMessage(BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.primary.withOpacity(0.06)
            : theme.colorScheme.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Text(
        _motivationalMessage,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
      return 'الفجر يناديك';
    } else if (hour >= 7 && hour < 12) {
      return 'صباح النشاط';
    } else if (hour >= 12 && hour < 14) {
      return 'ظهيرة مثالية';
    } else if (hour >= 14 && hour < 17) {
      return 'مساء النشاط';
    } else if (hour >= 17 && hour < 19) {
      return 'وقت الراحة';
    } else if (hour >= 19 && hour < 22) {
      return 'مساء جميل';
    } else {
      return 'مساء الخير';
    }
  }

  Widget _buildNotificationButton(BuildContext context, ThemeData theme, bool isDark) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا توجد إشعارات جديدة',
              style: TextStyle(
                color: isDark ? const Color(0xFFF1F5F9) : Colors.white,
              ),
            ),
            backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFF334155),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.primary.withOpacity(0.1)
              : const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.notifications_outlined,
          color: theme.colorScheme.primary,
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
            message = 'تجاوزت ميزانيتك الشهرية';
            icon = Icons.warning_amber_outlined;
          } else if (percent >= 80) {
            message = 'وصلت $percent% من ميزانيتك';
            icon = Icons.info_outline;
          } else {
            message = 'صرفت $percent% من ميزانيتك';
            icon = Icons.check_circle_outline;
          }
        } else {
          message = 'بقي $daysLeft يوم على نهاية الشهر';
          icon = Icons.calendar_today_outlined;
        }

        final surfaceColor = isDark
            ? const Color(0xFF1E293B).withOpacity(0.5)
            : Colors.white.withOpacity(0.6);
        final borderColor = isDark
            ? const Color(0xFF334155).withOpacity(0.5)
            : const Color(0xFFE2E8F0).withOpacity(0.7);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
    final theme = Theme.of(context);

    return Consumer<TwelaProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            Expanded(
              child: WalletMiniCard(
                title: 'كاش',
                amount: provider.cashBalance,
                icon: Icons.money_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: WalletMiniCard(
                title: 'مصرف',
                amount: provider.bankBalance,
                icon: Icons.account_balance_outlined,
                color: const Color(0xFF10B981),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTodaySpending(BuildContext context, ThemeData theme, bool isDark) {
    return Consumer<TwelaProvider>(
      builder: (context, provider, _) {
        final dailyLimit = provider.budgetSettings.dailySpendingLimit;
        final todaySpent = provider.todaySpent;
        final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
        final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
          ),
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
                              ? theme.colorScheme.primary.withOpacity(0.15)
                              : const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.12),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'صرف اليوم',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    formatLyd(todaySpent),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
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
                    Text(
                      'الحد: ${formatLyd(dailyLimit)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      '${((todaySpent / dailyLimit) * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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

  Widget _buildQuickActions(BuildContext context, ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات سريعة',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
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
                label: 'إضافة صرف',
                color: const Color(0xFFE5484D),
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
                label: 'إضافة دخل',
                color: const Color(0xFF149C6D),
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
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
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
