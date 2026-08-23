import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/number_bars_missions.dart';
import '../../services/accessibility_settings_service.dart';
import '../../services/audio_service.dart';
import '../../services/game_service.dart';
import '../../services/garden_service.dart';
import '../../services/progress_service.dart';
import '../../services/stats_service.dart';
import '../../services/tts_service.dart';
import '../../utils/adaptive_difficulty.dart';
import '../../utils/app_theme.dart';
import '../../widgets/confetti_overlay.dart';
import '../sensory/sensory_room_screen.dart';
import '../../utils/haptics.dart';

/// 🔢 Barres de nombres — micro-missions de numération.
///
/// Une petite mission, une aide claire, une récompense douce,
/// et un choix laissé à Emilie à la fin.
/// Aucun chronomètre, aucune vie, aucune perte de progression.
class NumberBarsScreen extends StatefulWidget {
  /// Si fourni, ne propose que les missions de cette competence
  /// (utilise par le mode histoire pour ouvrir une etape precise).
  final String? competence;
  const NumberBarsScreen({super.key, this.competence});

  @override
  State<NumberBarsScreen> createState() => _NumberBarsScreenState();
}

enum _Phase { objective, playing, success }

class _NumberBarsScreenState extends State<NumberBarsScreen> {
  late final String _level;
  late final List<NumberBarsMission> _missions;

  int _index = 0;
  _Phase _phase = _Phase.objective;

  int _thousands = 0, _hundreds = 0, _tens = 0, _units = 0;
  int _hintsShown = 0;
  String? _note; // message informatif (regroupement, piste après erreur)
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  NumberBarsMission get _mission => _missions[_index];
  int get _total => _thousands * 1000 + _hundreds * 100 + _tens * 10 + _units;
  Color get _levelColor =>
      _level == 'CE2' ? AppTheme.primaryPurple : AppTheme.primaryBlue;

