import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../data/app_version_repository.dart';
import '../models/app_version_config.dart';

class AppVersionProvider extends ChangeNotifier {
  final AppVersionRepository _repository;
  StreamSubscription<AppVersionConfig>? _subscription;

  AppVersionConfig _config = const AppVersionConfig();
  String _currentVersion = '0.0.0';
  bool _ready = false;

  AppVersionProvider(this._repository) {
    _init();
  }

  bool get isReady => _ready;
  String get currentVersion => _currentVersion;
  AppVersionConfig get config => _config;

  /// true si la version installée est strictement inférieure à minVersion.
  bool get mustUpdate =>
      _ready && compareVersions(_currentVersion, _config.minVersion) < 0;
  bool get hasUpdate =>
    _ready && compareVersions(_currentVersion, _config.latestVersion) < 0;
  Future<void> _init() async {
    final info = await PackageInfo.fromPlatform();
    _currentVersion = info.version;
    _subscription = _repository.watch().listen((config) {
      _config = config;
      _ready = true;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}