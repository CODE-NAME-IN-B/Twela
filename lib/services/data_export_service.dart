import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../services/storage_service.dart';

class DataExportService {
  static Future<String> exportToJson(StorageService storage) async {
    final data = storage.exportAllData();
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    return jsonStr;
  }

  static Future<File> saveExportToFile(String jsonStr) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/twela_backup_$timestamp.json');
    await file.writeAsString(jsonStr);
    return file;
  }

  static Future<Map<String, dynamic>?> importFromJsonString(String jsonStr) async {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (!_validateImportData(data)) {
        return null;
      }
      return data;
    } catch (e) {
      debugPrint('Import error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> importFromFile(File file) async {
    try {
      final jsonStr = await file.readAsString();
      return await importFromJsonString(jsonStr);
    } catch (e) {
      debugPrint('File read error: $e');
      return null;
    }
  }

  static bool _validateImportData(Map<String, dynamic> data) {
    if (!data.containsKey('transactions') && !data.containsKey('debts')) {
      return false;
    }
    return true;
  }

  static Future<void> restoreData(StorageService storage, Map<String, dynamic> data) async {
    await storage.importAllData(data);
  }
}
