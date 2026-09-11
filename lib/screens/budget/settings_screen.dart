import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/twela_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../models/budget_settings.dart';
import '../../models/app_settings.dart';
import '../../services/update_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/daftar_theme.dart';
import '../../widgets/daftar_card.dart';
import '../../widgets/twela_design_system.dart';
import '../data/data_export_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _monthlyBudgetController = TextEditingController();
  final _dailyLimitController = TextEditingController();
  final _lowBalanceController = TextEditingController();
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _currentVersion = '';
  bool _isCheckingUpdate = false;
  String _searchQuery = '';

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
    _searchController.dispose();
    _searchFocus.dispose();
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

  bool _matchesSearch(String text) {
    if (_searchQuery.isEmpty) return true;
    return text.toLowerCase().contains(_searchQuery.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DaftarTheme.darkSurface : DaftarTheme.lightSurface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeroCard(context, theme, isDark)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSearchBar(context, theme, isDark),
                  const SizedBox(height: 16),
                  if (_matchesSearch('المظهر') ||
                      _matchesSearch('فاتح') ||
                      _matchesSearch('داكن'))
                    _buildThemeSection(context, theme, isDark),
                  if (_matchesSearch('المظهر') ||
                      _matchesSearch('فاتح') ||
                      _matchesSearch('داكن'))
                    const SizedBox(height: 16),
                  if (_matchesSearch('ميزات') ||
                      _matchesSearch('اهتزاز') ||
                      _matchesSearch('زجاج') ||
                      _matchesSearch('شريط') ||
                      _matchesSearch('لون'))
                    _buildFeaturesSection(context, theme, isDark),
                  if (_matchesSearch('ميزات') ||
                      _matchesSearch('اهتزاز') ||
                      _matchesSearch('زجاج') ||
                      _matchesSearch('شريط') ||
                      _matchesSearch('لون'))
                    const SizedBox(height: 16),
                  if (_matchesSearch('تخصيص') ||
                      _matchesSearch('لون'))
                    _buildCustomizationSection(context, theme, isDark),
                  if (_matchesSearch('تخصيص') ||
                      _matchesSearch('لون'))
                    const SizedBox(height: 16),
                  if (_matchesSearch('ميزانية') ||
                      _matchesSearch('شهري') ||
                      _matchesSearch('يومي') ||
                      _matchesSearch('حد') ||
                      _matchesSearch('رصيد') ||
                      _matchesSearch('منخفض'))
                    _buildBudgetSection(context, theme, isDark),
                  if (_matchesSearch('ميزانية') ||
                      _matchesSearch('شهري') ||
                      _matchesSearch('يومي') ||
                      _matchesSearch('حد') ||
                      _matchesSearch('رصيد') ||
                      _matchesSearch('منخفض'))
                    const SizedBox(height: 16),
                  if (_matchesSearch('تحديث') || _matchesSearch('إصدار'))
                    _buildUpdateSection(context, theme, isDark),
                  if (_matchesSearch('تحديث') || _matchesSearch('إصدار'))
                    const SizedBox(height: 16),
                  if (_matchesSearch('بيانات') ||
                      _matchesSearch('تصدير') ||
                      _matchesSearch('استيراد'))
                    _buildDataSection(context, theme, isDark),
                  if (_matchesSearch('بيانات') ||
                      _matchesSearch('تصدير') ||
                      _matchesSearch('استيراد'))
                    const SizedBox(height: 16),
                  _buildDeveloperSection(context, theme, isDark),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: TwelaPrimaryButton(
                      label: 'حفظ الإعدادات',
                      onPressed: _saveSettings,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildVersionNumber(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, ThemeData theme, bool isDark) {
    final provider = context.watch<TwelaProvider>();
    final days = provider.daysSinceFirstUse;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: DaftarCard(
        showDiagonalCut: true,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Twela',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$days يوم معك',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'تتبع مصاريفك بالدينار الليبي',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: DaftarTheme.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'بحث في الإعدادات...',
          hintStyle: TextStyle(
            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: isDark ? AppColors.darkSurface : AppColors.borderLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, ThemeData theme, bool isDark) {
    final themeProvider = context.watch<ThemeProvider>();

    return DaftarCard(
      showDiagonalCut: false,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المظهر',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TwelaSegmentedControl<ThemeMode>(
            segments: const {
              ThemeMode.light: 'فاتح',
              ThemeMode.dark: 'داكن',
              ThemeMode.system: 'الجهاز',
            },
            selected: themeProvider.themeMode,
            onSelected: (mode) => themeProvider.setThemeMode(mode),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(
      BuildContext context, ThemeData theme, bool isDark) {
    final appSettings = context.watch<AppSettingsProvider>();

    return DaftarCard(
      showDiagonalCut: false,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المميزات',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TwelaSettingTile(
            icon: Icons.vibration,
            title: 'اهتزاز عند الحفظ',
            subtitle: 'نبضة خفيفة عند إضافة أي عملية',
            iconColor: AppColors.primary,
            trailing: Switch(
              value: appSettings.hapticFeedback,
              onChanged: (_) => appSettings.toggleHapticFeedback(),
              activeColor: AppColors.primary,
            ),
          ),
          TwelaSettingTile(
            icon: Icons.blur_on_outlined,
            title: 'وضع الزجاج',
            subtitle: 'خلفيات شبه شفافة للبطاقات',
            iconColor: AppColors.info,
            trailing: Switch(
              value: appSettings.glassMode,
              onChanged: (_) => appSettings.toggleGlassMode(),
              activeColor: AppColors.primary,
            ),
          ),
          TwelaSettingTile(
            icon: Icons.bar_chart_outlined,
            title: 'شريط Glyph',
            subtitle: 'معلومة سريعة أعلى الرصيد',
            iconColor: AppColors.warning,
            trailing: Switch(
              value: appSettings.showGlyphBar,
              onChanged: (_) => appSettings.toggleGlyphBar(),
              activeColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationSection(
      BuildContext context, ThemeData theme, bool isDark) {
    final appSettings = context.watch<AppSettingsProvider>();

    return DaftarCard(
      showDiagonalCut: false,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التخصيص',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'لون التمييز',
            style: theme.textTheme.titleSmall?.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(AppSettings.accentOptions.length, (index) {
              final color = AppSettings.accentOptions[index];
              final isSelected = appSettings.accentColor.value == color.value;
              return GestureDetector(
                onTap: () => appSettings.setAccentColor(color),
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetSection(
      BuildContext context, ThemeData theme, bool isDark) {
    return DaftarCard(
      showDiagonalCut: false,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الميزانية',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildBudgetField(
            context,
            theme: theme,
            isDark: isDark,
            controller: _monthlyBudgetController,
            label: 'الحد الشهري الإجمالي',
            hint: 'أدخل المبلغ',
            icon: Icons.calendar_month_outlined,
          ),
          const SizedBox(height: 12),
          _buildBudgetField(
            context,
            theme: theme,
            isDark: isDark,
            controller: _dailyLimitController,
            label: 'حد الصرف اليومي',
            hint: 'أدخل المبلغ',
            icon: Icons.today_outlined,
          ),
          const SizedBox(height: 12),
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
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: 'د.ل',
        prefixIcon: Icon(icon, size: 20),
        labelStyle: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        hintStyle: TextStyle(
          color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildDataSection(BuildContext context, ThemeData theme, bool isDark) {
    final primaryColor = AppColors.primary;

    return DaftarCard(
      showDiagonalCut: false,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'البيانات',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TwelaSettingTile(
            icon: Icons.sync_outlined,
            title: 'تصدير واستيراد',
            subtitle: 'نسخة احتياطية ومشاركة البيانات',
            iconColor: primaryColor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DataExportScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateSection(
      BuildContext context, ThemeData theme, bool isDark) {
    final primaryColor = AppColors.primary;

    return DaftarCard(
      showDiagonalCut: false,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التطبيق',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TwelaSettingTile(
            icon: Icons.system_update_outlined,
            title: 'التحقق من التحديثات',
            subtitle: 'اضغط للتحقق من إصدار جديد',
            iconColor: primaryColor,
            onTap: _isCheckingUpdate ? null : _checkForUpdate,
            trailing: _isCheckingUpdate
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection(
      BuildContext context, ThemeData theme, bool isDark) {
    final primaryColor = AppColors.primary;

    return DaftarCard(
      showDiagonalCut: false,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المطور',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.darkBackground, AppColors.darkSurface]
                    : [AppColors.borderLight, const Color(0xFFECFDF5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: primaryColor.withAlpha(50),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withAlpha(180)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withAlpha(80),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.code_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'CODE-NAME-IN-B',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Flutter Developer',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Libya',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final uri =
                        Uri.parse('https://github.com/CODE-NAME-IN-B');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withAlpha(80),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.code_outlined,
                            color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'github.com/CODE-NAME-IN-B',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'مشاريع',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildProjectItem(
            context,
            theme: theme,
            isDark: isDark,
            name: 'Twela',
            description: 'تطبيق تتبع المصاريف بالدينار الليبي',
            icon: Icons.account_balance_wallet_outlined,
            color: primaryColor,
            version:
                _currentVersion.isNotEmpty ? 'v$_currentVersion' : 'v1.1.9',
          ),
          const SizedBox(height: 8),
          _buildProjectItem(
            context,
            theme: theme,
            isDark: isDark,
            name: 'All Other Projects',
            description: 'مشاريع مفتوحة المصدر متنوعة',
            icon: Icons.folder_outlined,
            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectItem(
    BuildContext context, {
    required ThemeData theme,
    required bool isDark,
    required String name,
    required String description,
    required IconData icon,
    required Color color,
    String? version,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? DaftarTheme.darkSurface : DaftarTheme.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (version != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                version,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVersionNumber() {
    return Center(
      child: Text(
        'Twela v${_currentVersion.isNotEmpty ? _currentVersion : '1.1.9'}',
        style: GoogleFonts.silkscreen(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withAlpha(64)
              : Colors.black.withAlpha(51),
        ),
      ),
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
    final primaryColor = AppColors.primary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(38),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.system_update_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'تحديث متاح',
                style: TextStyle(
                  fontSize: 18,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
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
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'الإصدار الحالي: $_currentVersion',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
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
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  updateInfo.releaseNotes,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'لاحقاً',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showDownloadProgress(updateInfo);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('تحديث الآن'),
          ),
        ],
      ),
    );
  }

  void _showDownloadProgress(UpdateInfo updateInfo) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double progress = 0;
    String status = 'جاري التحميل...';

    late void Function(VoidCallback) dialogSetState;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          dialogSetState = setDialogState;

          return AlertDialog(
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              status,
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: progress > 0 ? progress : null,
                  backgroundColor:
                      isDark ? AppColors.darkBorder : AppColors.border,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  progress > 0 ? '${(progress * 100).toInt()}%' : '',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    UpdateService.downloadAndInstall(
      updateInfo,
      context,
      onProgress: (p, s) {
        dialogSetState(() {
          progress = p;
          status = s;
        });
      },
    );
  }
}
