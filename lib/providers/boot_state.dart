import 'package:flutter/widgets.dart';

import '../services/storage_service.dart';

/// The loading / error state every data provider shares.
///
/// Four states per screen is the plan's rule, and they all hang off this:
/// `isLoading` → skeleton, `loadFailed` → «أعد المحاولة», empty data → one
/// action, otherwise → content.
mixin BootState on ChangeNotifier {
  bool _isLoading = true;
  bool _loadFailed = false;

  bool get isLoading => _isLoading;
  bool get loadFailed => _loadFailed;

  /// Boot [load] out of [storage].
  ///
  /// When storage is already warm (unit tests, hot restart) the load runs
  /// synchronously, exactly as the constructor did before. On a real cold
  /// start it waits for storage and then defers to the end of the next frame,
  /// so the screen has painted its skeleton before the data lands.
  void boot(StorageService storage, void Function() load) {
    if (storage.isReady) {
      _run(load);
      return;
    }
    _isLoading = true;
    storage.ensureInitialized().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _run(load));
    }).catchError((Object _, StackTrace __) {
      _isLoading = false;
      _loadFailed = true;
      notifyListeners();
    });
  }

  /// Re-run the load after a failure — the action behind «أعد المحاولة».
  void retryBoot(StorageService storage, void Function() load) {
    _isLoading = true;
    _loadFailed = false;
    notifyListeners();
    boot(storage, load);
  }

  void _run(void Function() load) {
    _isLoading = false;
    try {
      load();
      _loadFailed = false;
    } catch (_) {
      // Corrupt JSON in storage: keep whatever loaded, flag the failure, and
      // let the screen offer a retry instead of crashing.
      _loadFailed = true;
    }
    notifyListeners();
  }
}
