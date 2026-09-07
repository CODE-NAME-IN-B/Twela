import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/routine_provider.dart';
import '../../models/routine_pattern.dart';

class RoutineSettingsScreen extends StatelessWidget {
  const RoutineSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الروتين'),
      ),
      body: Consumer<RoutineProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEnableSwitch(context, provider),
                const SizedBox(height: 24),
                if (provider.isEnabled) ...[
                  _buildPatternSection(
                    context,
                    'اقتراحات',
                    provider.suggestingPatterns,
                    provider,
                  ),
                  const SizedBox(height: 20),
                  _buildPatternSection(
                    context,
                    'تم التفعيل تلقائياً',
                    provider.autoConfirmedPatterns,
                    provider,
                  ),
                  const SizedBox(height: 20),
                  _buildPatternSection(
                    context,
                    'قيد التعلم',
                    provider.learningPatterns,
                    provider,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnableSwitch(BuildContext context, RoutineProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderLight,
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'اكتشاف الأنماط المتكررة واقتراحها',
                  style: Theme.of(context).textTheme.bodySmall,
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
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        if (patterns.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                'لا توجد أنماط',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          )
        else
          ...patterns.map((pattern) => _buildPatternTile(context, pattern, provider)),
      ],
    );
  }

  Widget _buildPatternTile(
    BuildContext context,
    RoutinePattern pattern,
    RoutineProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.autorenew,
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
                  'نمط متكرر',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '${pattern.occurrenceCount} مرات',
                  style: Theme.of(context).textTheme.bodySmall,
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
