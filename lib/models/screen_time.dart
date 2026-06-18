// ⏰ Contrôle du temps d'écran - Règle des 3-6-9-12
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenTimeService extends ChangeNotifier {
  static const int sessionLimitMinutes = 15; // pause oblig. après 15 min
  static const int dailyLimitMinutes = 45; // max par jour

  int _sessionSeconds = 0;
  int _dailySeconds = 0;
  bool _pauseRequested = false;
  DateTime? _sessionStart;

  int get sessionSeconds => _sessionSeconds;
  int get dailySeconds => _dailySeconds;
  bool get pauseRequested => _pauseRequested;

  double get sessionProgress => _sessionSeconds / (sessionLimitMinutes * 60);
  double get dailyProgress => _dailySeconds / (dailyLimitMinutes * 60);

  String get sessionTimeLabel {
    final m = _sessionSeconds ~/ 60;
    final s = _sessionSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void startSession() {
    _sessionStart = DateTime.now();
    _pauseRequested = false;
  }

  void tick() {
    _sessionSeconds++;
    _dailySeconds++;
    if (_sessionSeconds >= sessionLimitMinutes * 60 && !_pauseRequested) {
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

  Future<void> loadToday() async {
    final p = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final saved = p.getString('screentime_date');
    if (saved == today) {
      _dailySeconds = p.getInt('screentime_daily') ?? 0;
    } else {
      _dailySeconds = 0;
      await p.setString('screentime_date', today);
    }
  }

  Future<void> saveToday() async {
    final p = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await p.setString('screentime_date', today);
    await p.setInt('screentime_daily', _dailySeconds);
  }
}
