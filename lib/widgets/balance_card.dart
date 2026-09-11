import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/daftar_theme.dart';
import '../widgets/daftar_card.dart';
import '../utils/daftar_number_style.dart';
import '../providers/twela_provider.dart';
import '../providers/app_settings_provider.dart';
import '../utils/formatters.dart';

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final glassMode = context.watch<AppSettingsProvider>().glassMode;

    Widget card = Consumer<TwelaProvider>(
      builder: (context, provider, _) {
        return GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            setState(() => _isExpanded = !_isExpanded);
          },
          onTapCancel: () => _controller.reverse(),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: DaftarCard(
              showDiagonalCut: true,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الرصيد الإجمالي',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark
                              // ignore: deprecated_member_use
                              ? DaftarTheme.accent.withOpacity(0.1)
                              // ignore: deprecated_member_use
                              : DaftarTheme.accent.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            // ignore: deprecated_member_use
                            color: DaftarTheme.accent.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'د.ل',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    formatLyd(provider.totalBalance),
                    style: daftarNumberStyle(
                      fontSize: 28,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: _isExpanded
                        ? Column(
                            children: [
                              _buildExpandedStats(context, provider, isDark),
                              const SizedBox(height: 16),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  Row(
                    children: [
                      _buildMiniStat(
                        context,
                        'اليوم',
                        formatLydShort(provider.todaySpent),
                        Icons.today_outlined,
                        isDark,
                      ),
                      const SizedBox(width: 16),
                      _buildMiniStat(
                        context,
                        'الشهر',
                        formatLydShort(provider.monthSpent),
                        Icons.calendar_month_outlined,
                        isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (glassMode) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: card,
        ),
      );
    }

    return card;
  }

  Widget _buildExpandedStats(
      BuildContext context, TwelaProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            // ignore: deprecated_member_use
            ? AppColors.darkBorder.withOpacity(0.3)
            // ignore: deprecated_member_use
            : AppColors.borderLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              context, 'كاش', formatLydShort(provider.cashBalance), isDark),
          _buildStatItem(
              context, 'مصرف', formatLydShort(provider.bankBalance), isDark),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.textTertiary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: daftarNumberStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              // ignore: deprecated_member_use
              ? AppColors.darkBorder.withOpacity(0.3)
              // ignore: deprecated_member_use
              : AppColors.borderLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.textTertiary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.textTertiary,
                          fontSize: 11,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: daftarNumberStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
