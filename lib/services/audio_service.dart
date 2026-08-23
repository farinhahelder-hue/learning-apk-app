import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';
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
  birdChirp,    // chant d'oiseau (pour Billy)
  last5sec,     // 5 dernières secondes
}

/// Catégories de musique de fond
enum BackgroundMusic {
  home,         // écran d'accueil - douce et joyeuse
  math,         // maths - rythmée et dynamique
  french,       // français - calme et mélodique
  science,      // sciences - curieuse et aventureuse
}

class AudioService extends ChangeNotifier {
  final ap.AudioPlayer _bgPlayer   = ap.AudioPlayer();
  final ap.AudioPlayer _sfxPlayer  = ap.AudioPlayer();
  final ap.AudioPlayer _sfxPlayer2 = ap.AudioPlayer(); // pour sons simultanés

  bool _musicEnabled  = true;
  bool _soundEnabled  = true;
  // Volumes par défaut volontairement bas. Les anciens (0.85 pour les
  // effets) rendaient l'application fatigante ; on peut toujours les
  // remonter dans « Sons et musique ».
  double _musicVolume = 0.20;
  double _sfxVolume   = 0.55;
  BackgroundMusic? _currentMusic;

  /// Atténuation décidée par les réglages sensoriels.
  ///
  /// Le profil « Doux » et le mode calme ne touchaient jusqu'ici qu'aux
  /// animations : une enfant réglée sur « Doux » recevait quand même les
  /// effets à plein volume. C'est corrigé ici — le réglage porte enfin
  /// sur ce qu'on entend.
  double _sensoryGain = 1.0;

  /// Appelé quand les réglages sensoriels changent.
  /// [gain] : 1.0 = aucune atténuation, 0.0 = silence.
  void applySensoryGain(double gain) {
    final g = gain.clamp(0.0, 1.0);
    if (g == _sensoryGain) return;
    _sensoryGain = g;
    _bgPlayer.setVolume(_musicVolume * _sensoryGain);
    notifyListeners();
  }

  /// Volume réellement envoyé aux effets.
  double get _effectiveSfx => _sfxVolume * _sensoryGain;

  bool get musicEnabled  => _musicEnabled;
  bool get soundEnabled  => _soundEnabled;
  double get musicVolume => _musicVolume;
  double get sfxVolume   => _sfxVolume;

  // Mapping effets sonores → fichier réel assets/sounds/*.wav
  static const Map<SoundEffect, String> _sfxPaths = {
    SoundEffect.correct:       'sounds/correct.wav',
    SoundEffect.wrong:         'sounds/wrong.wav',
    SoundEffect.combo:         'sounds/combo.wav',
    SoundEffect.levelUp:       'sounds/level_up.wav',
    SoundEffect.starEarned:    'sounds/star.wav',
    SoundEffect.buttonTap:     'sounds/tap.wav',
    SoundEffect.challengeDone: 'sounds/celebrate.wav',
    SoundEffect.unlock:        'sounds/unlock.wav',
    SoundEffect.countdown:     'sounds/countdown.wav',
    SoundEffect.perfect:       'sounds/perfect.wav',
    SoundEffect.birdChirp:     'sounds/mascot_hello_bubulle.wav',
    SoundEffect.last5sec:      'sounds/countdown.wav',
  };

  // Mapping musiques → fichier réel assets/sounds/music/*.wav
  static const Map<BackgroundMusic, String> _musicPaths = {
    BackgroundMusic.home:    'sounds/music/music_home.wav',
    BackgroundMusic.math:    'sounds/music/music_math.wav',
    BackgroundMusic.french:  'sounds/music/music_french.wav',
    BackgroundMusic.science: 'sounds/music/music_science.wav',
  };

  AudioService() {
    _bgPlayer.setReleaseMode(ap.ReleaseMode.loop);
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    _musicEnabled  = p.getBool('music_on')    ?? true;
    _soundEnabled  = p.getBool('sound_on')    ?? true;
    _musicVolume   = p.getDouble('music_vol') ?? 0.20;
    _sfxVolume     = p.getDouble('sfx_vol')   ?? 0.55;
    notifyListeners();
  }

