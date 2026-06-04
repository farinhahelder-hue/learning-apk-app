import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_models.dart';
import '../models/achievement.dart';

class GameService extends ChangeNotifier {
  final SharedPreferences _prefs;
  
  int _xp = 0;
  int _level = 1;
  int _currentCombo = 0;
  int _maxComboEver = 0;
  String? _currentAvatar;
  List<String> _unlockedAvatars = ['star'];
  List<String> _unlockedAchievements = [];
  GameSession? _currentSession;
  DailyChallenge? _todaysChallenge;

  static const Map<String, String> _avatarPrices = {
    'star': '',
    'unicorn': '200',
    'rocket': '400',
    'queen': '700',
    'dragon': '1000',
  };

  static const List<String> _avatarOrder = [
    'star',
    'unicorn',
    'rocket',
    'queen',
    'dragon',
  ];

  GameService(this._prefs) {
    _loadData();
    _generateDailyChallenge();
  }

  // --- Getters ---
  int get xp => _xp;
  int get level => _level;
  int get currentCombo => _currentCombo;
  int get maxComboEver => _maxComboEver;
  String get currentAvatar => _currentAvatar ?? 'star';
  List<String> get unlockedAvatars => _unlockedAvatars;
  List<String> get unlockedAchievements => _unlockedAchievements;
  GameSession? get currentSession => _currentSession;
  DailyChallenge? get todaysChallenge => _todaysChallenge;

  int get xpForNextLevel => _level * 100;
  int get xpProgress => _xp % (level * 100);

  String get avatarEmoji {
    switch (_currentAvatar) {
      case 'unicorn':
        return '🦄';
      case 'rocket':
        return '🚀';
      case 'queen':
        return '👸';
      case 'dragon':
        return '🐉';
      default:
        return '⭐';
    }
  }

  // --- XP & Level ---
  void addXp(int amount) {
    _xp += amount;
    _checkLevelUp();
    _saveData();
    notifyListeners();
  }

  void _checkLevelUp() {
    int xpNeeded = level * 100;
    while (_xp >= xpNeeded) {
      _xp -= xpNeeded;
      _level++;
      xpNeeded = level * 100;
    }
  }

  // --- Combo System ---
  void incrementCombo() {
    _currentCombo++;
    if (_currentCombo > _maxComboEver) {
      _maxComboEver = _currentCombo;
    }
    notifyListeners();
  }

  void resetCombo() {
    _currentCombo = 0;
    notifyListeners();
  }

  int get comboBonus {
    if (_currentCombo >= 10) return 50;
    if (_currentCombo >= 5) return 25;
    if (_currentCombo >= 3) return 10;
    return 0;
  }

  // --- Avatar System ---
  Future<bool> buyAvatar(String avatarId) async {
    if (_avatarPrices[avatarId] == null || _avatarPrices[avatarId]!.isEmpty) {
      return false;
    }
    int price = int.parse(_avatarPrices[avatarId]!);
    if (_xp < price) return false;
    _xp -= price;
    _unlockedAvatars.add(avatarId);
    _currentAvatar = avatarId;
    _saveData();
    notifyListeners();
    return true;
  }

  void selectAvatar(String avatarId) {
    if (_unlockedAvatars.contains(avatarId)) {
      _currentAvatar = avatarId;
      _saveData();
      notifyListeners();
    }
  }

  bool isAvatarUnlocked(String avatarId) =>
      _unlockedAvatars.contains(avatarId);

