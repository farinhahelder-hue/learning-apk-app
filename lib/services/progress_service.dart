import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';
import '../utils/constants.dart';

class ProgressService extends ChangeNotifier {
  final SharedPreferences _prefs;
  late UserProgress _progress;

  ProgressService(this._prefs) {
    _loadProgress();
  }

  UserProgress get progress => _progress;

  void _loadProgress() {
    final data = _prefs.getString('user_progress');
    _progress = data != null
        ? UserProgress.fromMap(json.decode(data))
        : UserProgress(userId: 'emilie_001');
  }

  Future<void> _saveProgress() async {
    await _prefs.setString('user_progress', json.encode(_progress.toMap()));
    notifyListeners();
  }

  Future<void> addPoints(String subject, int points) async {
    _progress.totalPoints += points;
    switch (subject) {
      case 'math':
        _progress.mathPoints += points;
        break;
      case 'french':
        _progress.frenchPoints += points;
        break;
      case 'science':
        _progress.sciencePoints += points;
        break;
    }
    _checkLevelUp();
    _checkBadges();
    await _saveProgress();
  }

  void _checkLevelUp() {
    final newLevel =
        (_progress.totalPoints / AppConstants.pointsPerLevel).floor() + 1;
    if (newLevel > _progress.currentLevel) _progress.currentLevel = newLevel;
  }

  void _checkBadges() {
    for (final badge in AppConstants.badges) {
      final id = badge['id'] as String;
      if (_progress.earnedBadges.contains(id)) continue;
      bool earned = false;
      switch (id) {
        case 'first_exercise':
          earned = _progress.totalPoints > 0;
          break;
        case 'math_10':
          earned = _progress.mathPoints >= 100;
          break;
        case 'french_10':
          earned = _progress.frenchPoints >= 100;
          break;
        case 'science_10':
          earned = _progress.sciencePoints >= 100;
          break;
        case 'total_500':
          earned = _progress.totalPoints >= 500;
          break;
      }
      if (earned) _progress.earnedBadges.add(id);
    }
  }

  Future<void> updateStreak() async {
    final now = DateTime.now();
    final diff = now.difference(_progress.lastPlayDate).inDays;
    if (diff == 1)
      _progress.streakDays++;
    else if (diff > 1) _progress.streakDays = 1;
    _progress.lastPlayDate = now;
    await _saveProgress();
  }

  int getSubjectProgress(String subject) {
    switch (subject) {
      case 'math':
        return _progress.mathPoints;
      case 'french':
        return _progress.frenchPoints;
      case 'science':
        return _progress.sciencePoints;
      default:
        return 0;
    }
  }

  Future<void> resetProgress() async {
    _progress = UserProgress(userId: 'emilie_001');
    await _saveProgress();
  }
}