  // ── Musique de fond ──────────────────────────────────────────
  Future<void> playMusic(BackgroundMusic music) async {
    if (!_musicEnabled) return;
    if (_currentMusic == music) return;
    _currentMusic = music;
    try {
      await _bgPlayer.stop();
      await _bgPlayer.setVolume(_musicVolume * _sensoryGain);
      await _bgPlayer.play(ap.AssetSource(_musicPaths[music]!));
    } catch (e) {
      debugPrint('AudioService: musique indisponible ${_musicPaths[music]} - $e');
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

  // ── Effets sonores ────────────────────────────────────────────

  /// Dernier déclenchement de chaque effet, pour ne pas les empiler.
  final Map<SoundEffect, DateTime> _lastPlayed = {};

  /// Délai minimal entre deux fois le même effet. Le clic revient très
  /// vite quand on appuie plusieurs fois de suite ; sans ce garde-fou,
  /// les sons se superposent et ça devient un grésillement.
  static const Map<SoundEffect, int> _minGapMs = {
    SoundEffect.buttonTap: 70,
    SoundEffect.correct: 150,
    SoundEffect.wrong: 150,
    SoundEffect.countdown: 250,
  };

  bool _tooSoon(SoundEffect fx) {
    final gap = _minGapMs[fx];
    if (gap == null) return false;
    final last = _lastPlayed[fx];
    final now = DateTime.now();
    if (last != null && now.difference(last).inMilliseconds < gap) return true;
    _lastPlayed[fx] = now;
    return false;
  }

  Future<void> playSound(SoundEffect fx) async {
    if (!_soundEnabled) return;
    if (_tooSoon(fx)) return;
    try {
      await _sfxPlayer.setVolume(_effectiveSfx);
      await _sfxPlayer.play(ap.AssetSource(_sfxPaths[fx]!));
    } catch (e) {
      // Fichier absent - silencieux, ne bloque jamais l'enfant
      debugPrint('AudioService: Fichier absent ${_sfxPaths[fx]}');
    }
  }

  /// Son simultané (ex: correct + combo en même temps)
  Future<void> playSoundOverlap(SoundEffect fx) async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer2.setVolume(_effectiveSfx);
      await _sfxPlayer2.play(ap.AssetSource(_sfxPaths[fx]!));
    } catch (e) {
      debugPrint('AudioService: Fichier absent ${_sfxPaths[fx]}');
    }
  }

  // Jouer un son SFX personnalisé (chemin relatif à assets/)
  Future<void> playSfx(String assetPath) async {
    if (!_soundEnabled) return;
    try {
      await _sfxPlayer.setVolume(_effectiveSfx);
      await _sfxPlayer.play(ap.AssetSource(assetPath));
    } catch (e) {
      debugPrint('AudioService: Fichier absent $assetPath');
    }
  }

  /// Démarre la musique de fond par catégorie
  Future<void> startMusic(String category) async {
    switch (category) {
      case 'math':
        await playMusic(BackgroundMusic.math);
        break;
      case 'french':
        await playMusic(BackgroundMusic.french);
        break;
      case 'science':
        await playMusic(BackgroundMusic.science);
        break;
      default:
        await playMusic(BackgroundMusic.home);
    }
  }

  // ── Raccourcis pratiques ──────────────────────────────────────
  void onCorrectAnswer({bool isCombo = false}) {
    playSound(isCombo ? SoundEffect.combo : SoundEffect.correct);
  }

  void onWrongAnswer()  => playSound(SoundEffect.wrong);
  void onButtonTap()    => playSound(SoundEffect.buttonTap);
  void onLevelUp()      => playSound(SoundEffect.levelUp);
  void onStarEarned()   => playSound(SoundEffect.starEarned);

  /// Score parfait : le son le plus festif disponible
  void onPerfect() => playSound(SoundEffect.perfect);

  void onUnlock()        => playSound(SoundEffect.unlock);
  void onChallengeDone()  => playSound(SoundEffect.challengeDone);
  void onCountdown()     => playSound(SoundEffect.countdown);
  void onBillyGreeting() => playSound(SoundEffect.birdChirp);
  void onLast5Seconds()  => playSound(SoundEffect.last5sec);

  /// Appelée après 3 bonnes réponses consécutives (streak)
  void onStreak() => playSound(SoundEffect.combo);

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
    await _bgPlayer.setVolume(v * _sensoryGain);
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
