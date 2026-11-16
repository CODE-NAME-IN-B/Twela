import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../theme/app_colors.dart';
import '../../services/storage_service.dart';
import '../../services/data_export_service.dart';
import '../../providers/twela_provider.dart';
import '../../providers/debt_provider.dart';
import '../../providers/savings_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../design/motion.dart';
import '../../design/theme.dart';
import '../../design/widgets.dart';

class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  bool _isExporting = false;
  bool _isImporting = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_error != null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.data),
        ),
        body: InbErrorState(
          title: AppLocalizations.of(context)!.exportFailed(_error!),
          retryLabel: AppLocalizations.of(context)!.back,
          onRetry: () => setState(() => _error = null),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.data),
      ),
      body: Reveal(
          child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.only(
            start: 20, top: 16, end: 20, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetadataCell(context),
            const SizedBox(height: 16),
            _buildSection(
              context,
              theme: theme,
              isDark: isDark,
              title: AppLocalizations.of(context)!.backup,
              children: [
                _buildActionCard(
                  context,
                  theme: theme,
                  isDark: isDark,
                  icon: Icons.upload_file_outlined,
                  title: AppLocalizations.of(context)!.exportData,
                  subtitle: AppLocalizations.of(context)!.exportDataSubtitle,
                  color: theme.colorScheme.primary,
                  rose: true,
                  isLoading: _isExporting,
                  onTap: _exportData,
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  context,
                  theme: theme,
                  isDark: isDark,
                  icon: Icons.download_outlined,
                  title: AppLocalizations.of(context)!.importData,
                  subtitle: AppLocalizations.of(context)!.importDataSubtitle,
                  color: context.inb.indigo,
                  isLoading: _isImporting,
                  onTap: _importData,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              theme: theme,
              isDark: isDark,
              title: AppLocalizations.of(context)!.share,
              children: [
                _buildActionCard(
                  context,
                  theme: theme,
                  isDark: isDark,
                  icon: Icons.share_outlined,
                  title: AppLocalizations.of(context)!.shareAsFile,
                  subtitle: AppLocalizations.of(context)!.shareAsFileSubtitle,
                  color: context.sem.savings,
                  onTap: _shareData,
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  context,
                  theme: theme,
                  isDark: isDark,
                  icon: Icons.copy_outlined,
                  title: AppLocalizations.of(context)!.copyData,
                  subtitle: AppLocalizations.of(context)!.copyDataSubtitle,
                  color: context.sem.warning,
                  onTap: _copyData,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              theme: theme,
              isDark: isDark,
              title: AppLocalizations.of(context)!.alert,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.sem.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: AppColors.danger,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.importWarning,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      )),
    );
  }

  /// Metadata cell: what is inside the backup, in mono digits.
  Widget _buildMetadataCell(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Consumer3<TwelaProvider, DebtProvider, SavingsProvider>(
      builder: (context, twela, debts, savings, _) {
        Widget metric(String label, int value) {
          return Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: InbFonts.arabic,
                    fontSize: 13,
                    color: context.inb.muted,
                  ),
                ),
              ),
              Text('$value', style: monoStyle(context, size: 14)),
            ],
          );
        }

        return CellFrame(
          label: l.dataLabel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              metric(l.activityLog, twela.transactions.length),
              const SizedBox(height: S.sm),
              metric(l.debts, debts.debts.length),
              const SizedBox(height: S.sm),
              metric(l.savingsGoal, savings.activeGoals.length),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required ThemeData theme,
    required bool isDark,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.inb.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.inb.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    bool rose = false,
    bool isLoading = false,
    required VoidCallback onTap,
  }) {
    if (rose) {
      // The one promo tile of this screen: the primary export action.
      final c = context.inb;
      final fg = c.onRose;
      return BentoCard(
        tone: BentoTone.rose,
        onTap: isLoading ? null : onTap,
        padding: const EdgeInsets.all(S.md),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: fg.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(R.inner),
              ),
              child: isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child:
                          CircularProgressIndicator(strokeWidth: 2, color: fg),
                    )
                  : Icon(icon, color: fg, size: 20),
            ),
            const SizedBox(width: S.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: InbFonts.arabic,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: InbFonts.arabic,
                      fontSize: 12,
                      color: fg.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return PressScale(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.inb.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color,
                      ),
                    )
                  : Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.inb.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData() async {
    setState(() => _error = null);
    setState(() => _isExporting = true);
    try {
      final storage = context.read<StorageService>();
      final jsonStr = await DataExportService.exportToJson(storage);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/twela_backup_$timestamp.json');
      await file.writeAsString(jsonStr);

      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        text: AppLocalizations.of(context)!.twelaBackup,
      ));
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _importData() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (files.isEmpty) return;

      setState(() => _isImporting = true);

      final file = File(files.first.path!);
      final data = await DataExportService.importFromFile(file);

      if (data == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.invalidFile)),
          );
        }
        return;
      }

      if (mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.confirmImport),
            content: Text(AppLocalizations.of(context)!.confirmImportBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  AppLocalizations.of(context)!.import,
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          final storage = context.read<StorageService>();
          await DataExportService.restoreData(storage, data);
          // Refresh all provider in-memory state after import
          if (mounted) {
            context.read<TwelaProvider>().reloadData();
            context.read<DebtProvider>().reloadData();
            context.read<SavingsProvider>().reloadData();
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(AppLocalizations.of(context)!.importSucceeded)),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.importFailed(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<void> _shareData() async {
    try {
      final storage = context.read<StorageService>();
      final jsonStr = await DataExportService.exportToJson(storage);
      final file = await DataExportService.saveExportToFile(jsonStr);
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path)],
        text: AppLocalizations.of(context)!.twelaBackup,
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.shareFailed(e))),
        );
      }
    }
  }

  Future<void> _copyData() async {
    try {
      final storage = context.read<StorageService>();
      final jsonStr = await DataExportService.exportToJson(storage);
      await Clipboard.setData(ClipboardData(text: jsonStr));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.dataCopied)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.copyFailed(e))),
        );
      }
    }
  }
}
