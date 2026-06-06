import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SoundEffect {
  correct,      // bonne réponse
  wrong,        // mauvaise réponse
  combo,        // combo x3+
  levelUp,      // montée de niveau
  starEarned,   // étoile gagnée
  buttonTap,    // clic bouton
  challengeDone,// défi du jour terminé
  unlock,       // avatar débloqué
  countdown,    // dernières secondes
  perfect,      // score parfait 3 étoiles
  success,      // son de succès glockenspiel
  birdChirp,    // chant d'oiseau (pour Billy)
  last5sec,     // 5 dernières secondes
}

enum BackgroundMusic {
  home,         // écran d'accueil - douce et joyeuse
  math,         // maths - rythmée et dynamique
  french,       // français - calme et mélodique
  science,      // sciences - curieuse et aventureuse
  results,      // résultats - festive
  challenge,    // défi du jour - épique
}

class AudioService extends ChangeNotifier {
  final AudioPlayer _bgPlayer   = AudioPlayer();
  final AudioPlayer _sfxPlayer  = AudioPlayer();
  final AudioPlayer _sfxPlayer2 = AudioPlayer(); // pour sons simultanés

  bool _musicEnabled  = true;
  bool _soundEnabled  = true;
  double _musicVolume = 0.35;
  double _sfxVolume   = 0.85;
  BackgroundMusic? _currentMusic;

  bool get musicEnabled  => _musicEnabled;
  bool get soundEnabled  => _soundEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume   => _sfxVolume;

  // Mapping effets sonores → fichier assets/sounds/
  // Note: Certains fichiers sont renommés ou inexistants, on utilise des fallbacks
  static const Map<SoundEffect, String> _sfxPaths = {
    SoundEffect.correct:       'sounds/correct.wav',
    SoundEffect.wrong:         'sounds/wrong.wav',
    SoundEffect.combo:         'sounds/combo.wav',
    SoundEffect.levelUp:       'sounds/level_up.wav',
    SoundEffect.starEarned:    'sounds/star.wav',
    SoundEffect.buttonTap:     'sounds/tap.wav',
    SoundEffect.challengeDone: 'sounds/celebrate.wav',  // fallback: celebrate.wav
    SoundEffect.unlock:        'sounds/unlock.wav',
    SoundEffect.countdown:     'sounds/countdown.wav',
    SoundEffect.perfect:       'sounds/perfect.wav',
    // Nouveaux sons: fallback vers fichiers existants
    SoundEffect.success:       'sounds/celebrate.wav',  // fallback
    SoundEffect.birdChirp:     'sounds/mascot_hello_bubulle.wav',  // fallback
    SoundEffect.last5sec:      'sounds/countdown.wav',  // fallback
  };

  // Mapping musiques → fichier assets/sounds/music/
  static const Map<BackgroundMusic, String> _musicPaths = {
    BackgroundMusic.home:      'sounds/music/music_home.wav',
    BackgroundMusic.math:      'sounds/music/music_math.wav',
    BackgroundMusic.french:    'sounds/music/music_french.wav',
    BackgroundMusic.science:   'sounds/music/music_science.wav',
    BackgroundMusic.results:   'sounds/music/music_results.wav',
    BackgroundMusic.challenge: 'sounds/music/music_challenge.wav',
  };

  AudioService() {
    _bgPlayer.setReleaseMode(ReleaseMode.loop);
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    _musicEnabled  = p.getBool('music_on')    ?? true;
    _soundEnabled  = p.getBool('sound_on')    ?? true;
    _musicVolume   = p.getDouble('music_vol') ?? 0.35;
    _sfxVolume     = p.getDouble('sfx_vol')   ?? 0.85;
    notifyListeners();
  }

  // ── Musique de fond ──────────────────────────────────────────
  Future<void> playMusic(BackgroundMusic music) async {
    if (!_musicEnabled) return;
    if (_currentMusic == music) return; // déjà en cours
    _currentMusic = music;
    await _bgPlayer.stop();
    await _bgPlayer.setVolume(_musicVolume);
    await _bgPlayer.play(AssetSource(_musicPaths[music]!));
  }

