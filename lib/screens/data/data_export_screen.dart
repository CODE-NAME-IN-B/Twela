import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'dart:io';
import '../../theme/app_colors.dart';
import '../../services/storage_service.dart';
import '../../services/data_export_service.dart';
import '../../providers/twela_provider.dart';
import '../../providers/debt_provider.dart';
import '../../providers/savings_provider.dart';

class DataExportScreen extends StatefulWidget {
  const DataExportScreen({super.key});

  @override
  State<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends State<DataExportScreen> {
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('البيانات'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              theme: theme,
              isDark: isDark,
              title: 'النسخ الاحتياطي',
              children: [
                _buildActionCard(
                  context,
                  theme: theme,
                  isDark: isDark,
                  icon: Icons.upload_file_outlined,
                  title: 'تصدير البيانات',
                  subtitle: 'حفظ نسخة احتياطية من جميع بياناتك',
                  color: theme.colorScheme.primary,
                  isLoading: _isExporting,
                  onTap: _exportData,
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  context,
                  theme: theme,
                  isDark: isDark,
                  icon: Icons.download_outlined,
                  title: 'استيراد البيانات',
                  subtitle: 'استعادة بيانات من نسخة احتياطية',
                  color: const Color(0xFF8B5CF6),
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
              title: 'مشاركة',
              children: [
                _buildActionCard(
                  context,
                  theme: theme,
                  isDark: isDark,
                  icon: Icons.share_outlined,
                  title: 'مشاركة كملف',
                  subtitle: 'مشاركة ملف JSON للبيانات',
                  color: const Color(0xFF06B6D4),
                  onTap: _shareData,
                ),
                const SizedBox(height: 12),
                _buildActionCard(
                  context,
                  theme: theme,
                  isDark: isDark,
                  icon: Icons.copy_outlined,
                  title: 'نسخ البيانات',
                  subtitle: 'نسخ البيانات كنص JSON',
                  color: const Color(0xFFF59E0B),
                  onTap: _copyData,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              theme: theme,
              isDark: isDark,
              title: 'تنبيه',
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFFEF4444).withOpacity(0.1)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.danger.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_outlined,
                        color: AppColors.danger,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'سيتم استبدال جميع البيانات الحالية عند الاستيراد. تأكد من إنشاء نسخة احتياطية أولاً.',
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
      ),
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
    bool isLoading = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
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
                color: color.withOpacity(0.1),
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
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
    setState(() => _isExporting = true);
    try {
      final storage = context.read<StorageService>();
      final jsonStr = await DataExportService.exportToJson(storage);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/twela_backup_$timestamp.json');
      await file.writeAsString(jsonStr);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'نسخة احتياطية من Twela',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في التصدير: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;

      setState(() => _isImporting = true);

      final file = File(result.files.first.path!);
      final data = await DataExportService.importFromFile(file);

      if (data == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ملف غير صالح')),
          );
        }
        return;
      }

      if (mounted) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('تأكيد الاستيراد'),
            content: const Text('سيتم استبدال جميع البيانات الحالية. هل أنت متأكد؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'استيراد',
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
              const SnackBar(content: Text('تم الاستيراد بنجاح')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الاستيراد: $e')),
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
      await Share.shareXFiles([XFile(file.path)], text: 'نسخة احتياطية من Twela');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في المشاركة: $e')),
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
          const SnackBar(content: Text('تم نسخ البيانات')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في النسخ: $e')),
        );
      }
    }
  }
}
