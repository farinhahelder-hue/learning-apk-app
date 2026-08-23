import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/theatre_scenes.dart';
import '../../services/accessibility_settings_service.dart';
import '../../services/audio_service.dart';
import '../../services/game_service.dart';
import '../../services/garden_service.dart';
import '../../services/stats_service.dart';
import '../../services/tts_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/haptics.dart';
import '../../widgets/confetti_overlay.dart';

/// 🎭 Théâtre des personnages — comprendre ce que vit quelqu'un d'autre.
///
/// Deux règles tenues d'un bout à l'autre :
///
/// - **Aucune réponse n'est punie.** Un choix moins soutenu par la scène
///   reçoit une explication qui montre où regarder, pas un « faux ».
/// - **La dernière question n'a pas de bonne réponse.** Il y a plusieurs
///   façons correctes de réagir, et l'application ne classe pas celles
///   d'Emilie.
class TheatreScreen extends StatefulWidget {
  final TheatreScene? scene;
  const TheatreScreen({super.key, this.scene});

  @override
  State<TheatreScreen> createState() => _TheatreScreenState();
}

enum _Phase { scene, questions, done }

class _TheatreScreenState extends State<TheatreScreen> {
  late final String _level;
  late final TheatreScene _scene;

  _Phase _phase = _Phase.scene;
  int _qIndex = 0;
  String? _selected;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  TheatreQuestion get _q => _scene.questions[_qIndex];
  Color get _levelColor =>
      _level == 'CE2' ? AppTheme.primaryPurple : AppTheme.primaryOrange;

  @override
  void initState() {
    super.initState();
    _level = context.read<GameService>().gradeLevel;
    // Les listes de données sont const : on copie avant de mélanger.
    final pool = List.of(TheatreData.forLevel(_level));
    _scene = widget.scene ?? (pool..shuffle()).first;
    context.read<GardenService>().rewardMissionStarted();
    context.read<StatsService>().recordStarted(_level, _scene.competence);
  }

  void _speak(String text) {
    final access = context.read<AccessibilitySettingsService>();
    final tts = context.read<TtsService>();
    tts.setSpeechRate(access.voiceRate);
    tts.speak(text);
  }

  TheatreChoice _choiceFor(String label) =>
      _q.choices.firstWhere((c) => c.label == label);

  void _answer(String label) {
    if (_selected != null) return;
    AppHaptics.light();
    setState(() => _selected = label);
    // Aucun son d'erreur : même sur une question qui a une meilleure
    // réponse, se tromper ici n'est pas un échec.
    context.read<AudioService>().onCorrectAnswer();
  }

  void _next() {
    if (_qIndex < _scene.questions.length - 1) {
      setState(() {
        _qIndex++;
        _selected = null;
      });
    } else {
      _finish();
    }
  }

