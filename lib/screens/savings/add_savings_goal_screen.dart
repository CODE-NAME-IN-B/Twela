import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/savings_provider.dart';
import '../../models/savings_goal.dart';

class AddSavingsGoalScreen extends StatefulWidget {
  const AddSavingsGoalScreen({super.key});

  @override
  State<AddSavingsGoalScreen> createState() => _AddSavingsGoalScreenState();
}

class _AddSavingsGoalScreenState extends State<AddSavingsGoalScreen> {
  final _nameController = TextEditingController();
  final _dailyTargetController = TextEditingController();
  final _durationController = TextEditingController(text: '30');

  @override
  void dispose() {
    _nameController.dispose();
    _dailyTargetController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    final name = _nameController.text.trim();
    final dailyTarget = double.tryParse(_dailyTargetController.text);
    final duration = int.tryParse(_durationController.text);

    if (name.isEmpty || dailyTarget == null || dailyTarget <= 0 || duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى ملء جميع الحقول بشكل صحيح')),
      );
      return;
    }

    final goal = SavingsGoal.create(
      name: name,
      dailyTarget: dailyTarget,
      durationDays: duration,
    );

    context.read<SavingsProvider>().addGoal(goal);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إنشاء الحصالة')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dailyTarget = double.tryParse(_dailyTargetController.text) ?? 0;
    final duration = int.tryParse(_durationController.text) ?? 30;
    final targetAmount = dailyTarget * duration;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('إنشاء حصالة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(
              controller: _nameController,
              label: 'اسم الحصالة',
              hint: 'مثال: حصالة الشهر',
              icon: Icons.label_outline,
              theme: theme,
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _dailyTargetController,
              label: 'المبلغ اليومي',
              hint: '20',
              icon: Icons.savings_outlined,
              keyboardType: TextInputType.number,
              theme: theme,
              isDark: isDark,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            _buildField(
              controller: _durationController,
              label: 'المدة (بالأيام)',
              hint: '30',
              icon: Icons.calendar_today_outlined,
              keyboardType: TextInputType.number,
              theme: theme,
              isDark: isDark,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'هدفك',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          '${targetAmount.toStringAsFixed(2)} LYD خلال $duration يوم',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveGoal,
                child: const Text('إنشاء الحصالة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ThemeData theme,
    required bool isDark,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, size: 20),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
