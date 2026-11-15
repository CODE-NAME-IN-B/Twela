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
import '../design/format.dart';
import '../design/tokens.dart';

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

      final remindLater = prefs.getInt(_remindLaterKey);
      if (remindLater != null && now < remindLater) {
        return;
      }

      final skipVersion = prefs.getString(_skipVersionKey);

      final lastCheck = prefs.getInt(_lastCheckKey);
      if (lastCheck != null && now - lastCheck < 6 * 60 * 60 * 1000) {
        return;
      }

      await prefs.setInt(_lastCheckKey, now);

      final updateInfo = await checkForUpdate();
      if (updateInfo == null || !context.mounted) return;

      if (skipVersion == updateInfo.version) return;

      if (!context.mounted) return;
      _showUpdateDialog(context, updateInfo);
    } catch (e) {
      debugPrint('Auto-update check failed: $e');
    }
  }

  static void _showUpdateDialog(BuildContext context, UpdateInfo updateInfo) {
    final c = context.inb;
    final sem = context.sem;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(R.card),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: sem.savings.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(R.inner),
              ),
              child: Icon(Icons.system_update_outlined, color: sem.savings),
            ),
            const SizedBox(width: S.sm),
            Expanded(
              child: Text(
                'تحديث جديد متاح',
                style: TextStyle(
                  fontFamily: InbFonts.arabic,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: c.fg,
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
              'الإصدار الجديد: ${latn(updateInfo.version)}',
              style: TextStyle(
                fontFamily: InbFonts.arabic,
                fontWeight: FontWeight.w600,
                color: c.fg,
              ),
            ),
            const SizedBox(height: S.xs),
            Text(
              'الإصدار الحالي: ${latn(_currentVersionSync)}',
              style: TextStyle(
                fontFamily: InbFonts.arabic,
                fontSize: 13,
                color: c.muted,
              ),
            ),
            if (updateInfo.releaseNotes.isNotEmpty) ...[
              const SizedBox(height: S.md),
              Text(
                'ملاحظات الإصدار:',
                style: TextStyle(
                  fontFamily: InbFonts.arabic,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: c.fg,
                ),
              ),
              const SizedBox(height: S.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(S.md),
                decoration: BoxDecoration(
                  color: c.paper,
                  borderRadius: BorderRadius.circular(R.inner),
                  border: Border.all(color: c.line),
                ),
                child: Text(
                  latn(updateInfo.releaseNotes),
                  style: TextStyle(
                    fontFamily: InbFonts.arabic,
                    fontSize: 13,
                    height: 1.6,
                    color: c.muted,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt(
                _remindLaterKey,
                DateTime.now()
                    .add(const Duration(hours: 24))
                    .millisecondsSinceEpoch,
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(
              'ذكرني لاحقاً',
              style: TextStyle(
                fontFamily: InbFonts.arabic,
                color: c.muted,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(_skipVersionKey, updateInfo.version);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(
              'تخطى',
              style: TextStyle(
                fontFamily: InbFonts.arabic,
                color: c.muted,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showDownloadProgress(context, updateInfo);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: c.fg,
              foregroundColor: c.paper,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(R.pill),
              ),
            ),
            child: Text(
              'تحديث الآن',
              style: TextStyle(
                fontFamily: InbFonts.arabic,
                fontWeight: FontWeight.w700,
              ),
            ),
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

  static void _showDownloadProgress(
      BuildContext context, UpdateInfo updateInfo) {
    final c = context.inb;
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
            backgroundColor: c.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(R.card),
            ),
            title: Text(
              status,
              style: TextStyle(
                fontFamily: InbFonts.arabic,
                fontWeight: FontWeight.w700,
                color: c.fg,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(R.pill),
                  child: LinearProgressIndicator(
                    value: progress > 0 ? progress : null,
                    minHeight: 6,
                    backgroundColor: c.line,
                    color: c.fg,
                  ),
                ),
                const SizedBox(height: S.md),
                Text(
                  progress > 0 ? latn('${(progress * 100).toInt()}%') : '',
                  style: TextStyle(
                    fontFamily: InbFonts.mono,
                    fontWeight: FontWeight.w700,
                    color: c.muted,
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
