import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

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

  static Future<void> downloadAndInstall(
    UpdateInfo updateInfo,
    BuildContext context, {
    Function(double progress, String status)? onProgress,
  }) async {
    if (updateInfo.downloadUrl.isEmpty) return;

    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/twela_update.apk';
      final file = File(filePath);

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

      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        debugPrint('Error opening APK: ${result.message}');
      }
    } catch (e) {
      debugPrint('Error downloading update: $e');
    }
  }
}