  void _finish() {
    final access = context.read<AccessibilitySettingsService>();
    context.read<GardenService>().rewardActivityCompleted();
    context.read<StatsService>()
        .recordCompleted(_level, _scene.competence, hintsUsed: 0);
    context.read<AudioService>().onPerfect();
    if (!access.calmModeEnabled) {
      _confettiKey.currentState?.burst();
    }
    setState(() => _phase = _Phase.done);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🎭 ${_scene.title}'),
        backgroundColor: _levelColor.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Écouter la scène',
            icon: const Icon(Icons.volume_up_rounded),
            onPressed: () => _speak(_scene.fullText),
          ),
        ],
      ),
      body: Stack(
        children: [
          switch (_phase) {
            _Phase.scene => _buildScene(),
            _Phase.questions => _buildQuestions(),
            _Phase.done => _buildDone(),
          },
          ConfettiOverlay(key: _confettiKey),
        ],
      ),
    );
  }

  // ── 1. La scène ──────────────────────────────────────────
  Widget _buildScene() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Text(_scene.settingEmoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 6),
          Text(_scene.setting,
              style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
          const SizedBox(height: 4),
          Text(_scene.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 20),

          ..._scene.lines.map((l) {
            final parts = l.split('|');
            final emoji = parts.first;
            final text = parts.last;
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _levelColor.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(text,
                        style: const TextStyle(fontSize: 16, height: 1.6)),
                  ),
                  IconButton(
                    onPressed: () => _speak(text),
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                    tooltip: 'Écouter cette réplique',
                    color: _levelColor,
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => setState(() => _phase = _Phase.questions),
            style: ElevatedButton.styleFrom(
              backgroundColor: _levelColor,
              minimumSize: const Size(250, 56),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: const Text('J\'ai lu la scène',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Sortir du théâtre'),
          ),
        ],
      ),
    );
  }

  // ── 2. Les questions ─────────────────────────────────────
  Widget _buildQuestions() {
    final open = !_q.hasBestAnswer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_qIndex + 1) / _scene.questions.length,
            backgroundColor: Colors.grey.shade200,
            color: _levelColor,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 6),
          Text('Question ${_qIndex + 1} / ${_scene.questions.length}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
          const SizedBox(height: 14),

          // La scène reste consultable : ce n'est pas un test de mémoire.
          ExpansionTile(
            title: const Text('🎭 Relire la scène',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            tilePadding: EdgeInsets.zero,
            children: _scene.lines
                .map((l) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                          '${l.split('|').first}  ${l.split('|').last}',
                          style: const TextStyle(fontSize: 14, height: 1.6)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),

          // Deux étiquettes possibles, jamais les deux à la fois.
          if (open)
            _Badge(
              text: '💭 Ici, il n\'y a pas de mauvaise réponse',
              color: AppTheme.primaryGreen,
            )
          else if (_q.isInference)
            _Badge(
              text: '🔍 La réponse n\'est pas écrite : il faut la deviner',
              color: AppTheme.primaryOrange,
            ),

          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(_q.question,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              IconButton(
                onPressed: () => _speak(_q.question),
                icon: const Icon(Icons.volume_up_rounded),
                tooltip: 'Écouter la question',
                color: _levelColor,
              ),
            ],
          ),
          const SizedBox(height: 12),

          ..._q.choices.map((c) {
            Color bg = Colors.white;
            Color border = Colors.grey.shade300;
            if (_selected != null) {
              final isBest = _q.hasBestAnswer && c.label == _q.bestAnswer;
              final isMine = c.label == _selected;
              if (open && isMine) {
                bg = const Color(0xFFE8F5E9);
                border = AppTheme.primaryGreen;
              } else if (isBest) {
                bg = const Color(0xFFE8F5E9);
                border = const Color(0xFF4CAF50);
              } else if (isMine) {
                bg = const Color(0xFFF5F5F5);
              }
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _answer(c.label),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 2),
                  ),
                  child: Text(c.label,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            );
          }),

          // La réponse du théâtre au choix fait, quel qu'il soit.
          if (_selected != null) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.primaryYellow.withOpacity(0.5), width: 2),
              ),
              child: Text('🎭 ${_choiceFor(_selected!).response}',
                  style: const TextStyle(fontSize: 13, height: 1.5)),
            ),
            if (_q.evidence != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('👀 Dans la scène : ${_q.evidence}',
                    style: const TextStyle(
                        fontSize: 12, height: 1.4, color: AppTheme.textGrey)),
              ),
            ],
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: _levelColor,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                _qIndex < _scene.questions.length - 1
                    ? 'Question suivante ➡️'
                    : 'Terminer la scène 🎭',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── 3. Fin ───────────────────────────────────────────────
  Widget _buildDone() {
    final calm = context.watch<AccessibilitySettingsService>().calmModeEnabled;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(calm ? '🎭' : '👏', style: const TextStyle(fontSize: 70)),
            const SizedBox(height: 14),
            const Text('Rideau !',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text(
              'Tu as regardé une scène et cherché ce que vivaient les '
              'personnages. Il n\'y a pas de score ici : comprendre les '
              'autres, ça se travaille toute la vie.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: AppTheme.textGrey, height: 1.6),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('🌰 +1 graine    💧 +1 goutte',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            ),
            const SizedBox(height: 26),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _levelColor,
                minimumSize: const Size(230, 54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text('Retour',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
