import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;

  bool get soundEnabled => _soundEnabled;
  void toggleSound() => _soundEnabled = !_soundEnabled;

  Future<void> playSuccess() async {
    if (!_soundEnabled) return;
    try { await _player.play(AssetSource('sounds/success.mp3')); } catch (_) {}
  }

  Future<void> playError() async {
    if (!_soundEnabled) return;
    try { await _player.play(AssetSource('sounds/error.mp3')); } catch (_) {}
  }

  Future<void> playClick() async {
    if (!_soundEnabled) return;
    try { await _player.play(AssetSource('sounds/click.mp3')); } catch (_) {}
  }

  Future<void> playLevelUp() async {
    if (!_soundEnabled) return;
    try { await _player.play(AssetSource('sounds/level_up.mp3')); } catch (_) {}
  }

  void dispose() => _player.dispose();
}