  /// Restreint a la competence demandee ; si aucune ne correspond,
  /// on garde tout le niveau plutot que d'afficher un ecran vide.
  List<NumberBarsMission> _filtered(List<NumberBarsMission> all) {
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
      _filtered(NumberBarsData.forLevel(_level))..shuffle(),
      stats: context.read<StatsService>(),
      level: _level,
      competenceOf: (m) => m.competence,
      missionTypeOf: (m) => m.missionType,
    );
  }

  // ── Lecture de la consigne ───────────────────────────────
  void _speak(String text) {
    final access = context.read<AccessibilitySettingsService>();
    final tts = context.read<TtsService>();
    tts.setSpeechRate(access.voiceRate);
    tts.speak(text);
  }

  void _maybeAutoRead() {
    if (context.read<AccessibilitySettingsService>().autoReadEnabled) {
      _speak(_mission.objective);
    }
  }

  // ── Déroulé ──────────────────────────────────────────────
  void _startMission() {
    // Commencer une mission compte déjà : Emilie gagne une graine.
    context.read<GardenService>().rewardMissionStarted();
    context.read<StatsService>().recordStarted(_level, _mission.competence);
    setState(() {
      _phase = _Phase.playing;
      _thousands = 0; _hundreds = 0; _tens = 0; _units = 0;
      _hintsShown = 0;
      _note = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoRead());
  }

  void _add(String col) {
    AppHaptics.selection();
    context.read<AudioService>().onButtonTap();
    setState(() {
      _note = null;
      switch (col) {
        case 'u':
          _units++;
          if (_units >= 10) {
            _units -= 10; _tens++;
            _note = '✨ 10 unités se regroupent en 1 dizaine !';
          }
          break;
        case 'd':
          _tens++;
          if (_tens >= 10) {
            _tens -= 10; _hundreds++;
            _note = '✨ 10 dizaines se regroupent en 1 centaine !';
          }
          break;
        case 'c':
          _hundreds++;
          if (_mission.useThousands && _hundreds >= 10) {
            _hundreds -= 10; _thousands++;
            _note = '✨ 10 centaines se regroupent en 1 millier !';
          }
          break;
        case 'm':
          _thousands++;
          break;
      }
    });
  }

  void _remove(String col) {
    AppHaptics.selection();
    setState(() {
      _note = null;
      switch (col) {
        case 'u': if (_units > 0) _units--; break;
        case 'd': if (_tens > 0) _tens--; break;
        case 'c': if (_hundreds > 0) _hundreds--; break;
        case 'm': if (_thousands > 0) _thousands--; break;
      }
    });
  }

  void _showNextHint() {
    if (_hintsShown >= _mission.hints.length) return;
    setState(() => _hintsShown++);
    _speak(_mission.hints[_hintsShown - 1]);
  }

  /// Message informatif plutôt qu'un simple « faux ».
  String _gentleGuidance() {
    final t = _mission.target;
    final targetM = t ~/ 1000;
    final targetC = (t % 1000) ~/ 100;
    final targetD = (t % 100) ~/ 10;
    final targetU = t % 10;

    if (_mission.useThousands && _thousands != targetM) {
      return 'Regarde les milliers 🟪 — combien en faut-il ?';
    }
    if (_hundreds != targetC) {
      return 'Regarde les centaines 🟧 — compte-les à nouveau.';
    }
    if (_tens != targetD) {
      return 'Regarde les dizaines 🟩 — il en manque ou il y en a trop.';
    }
    if (_units != targetU) {
      return 'Regarde les unités 🟦 — vérifie le dernier chiffre.';
    }
    return 'Essayons autrement — veux-tu réécouter la consigne ?';
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

    // Feedback gradué selon le profil sensoriel.
    if (!access.calmModeEnabled) {
      _confettiKey.currentState?.burst();
    }
    if (access.profile == SensoryProfile.dynamique) {
      _speak('Bravo Emilie, tu as réussi !');
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
        title: const Text('🔢 Barres de nombres'),
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
                  color: _levelColor, borderRadius: BorderRadius.circular(12)),
                child: Text('Parcours $_level',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
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

  // ── 1. Écran objectif : un seul but, très simple ──────────
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
                      color: _levelColor, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
            const SizedBox(height: 24),
            const Text('🔢', style: TextStyle(fontSize: 76)),
            const SizedBox(height: 20),
            Text(
              _mission.objective,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.4),
            ),
            const SizedBox(height: 10),
            const Text('Petite mission',
                style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: () => _speak(_mission.objective),
              icon: const Icon(Icons.volume_up_rounded),
              label: const Text('Écouter'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _startMission,
              style: ElevatedButton.styleFrom(
                backgroundColor: _levelColor,
                minimumSize: const Size(200, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text('Commencer',
                  style: TextStyle(
                      color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  // ── 2. Manipulation ──────────────────────────────────────
  Widget _buildPlaying() {
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
                Expanded(
                  child: Text(_mission.objective,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ),
                IconButton(
                  onPressed: () => _speak(_mission.objective),
                  icon: const Icon(Icons.volume_up_rounded),
                  tooltip: 'Réécouter',
                  color: _levelColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Total construit
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: _levelColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text('Tu as construit',
                    style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                Text('$_total',
                    style: TextStyle(
                        fontSize: 34, fontWeight: FontWeight.w900, color: _levelColor)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Colonnes de manipulation
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_mission.useThousands)
                Expanded(
                  child: _Column(
                    label: 'milliers',
                    value: 1000,
                    count: _thousands,
                    blockColor: const Color(0xFF9575CD),
                    blockWidth: 30, blockHeight: 30,
                    onAdd: () => _add('m'),
                    onRemove: () => _remove('m'),
                  ),
                ),
              Expanded(
                child: _Column(
                  label: 'centaines',
                  value: 100,
                  count: _hundreds,
                  blockColor: const Color(0xFFFFA726),
                  blockWidth: 28, blockHeight: 28,
                  onAdd: () => _add('c'),
                  onRemove: () => _remove('c'),
                ),
              ),
              Expanded(
                child: _Column(
                  label: 'dizaines',
                  value: 10,
                  count: _tens,
                  blockColor: const Color(0xFF66BB6A),
                  blockWidth: 11, blockHeight: 40,
                  onAdd: () => _add('d'),
                  onRemove: () => _remove('d'),
                ),
              ),
              Expanded(
                child: _Column(
                  label: 'unités',
                  value: 1,
                  count: _units,
                  blockColor: const Color(0xFF42A5F5),
                  blockWidth: 15, blockHeight: 15,
                  onAdd: () => _add('u'),
                  onRemove: () => _remove('u'),
                ),
              ),
            ],
          ),

          // Message informatif (regroupement ou piste)
          if (_note != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryYellow.withOpacity(0.5), width: 2),
              ),
              child: Text(_note!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.4)),
            ),
          ],

          // Aides graduées déjà demandées
          if (_hintsShown > 0) ...[
            const SizedBox(height: 12),
            ...List.generate(_hintsShown, (i) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('💡 ${_mission.hints[i]}',
                      style: const TextStyle(fontSize: 13, height: 1.4)),
                )),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              if (_hintsShown < _mission.hints.length)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showNextHint,
                    icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
                    label: const Text('Aide'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              if (_hintsShown < _mission.hints.length) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _validate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _levelColor,
                    minimumSize: const Size(0, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Vérifier',
                      style: TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Arrêter cette mission'),
          ),
        ],
      ),
    );
  }

  // ── 3. Réussite : feedback calme + choix ─────────────────
  Widget _buildSuccess() {
    final access = context.watch<AccessibilitySettingsService>();
    final calm = access.calmModeEnabled;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // En mode calme : pictogramme fixe, aucune animation.
            Text(calm ? '⭐' : '🌟', style: const TextStyle(fontSize: 76)),
            const SizedBox(height: 16),
            const Text('C\'est trouvé.',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              _hintsShown > 0
                  ? 'Tu as utilisé une aide et tu as continué. C\'est très bien.'
                  : 'Tu as réussi tout seule. Tu peux être fière de ton effort.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.textGrey, height: 1.5),
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

/// Une colonne de manipulation : on tape « + » pour ajouter un objet,
/// « − » pour en retirer un. Pas de glisser-déposer : plus prévisible
/// et plus accessible.
class _Column extends StatelessWidget {
  final String label;
  final int value;
  final int count;
  final Color blockColor;
  final double blockWidth, blockHeight;
  final VoidCallback onAdd, onRemove;

  const _Column({
    required this.label,
    required this.value,
    required this.count,
    required this.blockColor,
    required this.blockWidth,
    required this.blockHeight,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          Text('($value)',
              style: const TextStyle(fontSize: 9, color: AppTheme.textGrey)),
          const SizedBox(height: 6),
          Container(
            height: 130,
            width: double.infinity,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: blockColor.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: blockColor.withOpacity(0.3)),
            ),
            child: SingleChildScrollView(
              reverse: true,
              child: Wrap(
                spacing: 3,
                runSpacing: 3,
                alignment: WrapAlignment.center,
                children: List.generate(count, (_) => Container(
                      width: blockWidth,
                      height: blockHeight,
                      decoration: BoxDecoration(
                        color: blockColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    )),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text('$count',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900, color: blockColor)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MiniButton(icon: Icons.remove_rounded, color: blockColor, onTap: onRemove),
              const SizedBox(width: 6),
              _MiniButton(icon: Icons.add_rounded, color: blockColor, onTap: onAdd),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _MiniButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String emoji, label;
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
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color)),
            ),
          ],
        ),
      ),
    );
  }
}
