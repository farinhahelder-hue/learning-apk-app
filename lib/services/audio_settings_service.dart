import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de paramètres audio persistés
/// Gère musicEnabled et sfxEnabled via SharedPreferences
class AudioSettingsService extends ChangeNotifier {
  final SharedPreferences _prefs;
  
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  double _musicVolume = 0.35;
  double _sfxVolume = 0.85;

  AudioSettingsService(this._prefs) {
    _loadSettings();
  }

  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume => _sfxVolume;

  void _loadSettings() {
    _musicEnabled = _prefs.getBool('music_on') ?? true;
    _sfxEnabled = _prefs.getBool('sound_on') ?? true;
    _musicVolume = _prefs.getDouble('music_vol') ?? 0.35;
    _sfxVolume = _prefs.getDouble('sfx_vol') ?? 0.85;
    notifyListeners();
  }

  Future<void> setMusicEnabled(bool value) async {
    _musicEnabled = value;
    await _prefs.setBool('music_on', value);
    notifyListeners();
  }

  Future<void> setSfxEnabled(bool value) async {
    _sfxEnabled = value;
    await _prefs.setBool('sound_on', value);
    notifyListeners();
  }

  Future<void> setMusicVolume(double value) async {
    _musicVolume = value.clamp(0.0, 1.0);
    await _prefs.setDouble('music_vol', _musicVolume);
    notifyListeners();
  }

  Future<void> setSfxVolume(double value) async {
    _sfxVolume = value.clamp(0.0, 1.0);
    await _prefs.setDouble('sfx_vol', _sfxVolume);
    notifyListeners();
  }

  Future<void> toggleMusic() async {
    await setMusicEnabled(!_musicEnabled);
  }

  Future<void> toggleSfx() async {
    await setSfxEnabled(!_sfxEnabled);
  }
}