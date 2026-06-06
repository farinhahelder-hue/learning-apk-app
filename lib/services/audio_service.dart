import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sons disponibles pour Emilie App
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
  // Nouveaux sons demandés
  confetti,     // son confettis
  levelComplete,// son niveau terminé
  applause,     // applaudissements
}

/// Catégories de musique de fond
enum BackgroundMusic {
  home,         // écran d'accueil - douce et joyeuse
  math,         // maths - rythmée et dynamique
  french,       // français - calme et mélodique
  science,      // sciences - curieuse et aventureuse
  results,      // résultats - festive
  challenge,    // défi du jour - épique
}

class AudioService extends ChangeNotifier {
  // Players audioplayers pour fichiers .wav
  final ap.AudioPlayer _bgPlayer    = ap.AudioPlayer();
  final ap.AudioPlayer _sfxPlayer   = ap.AudioPlayer();
  final ap.AudioPlayer _sfxPlayer2  = ap.AudioPlayer(); // pour sons simultanés
  // Player just_audio pour nouveaux fichiers MP3
  final AudioPlayer _justSfxPlayer = AudioPlayer();
  
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
  static const Map<SoundEffect, String> _sfxPaths = {
    SoundEffect.correct:       'sounds/correct.wav',
    SoundEffect.wrong:         'sounds/wrong.wav',
    SoundEffect.combo:         'sounds/combo.wav',
    SoundEffect.levelUp:       'sounds/level_up.wav',
    SoundEffect.starEarned:     'sounds/star.wav',
    SoundEffect.buttonTap:     'sounds/tap.wav',
    SoundEffect.challengeDone: 'sounds/celebrate.wav',
    SoundEffect.unlock:         'sounds/unlock.wav',
    SoundEffect.countdown:     'sounds/countdown.wav',
    SoundEffect.perfect:        'sounds/perfect.wav',
    SoundEffect.success:        'sounds/celebrate.wav',
    SoundEffect.birdChirp:     'sounds/mascot_hello_bubulle.wav',
    SoundEffect.last5sec:       'sounds/countdown.wav',
    // Nouveaux fichiers audio (à ajouter)
    SoundEffect.confetti:       'audio/sounds/confetti.mp3',
    SoundEffect.levelComplete:   'audio/sounds/level_complete.mp3',
    SoundEffect.applause:        'audio/sounds/applause.mp3',
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

  // Mapping musique de fond pour just_audio (nouveaux fichiers)
  static const Map<BackgroundMusic, String> _newMusicPaths = {
    BackgroundMusic.math:      'audio/music/math_music.mp3',
    BackgroundMusic.french:    'audio/music/french_music.mp3',
    BackgroundMusic.science:    'audio/music/science_music.mp3',
    BackgroundMusic.home:      'audio/music/default_music.mp3',
  };

  AudioService() {
    _bgPlayer.setReleaseMode(ap.ReleaseMode.loop);
    _loadPrefs();
    _initJustAudio();
  }

  /// Initialise just_audio pour les nouveaux sons
  Future<void> _initJustAudio() async {
    try {
      await _justSfxPlayer.setVolume(_sfxVolume);
      debugPrint('AudioService: just_audio initialisé');
    } catch (e) {
      debugPrint('AudioService: Erreur just_audio - $e');
    }
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
    if (_currentMusic == music) return;
    _currentMusic = music;
    await _bgPlayer.stop();
    await _bgPlayer.setVolume(_musicVolume);
    await _bgPlayer.play(ap.AssetSource(_musicPaths[music]!));
  }

  /// Démarre la musique avec just_audio (pour nouveaux fichiers MP3)
  Future<void> playMusicJustAudio(BackgroundMusic music) async {
    if (!_musicEnabled) return;
    if (_currentMusic == music) return;
    
    final path = _newMusicPaths[music];
    if (path == null) {
      // Fallback vers audioplayers
      await playMusic(music);
      return;
    }
    
    try {
      _currentMusic = music;
      await _bgPlayer.stop();
      await _bgPlayer.setVolume(_musicVolume);
      await _bgPlayer.setReleaseMode(ap.ReleaseMode.loop);
      await _bgPlayer.play(ap.AssetSource(path));
    } catch (e) {
      debugPrint('AudioService: Erreur playMusicJustAudio - $e');
      // Fallback
      await playMusic(music);
    }
  }

  Future<void> stopMusic() async {
    _currentMusic = null;
    await _bgPlayer.stop();
  }

  Future<void> pauseMusic() async => _bgPlayer.pause();
  Future<void> resumeMusic() async {
    if (_musicEnabled) await _bgPlayer.resume();
  }

  // ── Effets sonores (audioplayers) ────────────────────────────────────────────
  Future<void> playSound(SoundEffect fx) async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.setVolume(_sfxVolume);
      await _sfxPlayer.play(ap.AssetSource(_sfxPaths[fx]!));
    } catch (e) {
      // Fichier absent - silencieux
      debugPrint('AudioService: Fichier absent ${_sfxPaths[fx]}');
    }
  }

  /// Son simultané (ex: correct + confetti en même temps)
  Future<void> playSoundOverlap(SoundEffect fx) async {
    if (!_soundEnabled) return;
    await _sfxPlayer2.setVolume(_sfxVolume);
    await _sfxPlayer2.play(ap.AssetSource(_sfxPaths[fx]!));
  }

  // ── Nouveaux sons avec just_audio ────────────────────────────────────────────
  
  /// Son de succès - "ding" court
  Future<void> playSuccess() async {
    if (!_soundEnabled) return;
    await _playJustAudio('audio/sounds/success.mp3');
  }

  /// Son d'erreur - "buzz" court
  Future<void> playError() async {
    if (!_soundEnabled) return;
    await _playJustAudio('audio/sounds/error.mp3');
  }

  /// Son confettis
  Future<void> playConfetti() async {
    if (!_soundEnabled) return;
    await _playJustAudio('audio/sounds/confetti.mp3');
  }

  /// Son niveau terminé
  Future<void> playLevelComplete() async {
    if (!_soundEnabled) return;
    await _playJustAudio('audio/sounds/level_complete.mp3');
  }

  /// Son applaudissements
  Future<void> playApplause() async {
    if (!_soundEnabled) return;
    await _playJustAudio('audio/sounds/applause.mp3');
  }

  /// Joue un son avec just_audio (fallback silencieux si absent)
  Future<void> _playJustAudio(String assetPath) async {
    try {
      await _justSfxPlayer.setVolume(_sfxVolume);
      await _justSfxPlayer.setAsset(assetPath);
      await _justSfxPlayer.seek(Duration.zero);
      await _justSfxPlayer.play();
    } catch (e) {
      // Fallback silencieux si fichier absent
      debugPrint('AudioService: Fichier absent $assetPath');
    }
  }

  // ── Raccourcis pratiques ──────────────────────────────────────
  void onCorrectAnswer({bool isCombo = false}) {
    if (isCombo) {
      playSound(SoundEffect.combo);
    } else {
      playSuccess(); // Nouveau son avec just_audio
    }
  }

  void onWrongAnswer() => playError(); // Nouveau son avec just_audio
  void onButtonTap()   => playSound(SoundEffect.buttonTap);
  void onLevelUp()     => playSound(SoundEffect.levelUp);
  void onStarEarned()   => playSound(SoundEffect.starEarned);
  
  void onPerfect() { 
    playLevelComplete(); 
    playApplause();
  }
  
  void onUnlock()          => playSound(SoundEffect.unlock);
  void onChallengeDone()   => playSound(SoundEffect.challengeDone);
  void onCountdown()        => playSound(SoundEffect.countdown);
  void onBillyGreeting()    => playSound(SoundEffect.birdChirp);
  void onLast5Seconds()     => playSound(SoundEffect.last5sec);
  
  /// Appelée après 3 bonnes réponses consécutives (streak)
  void onStreak() => playConfetti();

  // Jouer un son SFX personnalisé
  Future<void> playSfx(String assetPath) async {
    if (!_soundEnabled) return;
    await _sfxPlayer.setVolume(_sfxVolume);
    await _sfxPlayer.play(ap.AssetSource(assetPath));
  }

  // Jouer musique de fond (fallback: music_home.wav si nouveau fichier absent)
  Future<void> playBackgroundMusic() async {
    if (!_musicEnabled) return;
    await _bgPlayer.stop();
    await _bgPlayer.setVolume(_musicVolume);
    await _bgPlayer.play(ap.AssetSource('sounds/music/music_home.wav'));
  }

  /// Démarre la musique de fond par catégorie
  Future<void> startMusic(String category) async {
    switch (category) {
      case 'math':
        await playMusicJustAudio(BackgroundMusic.math);
        break;
      case 'french':
        await playMusicJustAudio(BackgroundMusic.french);
        break;
      case 'science':
        await playMusicJustAudio(BackgroundMusic.science);
        break;
      default:
        await playMusic(BackgroundMusic.home);
    }
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
    await _justSfxPlayer.setVolume(v);
    final p = await SharedPreferences.getInstance();
    await p.setDouble('sfx_vol', v);
    notifyListeners();
  }

  @override
  void dispose() {
    _bgPlayer.dispose();
    _sfxPlayer.dispose();
    _sfxPlayer2.dispose();
    _justSfxPlayer.dispose();
    super.dispose();
  }
}
