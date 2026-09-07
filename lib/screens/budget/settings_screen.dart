import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/twela_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/budget_settings.dart';
import '../../services/update_service.dart';
import '../../utils/formatters.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _monthlyBudgetController = TextEditingController();
  final _dailyLimitController = TextEditingController();
  final _lowBalanceController = TextEditingController();
  String _currentVersion = '';
  bool _isCheckingUpdate = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<TwelaProvider>();
    final settings = provider.budgetSettings;

    if (settings.monthlyBudgetTotal != null) {
      _monthlyBudgetController.text = settings.monthlyBudgetTotal.toString();
    }
    if (settings.dailySpendingLimit != null) {
      _dailyLimitController.text = settings.dailySpendingLimit.toString();
    }
    if (settings.lowBalanceThreshold != null) {
      _lowBalanceController.text = settings.lowBalanceThreshold.toString();
    }

    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _currentVersion = packageInfo.version;
    });
  }

  @override
  void dispose() {
    _monthlyBudgetController.dispose();
    _dailyLimitController.dispose();
    _lowBalanceController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final provider = context.read<TwelaProvider>();
    final settings = BudgetSettings(
      monthlyBudgetTotal: double.tryParse(_monthlyBudgetController.text),
      dailySpendingLimit: double.tryParse(_dailyLimitController.text),
      lowBalanceThreshold: double.tryParse(_lowBalanceController.text),
    );
    provider.updateBudgetSettings(settings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الإعدادات')),
    );
  }

  Future<void> _checkForUpdate() async {
    setState(() => _isCheckingUpdate = true);
    final updateInfo = await UpdateService.checkForUpdate();
    setState(() => _isCheckingUpdate = false);
    if (!mounted) return;

    if (updateInfo != null) {
      _showUpdateDialog(updateInfo);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أنت تستخدم أحدث إصدار')),
      );
    }
  }

  void _showUpdateDialog(UpdateInfo updateInfo) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? theme.colorScheme.primary.withOpacity(0.15)
                    : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.system_update_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'تحديث متاح',
                style: TextStyle(
                  fontSize: 18,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الإصدار الجديد: ${updateInfo.version}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'الإصدار الحالي: $_currentVersion',
              style: TextStyle(
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
            if (updateInfo.releaseNotes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'ملاحظات الإصدار:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  updateInfo.releaseNotes,
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لاحقاً'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              UpdateService.downloadAndInstall(updateInfo);
            },
            child: const Text('تحديث الآن'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'الإعدادات',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppearanceSection(context, theme, isDark),
            const SizedBox(height: 16),
            _buildSection(
              context,
              theme,
              isDark,
              'الميزانية الشهرية',
              [
                _buildBudgetField(
                  context,
                  theme: theme,
                  isDark: isDark,
                  controller: _monthlyBudgetController,
                  label: 'الحد الشهري الإجمالي',
                  hint: 'أدخل المبلغ',
                  icon: Icons.calendar_month_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              theme,
              isDark,
              'الحد اليومي',
              [
                _buildBudgetField(
                  context,
                  theme: theme,
                  isDark: isDark,
                  controller: _dailyLimitController,
                  label: 'حد الصرف اليومي',
                  hint: 'أدخل المبلغ',
                  icon: Icons.today_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              theme,
              isDark,
              'الرصيد المنخفض',
              [
                _buildBudgetField(
                  context,
                  theme: theme,
                  isDark: isDark,
                  controller: _lowBalanceController,
                  label: 'تنبيه الرصيد المنخفض',
                  hint: 'أدخل الحد الأدنى',
                  icon: Icons.warning_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildUpdateSection(context, theme, isDark),
            const SizedBox(height: 16),
            _buildDeveloperSection(context, theme, isDark),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('حفظ الإعدادات'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, ThemeData theme, bool isDark) {
    final themeProvider = context.watch<ThemeProvider>();
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المظهر',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildThemeOption(
            context,
            theme: theme,
            isDark: isDark,
            icon: Icons.light_mode_outlined,
            label: 'الوضع الفاتح',
            isSelected: themeProvider.isLight,
            onTap: () => themeProvider.setThemeMode(ThemeMode.light),
          ),
          const SizedBox(height: 8),
          _buildThemeOption(
            context,
            theme: theme,
            isDark: isDark,
            icon: Icons.dark_mode_outlined,
            label: 'الوضع الداكن',
            isSelected: themeProvider.isDark,
            onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
          ),
          const SizedBox(height: 8),
          _buildThemeOption(
            context,
            theme: theme,
            isDark: isDark,
            icon: Icons.phone_iphone_outlined,
            label: 'حسب الجهاز',
            isSelected: themeProvider.isSystem,
            onTap: () => themeProvider.setThemeMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(isDark ? 0.15 : 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: primaryColor.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isSelected ? primaryColor : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    String title,
    List<Widget> children,
  ) {
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBudgetField(
    BuildContext context, {
    required ThemeData theme,
    required bool isDark,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: 'LYD',
        prefixIcon: Icon(icon, size: 20),
        labelStyle: TextStyle(
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _buildUpdateSection(BuildContext context, ThemeData theme, bool isDark) {
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'التطبيق',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'v$_currentVersion',
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _isCheckingUpdate ? null : _checkForUpdate,
            child: Container(
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
                      color: primaryColor.withOpacity(isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _isCheckingUpdate
                        ? Padding(
                            padding: const EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primaryColor,
                            ),
                          )
                        : Icon(
                            Icons.system_update_outlined,
                            color: primaryColor,
                            size: 20,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'التحقق من التحديثات',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'اضغط للتحقق من إصدار جديد',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_left,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection(BuildContext context, ThemeData theme, bool isDark) {
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
    final primaryColor = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المطور',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse('https://github.com/CODE-NAME-IN-B');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
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
                      color: primaryColor.withOpacity(isDark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.code_outlined,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CODE-NAME-IN-B',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'github.com/CODE-NAME-IN-B',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.open_in_new,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
