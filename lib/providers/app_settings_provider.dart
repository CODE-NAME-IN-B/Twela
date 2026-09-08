import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class AppSettingsProvider extends ChangeNotifier {
  final StorageService _storage;
  AppSettings _settings = const AppSettings();

  AppSettingsProvider(this._storage) {
    _settings = _storage.getAppSettings();
  }

  AppSettings get settings => _settings;
  bool get hapticFeedback => _settings.hapticFeedback;
  bool get glassMode => _settings.glassMode;
  bool get showGlyphBar => _settings.showGlyphBar;
  bool get gpsCurrency => _settings.gpsCurrency;
  Color get accentColor => _settings.accentColor;

  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings;
    await _storage.saveAppSettings(settings);
    notifyListeners();
  }

  Future<void> toggleHapticFeedback() async {
    _settings = _settings.copyWith(hapticFeedback: !_settings.hapticFeedback);
    await _storage.saveAppSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleGlassMode() async {
    _settings = _settings.copyWith(glassMode: !_settings.glassMode);
    await _storage.saveAppSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleGlyphBar() async {
    _settings = _settings.copyWith(showGlyphBar: !_settings.showGlyphBar);
    await _storage.saveAppSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleGpsCurrency() async {
    _settings = _settings.copyWith(gpsCurrency: !_settings.gpsCurrency);
    await _storage.saveAppSettings(_settings);
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _settings = _settings.copyWith(accentColor: color);
    await _storage.saveAppSettings(_settings);
    notifyListeners();
  }
}
