import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/problem_missions_data.dart';
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
import '../../utils/shuffled_choices.dart';

/// 🧩 Mission-problème — résoudre un problème étape par étape.
///
/// Le découpage est explicite : lire l'énoncé, choisir l'opération, puis
/// donner le résultat. Le schéma en barres est un échafaudage proposé à la
/// demande — jamais imposé, pour ne pas transformer chaque problème en
/// procédure rigide.
class ProblemMissionScreen extends StatefulWidget {
  /// Si fourni, ne propose que les missions de cette competence
  /// (utilise par le mode histoire pour ouvrir une etape precise).
  final String? competence;
  const ProblemMissionScreen({super.key, this.competence});

  @override
  State<ProblemMissionScreen> createState() => _ProblemMissionScreenState();
}

enum _Phase { objective, reading, solving, success }

class _ProblemMissionScreenState extends State<ProblemMissionScreen> {
  /// Sel de mélange des propositions, tiré une fois par écran.
  final int _salt = Shuffled.newSalt();

  late final String _level;
  late final List<ProblemMission> _missions;

  int _index = 0;
  _Phase _phase = _Phase.objective;

  int _stepIndex = 0;
  ProblemOp? _chosenOp;
  int? _chosenResult;
  bool _showSchema = false;
  int _hintsShown = 0;
  String? _note;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  ProblemMission get _m => _missions[_index];
  ProblemStep get _step => _m.steps[_stepIndex];
  Color get _levelColor =>
      _level == 'CE2' ? AppTheme.primaryPurple : AppTheme.primaryBlue;

