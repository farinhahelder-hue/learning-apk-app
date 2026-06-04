import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../utils/app_theme.dart';

class AudioSettingsScreen extends StatelessWidget {
  const AudioSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎵 Sons & Musique'),
        backgroundColor: AppTheme.primaryPurple.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte Musique
            _SectionCard(
              icon: '🎶',
              title: 'Musique de fond',
              subtitle: 'Mélodie douce pendant les activités',
              enabled: audio.musicEnabled,
              onToggle: audio.toggleMusic,
              volume: audio.musicVolume,
              onVolumeChanged: audio.setMusicVolume,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: 20),
            // Carte Effets sonores
            _SectionCard(
              icon: '🔊',
              title: 'Effets sonores',
              subtitle: 'Sons pour les bonnes/mauvaises réponses',
              enabled: audio.soundEnabled,
              onToggle: audio.toggleSound,
              volume: audio.sfxVolume,
              onVolumeChanged: audio.setSfxVolume,
              color: AppTheme.primaryPink,
            ),
            const SizedBox(height: 28),
            const Text('🎵 Musiques disponibles',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ..._musicList.map((m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text(m['emoji']!, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m['name']!, style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(m['desc']!, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            )),
            const SizedBox(height: 24),
            const Text('🔊 Effets sonores',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _sfxList.map((s) => _SfxChip(
                emoji: s['emoji']!,
                label: s['name']!,
                onTap: () => audio.playSound(
                  SoundEffect.values.firstWhere((e) => e.name == s['id'])
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  static const _musicList = [
    {'emoji': '🏠', 'name': 'Accueil', 'desc': 'Douce et joyeuse – écran principal'},
    {'emoji': '🔢', 'name': 'Maths', 'desc': 'Rythmée et dynamique – exercices de calcul'},
    {'emoji': '📚', 'name': 'Français', 'desc': 'Calme et mélodique – lecture & orthographe'},
    {'emoji': '🔬', 'name': 'Sciences', 'desc': 'Curieuse et aventureuse – découvertes'},
    {'emoji': '🏆', 'name': 'Résultats', 'desc': 'Festive – quand tu gagnes des étoiles'},
    {'emoji': '⚡', 'name': 'Défi du Jour', 'desc': 'Épique – pour les défis quotidiens'},
  ];

  static const _sfxList = [
    {'emoji': '✅', 'name': 'Bonne réponse', 'id': 'correct'},
    {'emoji': '❌', 'name': 'Mauvaise réponse', 'id': 'wrong'},
    {'emoji': '🔥', 'name': 'Combo', 'id': 'combo'},
    {'emoji': '⭐', 'name': 'Étoile gagnée', 'id': 'starEarned'},
    {'emoji': '🚀', 'name': 'Niveau supérieur', 'id': 'levelUp'},
    {'emoji': '🎉', 'name': 'Score parfait', 'id': 'perfect'},
    {'emoji': '🔓', 'name': 'Débloqué', 'id': 'unlock'},
    {'emoji': '⏱️', 'name': 'Compte à rebours', 'id': 'countdown'},
  ];
}

class _SectionCard extends StatelessWidget {
  final String icon, title, subtitle;
  final bool enabled;
  final VoidCallback onToggle;
  final double volume;
  final ValueChanged<double> onVolumeChanged;
  final Color color;

  const _SectionCard({
    required this.icon, required this.title, required this.subtitle,
    required this.enabled, required this.onToggle,
    required this.volume, required this.onVolumeChanged, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 12)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                ],
              )),
              Switch(value: enabled, onChanged: (_) => onToggle(), activeColor: color),
            ],
          ),
          if (enabled) ...
          [
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.volume_down, color: Colors.grey.shade400, size: 20),
                Expanded(
                  child: Slider(
                    value: volume, min: 0, max: 1,
                    activeColor: color,
                    onChanged: onVolumeChanged,
                  ),
                ),
                Icon(Icons.volume_up, color: color, size: 20),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SfxChip extends StatelessWidget {
  final String emoji, label;
  final VoidCallback onTap;
  const _SfxChip({required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Icon(Icons.play_circle_outline, size: 16, color: AppTheme.primaryBlue),
          ],
        ),
      ),
    );
  }
}
