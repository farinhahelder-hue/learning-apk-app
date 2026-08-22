import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/accessibility_settings_service.dart';
import '../../services/audio_service.dart';
import '../../services/tts_service.dart';
import '../../utils/app_theme.dart';

/// 🎛️ « Mes réglages » — confort sensoriel.
/// Accessible depuis l'espace parents (protégé par code).
/// Chaque réglage est indépendant : on peut garder les animations en
/// coupant la musique, ou l'inverse.
class SensorySettingsScreen extends StatelessWidget {
  const SensorySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final access = context.watch<AccessibilitySettingsService>();
    final audio = context.watch<AudioService>();

    final allSilent = !audio.musicEnabled && !audio.soundEnabled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎛️ Mes réglages'),
        backgroundColor: AppTheme.primaryPurple.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Bouton d'urgence : tout couper ──
          GestureDetector(
            onTap: () {
              if (allSilent) {
                audio.toggleMusic();
                audio.toggleSound();
              } else {
                if (audio.musicEnabled) audio.toggleMusic();
                if (audio.soundEnabled) audio.toggleSound();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: allSilent ? const Color(0xFF4CAF50) : Colors.red.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: allSilent ? const Color(0xFF4CAF50) : Colors.red.shade300,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Text(allSilent ? '🔕' : '🔊', style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      allSilent ? 'Tout est silencieux — toucher pour réactiver' : 'Couper TOUS les sons',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: allSilent ? Colors.white : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Profils sensoriels ──
          const _SectionTitle('Profil sensoriel'),
          const Text(
            'Un réglage rapide pour toute l\'app. Tu peux ensuite ajuster chaque option une par une.',
            style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
          ),
          const SizedBox(height: 12),
          ...SensoryProfile.values.map((p) {
            final selected = access.profile == p;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => access.applyProfile(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primaryPurple.withOpacity(0.12) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected ? AppTheme.primaryPurple : Colors.grey.shade300,
                      width: selected ? 2.5 : 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(p.emoji, style: const TextStyle(fontSize: 30)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: selected ? AppTheme.primaryPurple : AppTheme.textDark,
                                )),
                            const SizedBox(height: 3),
                            Text(p.description,
                                style: const TextStyle(fontSize: 11, color: AppTheme.textGrey, height: 1.35)),
                          ],
                        ),
                      ),
                      if (selected)
                        const Icon(Icons.check_circle_rounded, color: AppTheme.primaryPurple),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // ── Réglages indépendants ──
          const _SectionTitle('Réglages détaillés'),
          const SizedBox(height: 8),

          _SwitchTile(
            emoji: '🌙',
            title: 'Mode calme',
            subtitle: 'Moins de confettis, de vibrations et de couleurs vives',
            value: access.calmModeEnabled,
            onChanged: (_) => access.toggleCalmMode(),
          ),
          _SwitchTile(
            emoji: '✨',
            title: 'Animations',
            subtitle: 'Personnages et transitions animés',
            value: access.animationsEnabled,
            onChanged: (_) => access.toggleAnimations(),
          ),
          _SwitchTile(
            emoji: '🗣️',
            title: 'Lire les consignes à voix haute',
            subtitle: 'La question est lue automatiquement à chaque exercice',
            value: access.autoReadEnabled,
            onChanged: (_) => access.toggleAutoRead(),
          ),
          _SwitchTile(
            emoji: '⏱️',
            title: 'Minuteur de réflexion',
            subtitle: 'Désactivé par défaut — aucune pression de temps',
            value: access.showThinkingTimer,
            onChanged: (_) => access.toggleThinkingTimer(),
          ),

          const SizedBox(height: 20),

          // ── Vitesse de la voix ──
          const _SectionTitle('Vitesse de la voix'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('🐢  Très lente', style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                    Text(access.voiceRateLabel,
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryPurple)),
                    const Text('Normale  🐇', style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                  ],
                ),
                Slider(
                  value: access.voiceRate,
                  min: 0.25,
                  max: 0.60,
                  divisions: 7,
                  activeColor: AppTheme.primaryPurple,
                  onChanged: (v) => access.setVoiceRate(v),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    final tts = context.read<TtsService>();
                    tts.setSpeechRate(access.voiceRate);
                    tts.speak('Bonjour Emilie ! Voici la vitesse de ma voix.');
                  },
                  icon: const Icon(Icons.volume_up_rounded, size: 18),
                  label: const Text('Écouter un exemple'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Sons et musique ──
          const _SectionTitle('Sons et musique'),
          const SizedBox(height: 8),
          _SwitchTile(
            emoji: '🎶',
            title: 'Musique de fond',
            subtitle: 'Mélodie douce pendant les activités',
            value: audio.musicEnabled,
            onChanged: (_) => audio.toggleMusic(),
          ),
          if (audio.musicEnabled)
            _VolumeRow(
              label: 'Volume musique',
              value: audio.musicVolume,
              onChanged: audio.setMusicVolume,
            ),
          _SwitchTile(
            emoji: '🔔',
            title: 'Effets sonores',
            subtitle: 'Petits sons de réussite',
            value: audio.soundEnabled,
            onChanged: (_) => audio.toggleSound(),
          ),
          if (audio.soundEnabled)
            _VolumeRow(
              label: 'Volume effets',
              value: audio.sfxVolume,
              onChanged: audio.setSfxVolume,
            ),

          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryYellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              '💡 Ces réglages sont là pour qu\'Emilie contrôle ce qu\'elle entend et voit. '
              'Le meilleur réglage est celui qu\'elle choisit — testez ensemble et ajustez.',
              style: TextStyle(fontSize: 12, height: 1.5, color: AppTheme.textDark),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textDark));
}

class _SwitchTile extends StatelessWidget {
  final String emoji, title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                Text(subtitle,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textGrey, height: 1.3)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: AppTheme.primaryPurple),
        ],
      ),
    );
  }
}

class _VolumeRow extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _VolumeRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
      child: Row(
        children: [
          Icon(Icons.volume_down_rounded, size: 18, color: Colors.grey.shade400),
          Expanded(
            child: Slider(
              value: value,
              min: 0, max: 1,
              activeColor: AppTheme.primaryPurple,
              onChanged: onChanged,
            ),
          ),
          const Icon(Icons.volume_up_rounded, size: 18, color: AppTheme.primaryPurple),
        ],
      ),
    );
  }
}
