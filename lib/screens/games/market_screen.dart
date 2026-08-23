import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/market_missions.dart';
import '../../services/accessibility_settings_service.dart';
import '../../services/audio_service.dart';
import '../../services/game_service.dart';
import '../../services/garden_service.dart';
import '../../services/progress_service.dart';
import '../../services/stats_service.dart';
import '../../services/tts_service.dart';
import '../../utils/adaptive_difficulty.dart';
import '../../utils/app_theme.dart';
import '../../utils/haptics.dart';
import '../../widgets/confetti_overlay.dart';
import '../sensory/sensory_room_screen.dart';

/// 🧺 Marché des nombres — composer une quantité avec des jetons.
///
/// Même déroulé que les barres de nombres : un objectif, une manipulation,
/// des aides à la demande, une récompense, puis un choix laissé à Emilie.
/// Aucun chronomètre, aucune vie, rien qui se perde.
class MarketScreen extends StatefulWidget {
  /// Si fourni, ne propose que les missions de cette compétence
  /// (utilisé par le mode histoire pour ouvrir une étape précise).
  final String? competence;
  const MarketScreen({super.key, this.competence});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

enum _Phase { objective, playing, success }

class _MarketScreenState extends State<MarketScreen> {
  late final String _level;
  late final List<MarketMission> _missions;

  int _index = 0;
  _Phase _phase = _Phase.objective;

  /// Les jetons posés, dans l'ordre où Emilie les a choisis.
  final List<int> _basket = [];
  int _hintsShown = 0;
  String? _note;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  MarketMission get _mission => _missions[_index];
  int get _total => _basket.fold(0, (s, v) => s + v);
  Color get _levelColor =>
      _level == 'CE2' ? AppTheme.primaryPurple : AppTheme.primaryBlue;

  /// Restreint à la compétence demandée ; si aucune ne correspond,
  /// on garde tout le niveau plutôt que d'afficher un écran vide.
  List<MarketMission> _filtered(List<MarketMission> all) {
    final c = widget.competence;
    if (c == null) return List.of(all);
    final sub = all.where((m) => m.competence == c).toList();
    return sub.isEmpty ? List.of(all) : sub;
  }

  @override
  void initState() {
    super.initState();
    _level = context.read<GameService>().gradeLevel;
    _missions = AdaptiveDifficulty.ordered(
      _filtered(MarketData.forLevel(_level)),
      stats: context.read<StatsService>(),
      level: _level,
      competenceOf: (m) => m.competence,
      missionTypeOf: (m) => m.missionType,
    );
  }

  // ── Voix ─────────────────────────────────────────────────
  void _speak(String text) {
    final access = context.read<AccessibilitySettingsService>();
    final tts = context.read<TtsService>();
    tts.setSpeechRate(access.voiceRate);
    tts.speak(text);
  }

  String get _spokenObjective =>
      '${_mission.objective} : ${_mission.unit.format(_mission.target)}';

  void _maybeAutoRead() {
    if (context.read<AccessibilitySettingsService>().autoReadEnabled) {
      _speak(_spokenObjective);
    }
  }

  // ── Déroulé ──────────────────────────────────────────────
  void _startMission() {
    context.read<GardenService>().rewardMissionStarted();
    context.read<StatsService>().recordStarted(_level, _mission.competence);
    setState(() {
      _phase = _Phase.playing;
      _basket.clear();
      _hintsShown = 0;
      _note = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoRead());
  }

  void _addToken(int value) {
    AppHaptics.selection();
    context.read<AudioService>().onButtonTap();
    setState(() {
      _basket.add(value);
      _note = null;
    });
  }

  void _removeAt(int i) {
    AppHaptics.selection();
    setState(() {
      _basket.removeAt(i);
      _note = null;
    });
  }

  void _emptyBasket() {
    AppHaptics.light();
    setState(() {
      _basket.clear();
      _note = null;
    });
  }

  void _showNextHint() {
    if (_hintsShown >= _mission.hints.length) return;
    setState(() => _hintsShown++);
    _speak(_mission.hints[_hintsShown - 1]);
  }

  /// Une piste utile plutôt qu'un simple « faux ».
  String _gentleGuidance() {
    final u = _mission.unit;
    final diff = _mission.target - _total;
    if (diff > 0) {
      return 'Il manque encore ${u.format(diff)}. Ajoute un jeton.';
    }
    return 'Il y a ${u.format(-diff)} de trop. Retire un jeton en le touchant.';
  }

  void _validate() {
    if (_total == _mission.target) {
      _onSuccess();
    } else {
      AppHaptics.light();
      setState(() => _note = _gentleGuidance());
    }
  }

  void _onSuccess() {
    final access = context.read<AccessibilitySettingsService>();
    final audio = context.read<AudioService>();

    // Récompense pour avoir terminé, même avec des aides.
    context.read<GardenService>().rewardActivityCompleted();
    context.read<ProgressService>().addPoints('math', 15);
    context.read<StatsService>()
        .recordCompleted(_level, _mission.competence, hintsUsed: _hintsShown);

    audio.onCorrectAnswer();
    AppHaptics.medium();

    if (!access.calmModeEnabled) {
      _confettiKey.currentState?.burst();
    }
    if (access.profile == SensoryProfile.dynamique) {
      _speak('Bravo Emilie, le compte est bon !');
    }

    setState(() => _phase = _Phase.success);
  }

  void _nextMission() {
    setState(() {
      _index = (_index + 1) % _missions.length;
      _phase = _Phase.objective;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧺 Marché des nombres'),
        backgroundColor: _levelColor.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: _levelColor,
                    borderRadius: BorderRadius.circular(12)),
                child: Text(_level,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          switch (_phase) {
            _Phase.objective => _buildObjective(),
            _Phase.playing => _buildPlaying(),
            _Phase.success => _buildSuccess(),
          },
          ConfettiOverlay(key: _confettiKey),
        ],
      ),
    );
  }