  /// Restreint a la competence demandee ; si aucune ne correspond,
  /// on garde tout le niveau plutot que d'afficher un ecran vide.
  List<ProblemMission> _filtered(List<ProblemMission> all) {
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
      _filtered(ProblemMissionsData.forLevel(_level))..shuffle(),
      stats: context.read<StatsService>(),
      level: _level,
      competenceOf: (m) => m.competence,
      missionTypeOf: (m) => m.missionType,
    );
  }

  void _speak(String text) {
    final access = context.read<AccessibilitySettingsService>();
    final tts = context.read<TtsService>();
    tts.setSpeechRate(access.voiceRate);
    tts.speak(text);
  }

  void _startMission() {
    context.read<GardenService>().rewardMissionStarted();
    context.read<StatsService>().recordStarted(_level, _m.competence);
    setState(() {
      _phase = _Phase.reading;
      _stepIndex = 0;
      _chosenOp = null;
      _chosenResult = null;
      _showSchema = false;
      _hintsShown = 0;
      _note = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AccessibilitySettingsService>().autoReadEnabled) {
        _speak(_m.statement);
      }
    });
  }

  void _showNextHint() {
    if (_hintsShown >= _m.hints.length) return;
    setState(() => _hintsShown++);
    _speak(_m.hints[_hintsShown - 1]);
  }

  void _chooseOp(ProblemOp op) {
    if (_chosenOp != null) return;
    AppHaptics.light();
    if (op == _step.operation) {
      context.read<AudioService>().onCorrectAnswer();
      setState(() {
        _chosenOp = op;
        _note = null;
      });
    } else {
      setState(() => _note =
          '${op.emoji} ${op.label} : ${op.hintText}\nEst-ce bien ce qui se passe ici ? 👀');
    }
  }

  void _chooseResult(int value) {
    if (_chosenResult != null) return;
    AppHaptics.light();
    if (value == _step.result) {
      setState(() {
        _chosenResult = value;
        _note = null;
      });
      context.read<AudioService>().onCorrectAnswer();

      if (_stepIndex < _m.steps.length - 1) {
        // Passage à l'étape suivante après un court instant.
        Future.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          setState(() {
            _stepIndex++;
            _chosenOp = null;
            _chosenResult = null;
            _showSchema = false;
          });
        });
      } else {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) _onSuccess();
        });
      }
    } else {
      setState(() => _note =
          'Reprends le calcul : ${_step.writtenOperation}\nVeux-tu voir le schéma ? 📊');
    }
  }

  void _onSuccess() {
    final access = context.read<AccessibilitySettingsService>();
    context.read<GardenService>().rewardActivityCompleted();
    context.read<StatsService>()
        .recordCompleted(_level, _m.competence, hintsUsed: _hintsShown);
    context.read<ProgressService>().addPoints('math', 20);
    context.read<AudioService>().onPerfect();
    AppHaptics.medium();

    if (!access.calmModeEnabled) _confettiKey.currentState?.burst();
    if (access.profile == SensoryProfile.dynamique) {
      _speak('Bravo ! ${_m.answerSentence}');
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
        title: const Text('🧩 Mission-problème'),
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
            _Phase.reading => _buildReading(),
            _Phase.solving => _buildSolving(),
            _Phase.success => _buildSuccess(),
          },
          ConfettiOverlay(key: _confettiKey),
        ],
      ),
    );
  }

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
              child: Text(_m.missionType,
                  style: TextStyle(
                      color: _levelColor, fontWeight: FontWeight.w800, fontSize: 13)),
            ),
            const SizedBox(height: 22),
            const Text('🧩', style: TextStyle(fontSize: 70)),
            const SizedBox(height: 20),
            const Text('Résous le problème, étape par étape',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.4)),
            const SizedBox(height: 10),
            Text(
              _m.steps.length > 1
                  ? 'Ce problème a ${_m.steps.length} étapes'
                  : 'Petite mission',
              style: const TextStyle(fontSize: 13, color: AppTheme.textGrey),
            ),
            const SizedBox(height: 26),
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

  // ── Étape de lecture : une seule chose à faire, comprendre ──
  Widget _buildReading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          const Text('📖 Lis bien l\'énoncé',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textGrey)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _levelColor.withOpacity(0.3), width: 2),
            ),
            child: Text(_m.statement,
                style: const TextStyle(fontSize: 18, height: 1.6, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => _speak(_m.statement),
            icon: const Icon(Icons.volume_up_rounded, size: 20),
            label: const Text('Écouter l\'énoncé'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(220, 48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: () => setState(() => _phase = _Phase.solving),
            style: ElevatedButton.styleFrom(
              backgroundColor: _levelColor,
              minimumSize: const Size(220, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: const Text('J\'ai compris',
                style: TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
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

  // ── Résolution : opération puis résultat ─────────────────
  Widget _buildSolving() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          // Rappel de l'énoncé, toujours accessible
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(_m.statement,
                      style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.textGrey)),
                ),
                IconButton(
                  onPressed: () => _speak(_m.statement),
                  icon: const Icon(Icons.volume_up_rounded, size: 20),
                  tooltip: 'Réécouter l\'énoncé',
                  color: _levelColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (_m.steps.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('Étape ${_stepIndex + 1} sur ${_m.steps.length}',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w800, color: _levelColor)),
            ),

          Text(_step.question,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, height: 1.4)),
          const SizedBox(height: 18),

          // 1. Choisir l'opération
          if (_chosenOp == null) ...[
            const Text('Que faut-il faire ?',
                style: TextStyle(fontSize: 14, color: AppTheme.textGrey)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10, runSpacing: 10,
              alignment: WrapAlignment.center,
              children: ProblemOp.values.map((op) {
                final c = Color(op.colorValue);
                return GestureDetector(
                  onTap: () => _chooseOp(op),
                  child: Container(
                    width: 150,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.withOpacity(0.6), width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(op.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(op.label,
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 14, color: c)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ]

          // 2. Choisir le résultat
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: Color(_chosenOp!.colorValue).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${_chosenOp!.emoji}  ${_step.writtenOperation}',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(_chosenOp!.colorValue)),
              ),
            ),
            const SizedBox(height: 8),

            // Échafaudage optionnel : le schéma en barres
            TextButton.icon(
              onPressed: () => setState(() => _showSchema = !_showSchema),
              icon: const Icon(Icons.bar_chart_rounded, size: 18),
              label: Text(_showSchema ? 'Masquer le schéma' : 'Voir le schéma'),
            ),
            if (_showSchema) _buildSchema(),

            const SizedBox(height: 12),
            const Text('Quel est le résultat ?',
                style: TextStyle(fontSize: 14, color: AppTheme.textGrey)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10, runSpacing: 10,
              alignment: WrapAlignment.center,
              children: Shuffled.of(_step.choices,
                      salt: _salt, index: _step.question.hashCode)
                  .map((v) {
                final picked = _chosenResult == v;
                return GestureDetector(
                  onTap: () => _chooseResult(v),
                  child: Container(
                    width: 80,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: picked ? const Color(0xFFE8F5E9) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: picked ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Text('$v',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  ),
                );
              }).toList(),
            ),
          ],

          if (_note != null) ...[
            const SizedBox(height: 16),
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
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.5)),
            ),
          ],

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
                  child: Text('💡 ${_m.hints[i]}',
                      style: const TextStyle(fontSize: 13, height: 1.4)),
                )),
          ],

          const SizedBox(height: 14),
          if (_hintsShown < _m.hints.length)
            OutlinedButton.icon(
              onPressed: _showNextHint,
              icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
              label: const Text('Aide'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(160, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Arrêter cette mission'),
          ),
        ],
      ),
    );
  }

  /// Schéma en barres : une aide visuelle, proposée seulement à la demande.
  Widget _buildSchema() {
    final a = _step.a, b = _step.b;
    final maxVal = (a > b ? a : b).toDouble().clamp(1, double.infinity);
    final color = Color(_chosenOp!.colorValue);

    Widget bar(String label, int value, Color c) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  height: 26,
                  width: constraints.maxWidth * (value / maxVal).clamp(0.08, 1.0),
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  // La barre descend à 8 % de la largeur disponible : un
                  // nombre à deux ou trois chiffres n'y tient pas, et le
                  // réglage « taille du texte » aggrave le cas. FittedBox
                  // rétrécit le nombre au lieu de le laisser déborder —
                  // il n'agit que si c'est nécessaire.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('$value',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13)),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
      ),
      child: Column(
        children: [
          bar(_chosenOp == ProblemOp.partager ? 'total' : 'a', a, color),
          bar(_chosenOp == ProblemOp.partager ? 'parts' : 'b', b, color.withOpacity(0.6)),
          const SizedBox(height: 6),
          Text(
            switch (_chosenOp!) {
              ProblemOp.ajouter => 'On met les deux barres bout à bout.',
              ProblemOp.retirer => 'On enlève la petite barre à la grande.',
              ProblemOp.partager => 'On coupe la grande barre en parts égales.',
              ProblemOp.comparer => 'On regarde ce qui dépasse entre les deux.',
            },
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    final calm = context.watch<AccessibilitySettingsService>().calmModeEnabled;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(calm ? '⭐' : '🌟', style: const TextStyle(fontSize: 66)),
            const SizedBox(height: 14),
            const Text('Problème résolu !',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _levelColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(_m.answerSentence,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: _levelColor)),
            ),
            const SizedBox(height: 12),
            Text(
              _hintsShown > 0
                  ? 'Tu as utilisé une aide et tu es allée jusqu\'au bout. C\'est une bonne stratégie.'
                  : 'Tu as résolu le problème toute seule. Bravo pour ton effort.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.textGrey, height: 1.5),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('🌰 +1 graine    💧 +1 goutte',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            ),
            const SizedBox(height: 24),
            _ChoiceButton(
                emoji: '▶️', label: 'Un autre problème', color: _levelColor, onTap: _nextMission),
            const SizedBox(height: 10),
            _ChoiceButton(
                emoji: '🌱',
                label: 'Aller au jardin',
                color: AppTheme.primaryGreen,
                onTap: () => Navigator.pushNamed(context, '/garden')),
            const SizedBox(height: 10),
            _ChoiceButton(
                emoji: '🫧',
                label: 'Faire une pause calme',
                color: AppTheme.primaryBlue,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SensoryRoomScreen()))),
            const SizedBox(height: 10),
            _ChoiceButton(
                emoji: '🏠',
                label: 'Revenir au menu',
                color: AppTheme.primaryPurple,
                onTap: () => Navigator.pop(context)),
          ],
        ),
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
