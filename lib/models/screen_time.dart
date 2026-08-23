// ⏰ Contrôle du temps d'écran - Règle des 3-6-9-12
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenTimeService extends ChangeNotifier {
  /// Durées proposées, en minutes. 0 = aucune proposition de pause.
  static const List<int> sessionChoices = [10, 15, 20, 30, 45, 0];

  static const int dailyLimitMinutes = 45;   // repère indicatif

  final SharedPreferences _prefs;

  /// Au bout de combien de minutes proposer une pause. C'est bien une
  /// proposition à trois choix, pas une coupure : voir ScreenTimeGate.
  int _sessionLimitMinutes = 15;

  int _sessionSeconds = 0;
  int _dailySeconds   = 0;
  bool _pauseRequested = false;

  int get sessionLimitMinutes => _sessionLimitMinutes;

  String get sessionLimitLabel =>
      _sessionLimitMinutes == 0 ? 'Aucune' : '$_sessionLimitMinutes min';

  Future<void> setSessionLimit(int minutes) async {
    _sessionLimitMinutes = minutes;
    await _prefs.setInt('session_limit', minutes);
    notifyListeners();
  }

  int get sessionSeconds  => _sessionSeconds;
  int get dailySeconds    => _dailySeconds;
  bool get pauseRequested => _pauseRequested;

  double get sessionProgress => _sessionLimitMinutes == 0
      ? 0
      : _sessionSeconds / (_sessionLimitMinutes * 60);
  double get dailyProgress   => _dailySeconds   / (dailyLimitMinutes   * 60);

  String get sessionTimeLabel {
    final m = _sessionSeconds ~/ 60;
    final s = _sessionSeconds % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  void startSession() {
    _pauseRequested = false;
  }

  void tick() {
    _sessionSeconds++;
    _dailySeconds++;
    if (_sessionLimitMinutes > 0 &&
        _sessionSeconds >= _sessionLimitMinutes * 60 &&
        !_pauseRequested) {
      _pauseRequested = true;
      notifyListeners();
    }
  }

  void resetSession() {
    _sessionSeconds = 0;
    _pauseRequested = false;
    notifyListeners();
  }

  bool get dailyLimitReached => _dailySeconds >= dailyLimitMinutes * 60;

  ScreenTimeService(this._prefs) {
    _sessionLimitMinutes = _prefs.getInt('session_limit') ?? 15;
  }

  Future<void> loadToday() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final saved = _prefs.getString('screentime_date');
    if (saved == today) {
      _dailySeconds = _prefs.getInt('screentime_daily') ?? 0;
    } else {
      _dailySeconds = 0;
      await _prefs.setString('screentime_date', today);
    }
  }

  Future<void> saveToday() async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await _prefs.setString('screentime_date', today);
    await _prefs.setInt('screentime_daily', _dailySeconds);
  }
}