  // --- Session ---
  void startSession(String skillId) {
    _currentSession = GameSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      skillId: skillId,
    );
    notifyListeners();
  }

  void recordAnswer(bool correct, int basePoints) {
    if (_currentSession == null) return;

    _currentSession!.totalQuestions++;
    int pointsEarned = basePoints;

    if (correct) {
      _currentSession!.correctAnswers++;
      _currentSession!.comboMax = _currentSession!.comboMax > _currentCombo
          ? _currentSession!.comboMax
          : _currentCombo;
      pointsEarned += comboBonus;
      addXp(pointsEarned ~/ 10);
    }

    _currentSession!.score += pointsEarned;
    notifyListeners();
  }

  void endSession() {
    _currentSession?.end();
    _currentCombo = 0;
    _checkAchievements();
    _saveData();
    notifyListeners();
  }

  // --- Daily Challenge ---
  void _generateDailyChallenge() {
    final subjects = ['math', 'french', 'science'];
    final titles = [
      {'title': 'Défi calcul', 'desc': 'Résous 5 problèmes de calcul'},
      {'title': 'Quiz vocabulaire', 'desc': 'Trouve les synonymes et contraires'},
      {'title': 'Expérience scientifique', 'desc': 'Réponds aux questions science'},
    ];
    final today = DateTime.now();
    final idx = today.day % 3;

    _todaysChallenge = DailyChallenge(
      id: 'daily_${today.year}${today.month}${today.day}',
      title: titles[idx]['title']!,
      description: titles[idx]['desc']!,
      subject: subjects[idx],
      bonusXp: 50,
      date: today,
    );
  }

  void completeDailyChallenge() {
    if (_todaysChallenge != null && !_todaysChallenge!.completed) {
      _todaysChallenge!.completed = true;
      addXp(50);
      _checkAchievements();
      notifyListeners();
    }
  }

  // --- Achievements ---
  void _checkAchievements() {
    for (final def in AchievementDefinition.all) {
      if (_unlockedAchievements.contains(def.id)) continue;

      bool earned = false;
      switch (def.type) {
        case 'streak':
          // TODO: integrate with ProgressService streak
          break;
        case 'perfect':
          earned = _currentSession?.perfectScore ?? false;
          break;
        case 'combo':
          earned = (_maxComboEver >= def.requiredValue);
          break;
      }

      if (earned) {
        _unlockedAchievements.add(def.id);
      }
    }
    _saveData();
  }

  List<Achievement> getAchievements() {
    return AchievementDefinition.all.map((def) {
      if (_unlockedAchievements.contains(def.id)) {
        return def.copyWith(unlockedAt: DateTime.now());
      }
      return def;
    }).toList();
  }

  // --- Persistence ---
  void _loadData() {
    _xp = _prefs.getInt('game_xp') ?? 0;
    _level = _prefs.getInt('game_level') ?? 1;
    _maxComboEver = _prefs.getInt('game_max_combo') ?? 0;
    _currentAvatar = _prefs.getString('game_avatar');
    _unlockedAvatars =
        _prefs.getStringList('game_avatars') ?? ['star'];
    _unlockedAchievements =
        _prefs.getStringList('game_achievements') ?? [];

    String? sessionJson = _prefs.getString('game_current_session');
    if (sessionJson != null) {
      try {
        _currentSession =
            GameSession.fromMap(json.decode(sessionJson));
      } catch (_) {}
    }
  }

  void _saveData() {
    _prefs.setInt('game_xp', _xp);
    _prefs.setInt('game_level', _level);
    _prefs.setInt('game_max_combo', _maxComboEver);
    if (_currentAvatar != null) {
      _prefs.setString('game_avatar', _currentAvatar!);
    }
    _prefs.setStringList('game_avatars', _unlockedAvatars);
    _prefs.setStringList('game_achievements', _unlockedAchievements);
    if (_currentSession != null) {
      _prefs.setString('game_current_session',
          json.encode(_currentSession!.toMap()));
    }
  }

  Future<void> resetGame() async {
    _xp = 0;
    _level = 1;
    _currentCombo = 0;
    _maxComboEver = 0;
    _currentAvatar = 'star';
    _unlockedAvatars = ['star'];
    _unlockedAchievements = [];
    _currentSession = null;
    await _prefs.remove('game_xp');
    await _prefs.remove('game_level');
    await _prefs.remove('game_max_combo');
    await _prefs.remove('game_avatar');
    await _prefs.remove('game_avatars');
    await _prefs.remove('game_achievements');
    await _prefs.remove('game_current_session');
    notifyListeners();
  }
}