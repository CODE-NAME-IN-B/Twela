import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../design/tokens.dart';
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
import '../../l10n/generated/app_localizations.dart';
import '../../design/motion.dart';

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
      SnackBar(content: Text(AppLocalizations.of(context)!.settingsSaved)),
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
      backgroundColor:
          isDark ? DaftarTheme.darkSurface : DaftarTheme.lightSurface,
      body: Reveal(
          child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeroCard(context, theme, isDark)),
            SliverPadding(
              padding: const EdgeInsetsDirectional.only(
                  start: 20, top: 0, end: 20, bottom: 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSearchBar(context, theme, isDark),
                  const SizedBox(height: 16),
                  if (_matchesSearch(
                          AppLocalizations.of(context)!.appearance) ||
                      _matchesSearch(AppLocalizations.of(context)!.light) ||
                      _matchesSearch(AppLocalizations.of(context)!.dark))
                    _buildThemeSection(context, theme, isDark),
                  if (_matchesSearch(
                          AppLocalizations.of(context)!.appearance) ||
                      _matchesSearch(AppLocalizations.of(context)!.light) ||
                      _matchesSearch(AppLocalizations.of(context)!.dark))
                    const SizedBox(height: 16),
                  if (_matchesSearch(AppLocalizations.of(context)!.features) ||
                      _matchesSearch(AppLocalizations.of(context)!.haptics) ||
                      _matchesSearch(AppLocalizations.of(context)!.glass) ||
                      _matchesSearch(AppLocalizations.of(context)!.bar) ||
                      _matchesSearch(AppLocalizations.of(context)!.color))
                    _buildFeaturesSection(context, theme, isDark),
                  if (_matchesSearch(AppLocalizations.of(context)!.features) ||
                      _matchesSearch(AppLocalizations.of(context)!.haptics) ||
                      _matchesSearch(AppLocalizations.of(context)!.glass) ||
                      _matchesSearch(AppLocalizations.of(context)!.bar) ||
                      _matchesSearch(AppLocalizations.of(context)!.color))
                    const SizedBox(height: 16),
                  if (_matchesSearch(
                          AppLocalizations.of(context)!.customization) ||
                      _matchesSearch(AppLocalizations.of(context)!.color))
                    _buildCustomizationSection(context, theme, isDark),
                  if (_matchesSearch(
                          AppLocalizations.of(context)!.customization) ||
                      _matchesSearch(AppLocalizations.of(context)!.color))
                    const SizedBox(height: 16),
                  if (_matchesSearch(AppLocalizations.of(context)!.budget) ||
                      _matchesSearch(AppLocalizations.of(context)!.monthly) ||
                      _matchesSearch(AppLocalizations.of(context)!.daily) ||
                      _matchesSearch(AppLocalizations.of(context)!.limit) ||
                      _matchesSearch(AppLocalizations.of(context)!.balance) ||
                      _matchesSearch(AppLocalizations.of(context)!.low))
                    _buildBudgetSection(context, theme, isDark),
                  if (_matchesSearch(AppLocalizations.of(context)!.budget) ||
                      _matchesSearch(AppLocalizations.of(context)!.monthly) ||
                      _matchesSearch(AppLocalizations.of(context)!.daily) ||
                      _matchesSearch(AppLocalizations.of(context)!.limit) ||
                      _matchesSearch(AppLocalizations.of(context)!.balance) ||
                      _matchesSearch(AppLocalizations.of(context)!.low))
                    const SizedBox(height: 16),
                  if (_matchesSearch(AppLocalizations.of(context)!.update) ||
                      _matchesSearch(AppLocalizations.of(context)!.version))
                    _buildUpdateSection(context, theme, isDark),
                  if (_matchesSearch(AppLocalizations.of(context)!.update) ||
                      _matchesSearch(AppLocalizations.of(context)!.version))
                    const SizedBox(height: 16),
                  if (_matchesSearch(AppLocalizations.of(context)!.dataLabel) ||
                      _matchesSearch(AppLocalizations.of(context)!.export) ||
                      _matchesSearch(AppLocalizations.of(context)!.import))
                    _buildDataSection(context, theme, isDark),
                  if (_matchesSearch(AppLocalizations.of(context)!.dataLabel) ||
                      _matchesSearch(AppLocalizations.of(context)!.export) ||
                      _matchesSearch(AppLocalizations.of(context)!.import))
                    const SizedBox(height: 16),
                  _buildDeveloperSection(context, theme, isDark),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: TwelaPrimaryButton(
                      label: AppLocalizations.of(context)!.saveSettings,
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
      )),
    );
  }

  Widget _buildHeroCard(BuildContext context, ThemeData theme, bool isDark) {
    final provider = context.watch<TwelaProvider>();
    final days = provider.daysSinceFirstUse;

    return Padding(
      padding: const EdgeInsetsDirectional.only(
          start: 20, top: 16, end: 20, bottom: 0),
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
                    AppLocalizations.of(context)!.daysWithYou(days),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context)!.tagline,
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
              decoration: BoxDecoration(
                color: DaftarTheme.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: context.inb.onIsland,
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
          hintText: AppLocalizations.of(context)!.searchSettings,
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

  Widget _buildThemeSection(
      BuildContext context, ThemeData theme, bool isDark) {
    final themeProvider = context.watch<ThemeProvider>();

    return DaftarCard(
      showDiagonalCut: false,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.appearance,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          TwelaSegmentedControl<ThemeMode>(
            segments: {
              ThemeMode.light: AppLocalizations.of(context)!.light,
              ThemeMode.dark: AppLocalizations.of(context)!.dark,
              ThemeMode.system: AppLocalizations.of(context)!.device,
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
            AppLocalizations.of(context)!.featureHighlights,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TwelaSettingTile(
            icon: Icons.vibration,
            title: AppLocalizations.of(context)!.hapticOnSave,
            subtitle: AppLocalizations.of(context)!.hapticOnSaveSubtitle,
            iconColor: AppColors.primary,
            trailing: Switch(
              value: appSettings.hapticFeedback,
              onChanged: (_) => appSettings.toggleHapticFeedback(),
              activeThumbColor: AppColors.primary,
            ),
          ),
          TwelaSettingTile(
            icon: Icons.blur_on_outlined,
            title: AppLocalizations.of(context)!.glassMode,
            subtitle: AppLocalizations.of(context)!.glassModeSubtitle,
            iconColor: AppColors.info,
            trailing: Switch(
              value: appSettings.glassMode,
              onChanged: (_) => appSettings.toggleGlassMode(),
              activeThumbColor: AppColors.primary,
            ),
          ),
          TwelaSettingTile(
            icon: Icons.bar_chart_outlined,
            title: AppLocalizations.of(context)!.glyphBar,
            subtitle: AppLocalizations.of(context)!.glyphBarSubtitle,
            iconColor: AppColors.warning,
            trailing: Switch(
              value: appSettings.showGlyphBar,
              onChanged: (_) => appSettings.toggleGlyphBar(),
              activeThumbColor: AppColors.primary,
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
            AppLocalizations.of(context)!.personalization,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.accentColor,
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
              final isSelected =
                  appSettings.accentColor.toARGB32() == color.toARGB32();
              return PressScale(
                onTap: () => appSettings.setAccentColor(color),
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsetsDirectional.only(start: 8),
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
                      ? Icon(Icons.check, color: context.inb.onIsland, size: 18)
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
            AppLocalizations.of(context)!.budgetTitle,
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
            label: AppLocalizations.of(context)!.monthlyTotalLimit,
            hint: AppLocalizations.of(context)!.enterAmount,
            icon: Icons.calendar_month_outlined,
          ),
          const SizedBox(height: 12),
          _buildBudgetField(
            context,
            theme: theme,
            isDark: isDark,
            controller: _dailyLimitController,
            label: AppLocalizations.of(context)!.dailySpendLimit,
            hint: AppLocalizations.of(context)!.enterAmount,
            icon: Icons.today_outlined,
          ),
          const SizedBox(height: 12),
          _buildBudgetField(
            context,
            theme: theme,
            isDark: isDark,
            controller: _lowBalanceController,
            label: AppLocalizations.of(context)!.lowBalanceAlert,
            hint: AppLocalizations.of(context)!.enterMinimum,
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
        suffixText: AppLocalizations.of(context)!.currencyLyd,
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
            AppLocalizations.of(context)!.data,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TwelaSettingTile(
            icon: Icons.sync_outlined,
            title: AppLocalizations.of(context)!.exportImport,
            subtitle: AppLocalizations.of(context)!.exportImportSubtitle,
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
            AppLocalizations.of(context)!.appSection,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TwelaSettingTile(
            icon: Icons.system_update_outlined,
            title: AppLocalizations.of(context)!.checkForUpdates,
            subtitle: AppLocalizations.of(context)!.checkForUpdatesSubtitle,
            iconColor: primaryColor,
            onTap: _isCheckingUpdate ? null : _checkForUpdate,
            trailing: _isCheckingUpdate
                ? SizedBox(
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
            AppLocalizations.of(context)!.developer,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.inb.surface,
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
                    color: primaryColor.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.code_rounded,
                    color: context.inb.onIsland,
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
                PressScale(
                  onTap: () async {
                    final uri = Uri.parse('https://github.com/CODE-NAME-IN-B');
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
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.code_outlined,
                            color: context.inb.onIsland, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'github.com/CODE-NAME-IN-B',
                          style: TextStyle(
                            color: context.inb.onIsland,
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
            AppLocalizations.of(context)!.projects,
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
            description: AppLocalizations.of(context)!.appDescription,
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
            description: AppLocalizations.of(context)!.projectsSubtitle,
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
        style: TextStyle(
          fontFamily: InbFonts.pixel,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: context.inb.muted,
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
        SnackBar(content: Text(AppLocalizations.of(context)!.youAreUpToDate)),
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
        backgroundColor: context.inb.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(38),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.system_update_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.updateReady,
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
              AppLocalizations.of(context)!
                  .newVersionAvailable(updateInfo.version),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.currentVersionIs(_currentVersion),
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
                AppLocalizations.of(context)!.releaseNotesHeader,
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
                  color:
                      isDark ? AppColors.darkBackground : AppColors.borderLight,
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
              AppLocalizations.of(context)!.later,
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
              foregroundColor: context.inb.onIsland,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.updateNow),
          ),
        ],
      ),
    );
  }

  void _showDownloadProgress(UpdateInfo updateInfo) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double progress = 0;
    String status = AppLocalizations.of(context)!.loading;

    late void Function(VoidCallback) dialogSetState;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          dialogSetState = setDialogState;

          return AlertDialog(
            backgroundColor: context.inb.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              status,
              style: TextStyle(
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
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
