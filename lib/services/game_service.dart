import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_session.dart';
import '../utils/curriculum.dart';

class GameService extends ChangeNotifier {
  final SharedPreferences _prefs;
  Map<String, WorldProgress> _worldsProgress = {};
  List<String> _completedDailyChallenges = [];
  int _xp = 0;
  int _level = 1;
  List<String> _unlockedAvatars = ['avatar_star'];
  String _currentAvatar = 'avatar_star';

  GameService(this._prefs) {
    _load();
  }

  int get xp => _xp;
  int get level => _level;
  String get currentAvatar => _currentAvatar;
  List<String> get unlockedAvatars => _unlockedAvatars;
  Map<String, WorldProgress> get worldsProgress => _worldsProgress;

  int get xpForNextLevel => _level * 200;
  double get xpProgress => (_xp % xpForNextLevel) / xpForNextLevel;

  void _load() {
    _xp = _prefs.getInt('game_xp') ?? 0;
    _level = _prefs.getInt('game_level') ?? 1;
    _currentAvatar = _prefs.getString('avatar') ?? 'avatar_star';
    _unlockedAvatars =
        _prefs.getStringList('unlocked_avatars') ?? ['avatar_star'];
    _completedDailyChallenges = _prefs.getStringList('daily_done') ?? [];

    final raw = _prefs.getString('worlds_progress');
    if (raw != null) {
      final Map<String, dynamic> data = json.decode(raw);
      data.forEach((k, v) {
        _worldsProgress[k] = WorldProgress.fromMap(v as Map<String, dynamic>);
      });
    }
  }

  Future<void> _save() async {
    await _prefs.setInt('game_xp', _xp);
    await _prefs.setInt('game_level', _level);
    await _prefs.setString('avatar', _currentAvatar);
    await _prefs.setStringList('unlocked_avatars', _unlockedAvatars);
    await _prefs.setStringList('daily_done', _completedDailyChallenges);
    final map = <String, dynamic>{};
    _worldsProgress.forEach((k, v) => map[k] = v.toMap());
    await _prefs.setString('worlds_progress', json.encode(map));
    notifyListeners();
  }

  Future<void> completeSession(GameSession session) async {
    final stars = session.computeStars();
    final xpGained = stars * 20 + session.score;
    _xp += xpGained;
    // Level up check
    while (_xp >= xpForNextLevel * _level) _level++;

    // Update world progress
    _worldsProgress.putIfAbsent(
      session.worldId,
      () => WorldProgress(worldId: session.worldId),
    );
    final wp = _worldsProgress[session.worldId]!;
    final prevStars = wp.skillStars[session.skillId] ?? 0;
    if (stars > prevStars) {
      wp.totalStars += stars - prevStars;
      wp.skillStars[session.skillId] = stars;
    }

    // Unlock avatars based on XP milestones
    _checkAvatarUnlocks();
    await _save();
  }

  void _checkAvatarUnlocks() {
    final milestones = {
      'avatar_unicorn': 100,
      'avatar_rocket': 300,
      'avatar_crown': 600,
      'avatar_dragon': 1000,
    };
    milestones.forEach((avatar, xpRequired) {
      if (_xp >= xpRequired && !_unlockedAvatars.contains(avatar)) {
        _unlockedAvatars.add(avatar);
      }
    });
  }

  WorldProgress getWorldProgress(String worldId) =>
      _worldsProgress[worldId] ?? WorldProgress(worldId: worldId);

  int getSkillStars(String worldId, String skillId) =>
      getWorldProgress(worldId).skillStars[skillId] ?? 0;

  bool isDailyChallengeCompleted(String id) =>
      _completedDailyChallenges.contains(id);

  Future<void> completeDailyChallenge(String id) async {
    if (!_completedDailyChallenges.contains(id)) {
      _completedDailyChallenges.add(id);
      _xp += 50;
      await _save();
    }
  }

  void changeAvatar(String avatar) {
    if (_unlockedAvatars.contains(avatar)) {
      _currentAvatar = avatar;
      _prefs.setString('avatar', avatar);
      notifyListeners();
    }
  }
}