  Future<void> stopMusic() async {
    _currentMusic = null;
    await _bgPlayer.stop();
  }

  Future<void> pauseMusic() async => _bgPlayer.pause();
  Future<void> resumeMusic() async {
    if (_musicEnabled) await _bgPlayer.resume();
  }

  // ── Effets sonores ────────────────────────────────────────────
  Future<void> playSound(SoundEffect fx) async {
    if (!_soundEnabled) return;
    await _sfxPlayer.setVolume(_sfxVolume);
    await _sfxPlayer.play(AssetSource(_sfxPaths[fx]!));
  }

  /// Son simultané (ex: correct + confetti en même temps)
  Future<void> playSoundOverlap(SoundEffect fx) async {
    if (!_soundEnabled) return;
    await _sfxPlayer2.setVolume(_sfxVolume);
    await _sfxPlayer2.play(AssetSource(_sfxPaths[fx]!));
  }

  // ── Raccourcis pratiques ──────────────────────────────────────
  void onCorrectAnswer({bool isCombo = false}) {
    if (isCombo) {
      playSound(SoundEffect.combo);
    } else {
      playSound(SoundEffect.correct);
    }
  }

  void onWrongAnswer()    => playSound(SoundEffect.wrong);
  void onButtonTap()      => playSound(SoundEffect.buttonTap);
  void onLevelUp()        => playSound(SoundEffect.levelUp);
  void onStarEarned()     => playSound(SoundEffect.starEarned);
  void onPerfect()        { playSound(SoundEffect.perfect); playSoundOverlap(SoundEffect.starEarned); }
  void onUnlock()         => playSound(SoundEffect.unlock);
  void onChallengeDone()  => playSound(SoundEffect.challengeDone);
  void onCountdown()      => playSound(SoundEffect.countdown);

  // Nouveaux sons demandés
  void onBillyGreeting() => playSound(SoundEffect.birdChirp);
  void onLast5Seconds()  => playSound(SoundEffect.last5sec);

  // Jouer un son SFX personnalisé
  Future<void> playSfx(String assetPath) async {
    if (!_soundEnabled) return;
    await _sfxPlayer.setVolume(_sfxVolume);
    await _sfxPlayer.play(AssetSource(assetPath));
  }

  // Jouer musique de fond (fallback: music_home.wav si Timber_and_Tide.mp3 absent)
  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;
    await _bgPlayer.stop();
    await _bgPlayer.setVolume(_musicVolume);
    // Utiliser music_home.wav comme fallback (Timber_and_Tide.mp3 à ajouter plus tard)
    await _bgPlayer.play(AssetSource('sounds/music/music_home.wav'));
  }

  // ── Paramètres ────────────────────────────────────────────────
  Future<void> toggleMusic() async {
    _musicEnabled = !_musicEnabled;
    final p = await SharedPreferences.getInstance();
    await p.setBool('music_on', _musicEnabled);
    if (!_musicEnabled) {
      await _bgPlayer.stop();
    } else if (_currentMusic != null) {
      await playMusic(_currentMusic!);
    }
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _soundEnabled = !_soundEnabled;
    final p = await SharedPreferences.getInstance();
    await p.setBool('sound_on', _soundEnabled);
    notifyListeners();
  }

  Future<void> setMusicVolume(double v) async {
    _musicVolume = v;
    await _bgPlayer.setVolume(v);
    final p = await SharedPreferences.getInstance();
    await p.setDouble('music_vol', v);
    notifyListeners();
  }

  Future<void> setSfxVolume(double v) async {
    _sfxVolume = v;
    final p = await SharedPreferences.getInstance();
    await p.setDouble('sfx_vol', v);
    notifyListeners();
  }

  @override
  void dispose() {
    _bgPlayer.dispose();
    _sfxPlayer.dispose();
    _sfxPlayer2.dispose();
    super.dispose();
  }
}
