import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/twela_design_system.dart';
import '../theme/app_colors.dart';

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String releaseNotes;
  final String publishedAt;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.publishedAt,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    final assets = json['assets'] as List? ?? [];
    String downloadUrl = '';

    for (final asset in assets) {
      if (asset['name'].toString().endsWith('.apk')) {
        downloadUrl = asset['browser_download_url'] ?? '';
        break;
      }
    }

    return UpdateInfo(
      version: (json['tag_name'] ?? '').toString().replaceFirst('v', ''),
      downloadUrl: downloadUrl,
      releaseNotes: (json['body'] ?? '').toString(),
      publishedAt: (json['published_at'] ?? '').toString(),
    );
  }
}

class UpdateService {
  static const String _owner = 'CODE-NAME-IN-B';
  static const String _repo = 'Twela';
  static const String _githubApiUrl =
      'https://api.github.com/repos/$_owner/$_repo/releases/latest';
  static const String _lastCheckKey = 'update_last_check';
  static const String _remindLaterKey = 'update_remind_later';
  static const String _skipVersionKey = 'update_skip_version';

  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await http.get(
        Uri.parse(_githubApiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final updateInfo = UpdateInfo.fromJson(data);

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      if (_isNewerVersion(updateInfo.version, currentVersion)) {
        return updateInfo;
      }
      return null;
    } catch (e) {
      debugPrint('Error checking for update: $e');
      return null;
    }
  }

  static bool _isNewerVersion(String latest, String current) {
    final latestParts = latest.split('.').map(int.tryParse).toList();
    final currentParts = current.split('.').map(int.tryParse).toList();

    for (var i = 0; i < 3; i++) {
      final l = i < latestParts.length ? (latestParts[i] ?? 0) : 0;
      final c = i < currentParts.length ? (currentParts[i] ?? 0) : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  /// Auto-check: only shows dialog if enough time has passed since last check
  /// or remind-later has expired.
  static Future<void> autoCheckForUpdate(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;

      // Check if user selected "remind me later" — only show after 24 hours
      final remindLater = prefs.getInt(_remindLaterKey);
      if (remindLater != null && now < remindLater) {
        return; // Still within remind-later window
      }

      // Check if user skipped this version
      final skipVersion = prefs.getString(_skipVersionKey);

      // Only check once per 6 hours
      final lastCheck = prefs.getInt(_lastCheckKey);
      if (lastCheck != null && now - lastCheck < 6 * 60 * 60 * 1000) {
        return;
      }

      await prefs.setInt(_lastCheckKey, now);

      final updateInfo = await checkForUpdate();
      if (updateInfo == null || !context.mounted) return;

      // Don't show if user skipped this exact version
      if (skipVersion == updateInfo.version) return;

      if (!context.mounted) return;
      _showUpdateDialog(context, updateInfo);
    } catch (e) {
      debugPrint('Auto-update check failed: $e');
    }
  }

  static void _showUpdateDialog(BuildContext context, UpdateInfo updateInfo) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TwelaRadius.lg),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(TwelaRadius.sm),
              ),
              child: const Icon(
                Icons.system_update_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'تحديث جديد متاح',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
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
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'الإصدار الحالي: ${_currentVersionSync}',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
            if (updateInfo.releaseNotes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'ملاحظات الإصدار:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(TwelaRadius.sm),
                ),
                child: Text(
                  updateInfo.releaseNotes,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Remind me later — show again after 24 hours
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt(
                _remindLaterKey,
                DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(
              'ذكرني لاحقاً',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Skip this version
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(_skipVersionKey, updateInfo.version);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(
              'تخطى',
              style: TextStyle(
                color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showDownloadProgress(context, updateInfo);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TwelaRadius.sm),
              ),
            ),
            child: const Text('تحديث الآن'),
          ),
        ],
      ),
    );
  }

  static String _currentVersionSync = '';

  static Future<void> init() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _currentVersionSync = packageInfo.version;
  }

  static void _showDownloadProgress(BuildContext context, UpdateInfo updateInfo) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(TwelaRadius.lg),
            ),
            title: Text(
              status,
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: progress > 0 ? progress : null,
                  backgroundColor: isDark ? AppColors.darkBorder : AppColors.border,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  progress > 0 ? '${(progress * 100).toInt()}%' : '',
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    downloadAndInstall(
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

  static Future<void> downloadAndInstall(
    UpdateInfo updateInfo,
    BuildContext context, {
    Function(double progress, String status)? onProgress,
  }) async {
    if (updateInfo.downloadUrl.isEmpty) {
      throw Exception('No APK download URL available');
    }

    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/twela_update.apk';
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      }

      final dio = Dio();

      await dio.download(
        updateInfo.downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            final percentage = (progress * 100).toStringAsFixed(0);
            onProgress?.call(progress, 'جاري التحميل... $percentage%');
          }
        },
      );

      onProgress?.call(1.0, 'جاري التثبيت...');

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 26) {
          // Android 8+ requires "Install unknown apps" permission
        }
      }

      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        debugPrint('Error opening APK: ${result.message}');
        throw Exception('Failed to open APK: ${result.message}');
      }
    } catch (e) {
      debugPrint('Error downloading update: $e');
      rethrow;
    }
  }
}