  // ── 1. Objectif ──────────────────────────────────────────
  Widget _buildObjective() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: _levelColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(_mission.missionType,
                  style: TextStyle(
                      color: _levelColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13)),
            ),
            const SizedBox(height: 24),
            Text(_mission.itemEmoji, style: const TextStyle(fontSize: 76)),
            const SizedBox(height: 20),
            Text(_mission.objective,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w800, height: 1.4)),
            const SizedBox(height: 6),
            Text(_mission.unit.format(_mission.target),
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: _levelColor)),
            const SizedBox(height: 10),
            Text(_mission.unit.stallName,
                style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: () => _speak(_spokenObjective),
              icon: const Icon(Icons.volume_up_rounded),
              label: const Text('Écouter'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(200, 50),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _startMission,
              style: ElevatedButton.styleFrom(
                backgroundColor: _levelColor,
                minimumSize: const Size(200, 56),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text('Commencer',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. Manipulation ──────────────────────────────────────
  Widget _buildPlaying() {
    final u = _mission.unit;
    final exact = _total == _mission.target;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Consigne + réécoute
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _levelColor.withOpacity(0.3), width: 2),
            ),
            child: Row(
              children: [
                Text(_mission.itemEmoji, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_mission.objective,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      Text(u.format(_mission.target),
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: _levelColor)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _speak(_spokenObjective),
                  icon: const Icon(Icons.volume_up_rounded),
                  tooltip: 'Réécouter',
                  color: _levelColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Le panier : ce qui a été posé
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 110),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: exact
                  ? const Color(0xFFE8F5E9)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: exact ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Mon panier',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textGrey)),
                    Text(u.format(_total),
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: exact
                                ? const Color(0xFF2E7D32)
                                : AppTheme.textDark)),
                  ],
                ),
                const SizedBox(height: 10),
                if (_basket.isEmpty)
                  const Text(
                    'Touche un jeton en bas pour le poser ici.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textGrey),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var i = 0; i < _basket.length; i++)
                        GestureDetector(
                          onTap: () => _removeAt(i),
                          child: _TokenChip(
                            label: u.format(_basket[i]),
                            color: _levelColor,
                            filled: true,
                          ),
                        ),
                    ],
                  ),
                if (_basket.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Touche un jeton du panier pour l\'enlever.',
                      style: TextStyle(fontSize: 10, color: AppTheme.textGrey)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // L'étal : les jetons disponibles
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${u.emoji}  ${u.stallName}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textGrey)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in _mission.tokens)
                      GestureDetector(
                        onTap: () => _addToken(t),
                        child: _TokenChip(
                          label: u.format(t),
                          color: _levelColor,
                          filled: false,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Piste après un essai qui ne tombe pas juste
          if (_note != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(_note!,
                  style: const TextStyle(fontSize: 13, height: 1.5)),
            ),
          ],

          // Aides déjà demandées
          if (_hintsShown > 0) ...[
            const SizedBox(height: 12),
            ...List.generate(
              _hintsShown,
              (i) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('💡 ${_mission.hints[i]}',
                    style: const TextStyle(fontSize: 13, height: 1.4)),
              ),
            ),
          ],

          const SizedBox(height: 14),
          Row(
            children: [
              if (_hintsShown < _mission.hints.length)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showNextHint,
                    icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
                    label: Text(_hintsShown == 0 ? 'Un indice' : 'Encore un indice'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              if (_hintsShown < _mission.hints.length) const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _validate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _levelColor,
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Vérifier',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _basket.isEmpty ? null : _emptyBasket,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Vider le panier et recommencer'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── 3. Réussite, puis choix ──────────────────────────────
  Widget _buildSuccess() {
    final calm = context.watch<AccessibilitySettingsService>().calmModeEnabled;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(calm ? '⭐' : '🌟', style: const TextStyle(fontSize: 76)),
            const SizedBox(height: 16),
            const Text('Le compte est bon.',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              _hintsShown > 0
                  ? 'Tu as utilisé une aide et tu as continué. C\'est très bien.'
                  : 'Tu as trouvé toute seule. Tu peux être fière de ton effort.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textGrey, height: 1.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('🌰 +1 graine    💧 +1 goutte',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            ),
            const SizedBox(height: 28),

            // Choix laissé à Emilie
            _ChoiceButton(
              emoji: '▶️',
              label: 'Une autre mission',
              color: _levelColor,
              onTap: _nextMission,
            ),
            const SizedBox(height: 10),
            _ChoiceButton(
              emoji: '🌱',
              label: 'Aller au jardin',
              color: AppTheme.primaryGreen,
              onTap: () => Navigator.pushNamed(context, '/garden'),
            ),
            const SizedBox(height: 10),
            _ChoiceButton(
              emoji: '🫧',
              label: 'Faire une pause calme',
              color: AppTheme.primaryBlue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SensoryRoomScreen()),
              ),
            ),
            const SizedBox(height: 10),
            _ChoiceButton(
              emoji: '🏠',
              label: 'Revenir au menu',
              color: AppTheme.primaryPurple,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Un jeton : plein quand il est dans le panier, contour quand il est
/// encore sur l'étal.
class _TokenChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;

  const _TokenChip({
    required this.label,
    required this.color,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: filled ? color : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: filled ? Colors.white : color)),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 260,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.4), width: 2),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: color)),
            ),
          ],
        ),
      ),
    );
  }
}
