import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/routine_provider.dart';
import '../../providers/twela_provider.dart';
import '../../models/routine_pattern.dart';
import '../../utils/formatters.dart';

class RoutineSettingsScreen extends StatelessWidget {
  const RoutineSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('إعدادات الروتين'),
      ),
      body: Consumer<RoutineProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsetsDirectional.only(
                start: 20, top: 16, end: 20, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEnableSwitch(context, provider, isDark, theme),
                const SizedBox(height: 24),
                if (provider.isEnabled) ...[
                  _buildPatternSection(
                    context,
                    'اقتراحات',
                    provider.suggestingPatterns,
                    provider,
                    isDark,
                    theme,
                  ),
                  const SizedBox(height: 20),
                  _buildPatternSection(
                    context,
                    'تم التفعيل تلقائياً',
                    provider.autoConfirmedPatterns,
                    provider,
                    isDark,
                    theme,
                  ),
                  const SizedBox(height: 20),
                  _buildPatternSection(
                    context,
                    'قيد التعلم',
                    provider.learningPatterns,
                    provider,
                    isDark,
                    theme,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnableSwitch(BuildContext context, RoutineProvider provider,
      bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.inb.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.inb.line,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'يتعلم منك',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'اكتشاف الأنماط المتكررة واقتراحها',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: provider.isEnabled,
            onChanged: (_) => provider.toggleEnabled(),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPatternSection(
    BuildContext context,
    String title,
    List<RoutinePattern> patterns,
    RoutineProvider provider,
    bool isDark,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        if (patterns.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.inb.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: context.inb.line,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                'لا توجد أنماط',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: context.inb.muted,
                ),
              ),
            ),
          )
        else
          ...patterns.map((pattern) =>
              _buildPatternTile(context, pattern, provider, isDark, theme)),
      ],
    );
  }

  Widget _buildPatternTile(
    BuildContext context,
    RoutinePattern pattern,
    RoutineProvider provider,
    bool isDark,
    ThemeData theme,
  ) {
    final twelaProvider = context.read<TwelaProvider>();
    final category = twelaProvider.getCategoryById(pattern.categoryId);
    final categoryName = category?.name ?? 'غير محدد';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.inb.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.inb.line,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              category?.icon ?? Icons.autorenew,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  '${formatLydShort(pattern.approxAmount)} - ${pattern.occurrenceCount} مرات',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (pattern.status == PatternStatus.suggesting)
            TextButton(
              onPressed: () => provider.updatePatternStatus(
                pattern.id,
                PatternStatus.autoConfirmed,
              ),
              child: const Text('تفعيل'),
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => provider.removePattern(pattern.id),
          ),
        ],
      ),
    );
  }
}
