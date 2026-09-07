import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/routine_pattern.dart';
import '../services/storage_service.dart';
import '../services/routine_detection_service.dart';

class RoutineProvider extends ChangeNotifier {
  final StorageService _storage;
  static const _uuid = Uuid();

  List<RoutinePattern> _patterns = [];
  bool _isEnabled = true;

  RoutineProvider(this._storage) {
    _patterns = _storage.getPatterns();
  }

  List<RoutinePattern> get patterns => _patterns;
  bool get isEnabled => _isEnabled;

  List<RoutinePattern> get learningPatterns =>
      _patterns.where((p) => p.status == PatternStatus.learning).toList();
  List<RoutinePattern> get suggestingPatterns =>
      _patterns.where((p) => p.status == PatternStatus.suggesting).toList();
  List<RoutinePattern> get autoConfirmedPatterns =>
      _patterns.where((p) => p.status == PatternStatus.autoConfirmed).toList();

  Future<void> updatePatternStatus(String patternId, PatternStatus status) async {
    final index = _patterns.indexWhere((p) => p.id == patternId);
    if (index != -1) {
      _patterns[index].status = status;
      await _storage.savePatterns(_patterns);
      notifyListeners();
    }
  }

  Future<void> removePattern(String id) async {
    _patterns.removeWhere((p) => p.id == id);
    await _storage.savePatterns(_patterns);
    notifyListeners();
  }

  void toggleEnabled() {
    _isEnabled = !_isEnabled;
    notifyListeners();
  }
}
