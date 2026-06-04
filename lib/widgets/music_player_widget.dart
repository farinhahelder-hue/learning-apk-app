import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../utils/app_theme.dart';

/// Mini lecteur flottant affiché en bas de l'écran d'accueil
class MiniMusicPlayer extends StatelessWidget {
  const MiniMusicPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioService>();
    return GestureDetector(
      onTap: () => audio.musicEnabled ? audio.pauseMusic() : audio.resumeMusic(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: audio.musicEnabled
              ? AppTheme.primaryPurple.withOpacity(0.12)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: audio.musicEnabled ? AppTheme.primaryPurple.withOpacity(0.3) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              audio.musicEnabled ? Icons.music_note_rounded : Icons.music_off_rounded,
              color: audio.musicEnabled ? AppTheme.primaryPurple : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                audio.musicEnabled ? '🎵 Musique activée' : '🔇 Musique désactivée',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: audio.musicEnabled ? AppTheme.primaryPurple : Colors.grey,
                ),
              ),
            ),
            // Bouton toggle rapide
            GestureDetector(
              onTap: audio.toggleMusic,
              child: Icon(
                audio.musicEnabled ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                color: audio.musicEnabled ? AppTheme.primaryPurple : Colors.grey,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icône flottante de contrôle audio (pour les écrans de jeu)
class AudioControlFAB extends StatelessWidget {
  const AudioControlFAB({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioService>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Toggle musique
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          elevation: 4,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: audio.toggleMusic,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                audio.musicEnabled ? Icons.music_note_rounded : Icons.music_off_rounded,
                color: audio.musicEnabled ? AppTheme.primaryPurple : Colors.grey,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Toggle sons
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          elevation: 4,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: audio.toggleSound,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                audio.soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                color: audio.soundEnabled ? AppTheme.primaryBlue : Colors.grey,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
