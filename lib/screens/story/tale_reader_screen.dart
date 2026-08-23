import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/tales_data.dart';
import '../../services/accessibility_settings_service.dart';
import '../../services/audio_service.dart';
import '../../services/game_service.dart';
import '../../services/garden_service.dart';
import '../../services/progress_service.dart';
import '../../services/stats_service.dart';
import '../../services/tts_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/confetti_overlay.dart';
import '../../utils/haptics.dart';

/// 📖 Lire ou écouter une histoire, puis répondre à des questions.
///
/// Le texte reste affiché pendant les questions : il ne s'agit pas d'un
/// test de mémoire mais de compréhension. Chaque réponse est suivie d'une
/// explication, et les questions d'inférence sont signalées comme telles.
class TaleReaderScreen extends StatefulWidget {
  final Tale? tale;

  /// Compétence du parcours à créditer (mode histoire). Si elle est
  /// fournie, on choisit en priorité une histoire qui la travaille.
  final String? competence;

  const TaleReaderScreen({super.key, this.tale, this.competence});

  @override
  State<TaleReaderScreen> createState() => _TaleReaderScreenState();
}

enum _Phase { reading, questions, done }

class _TaleReaderScreenState extends State<TaleReaderScreen> {
  late final String _level;
  late final Tale _tale;
  late final String _competence;

  _Phase _phase = _Phase.reading;
  int _qIndex = 0;
  int _score = 0;
  String? _selected;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  TaleQuestion get _q => _tale.questions[_qIndex];
  Color get _levelColor =>
      _level == 'CE2' ? AppTheme.primaryPurple : AppTheme.primaryBlue;

  @override
  void initState() {
    super.initState();
    _level = context.read<GameService>().gradeLevel;
    // Copie explicite : les listes de tales_data sont const, donc non
    // modifiables — on ne peut pas les mélanger en place.
    final pool = List.of(TalesData.forLevel(_level));
    final wanted = widget.competence;
    final matching =
        wanted == null ? <Tale>[] : pool.where((t) => t.competence == wanted).toList();
    final choices = matching.isNotEmpty ? matching : pool;
    _tale = widget.tale ?? (choices..shuffle()).first;
    _competence = wanted ?? _tale.competence;
    context.read<GardenService>().rewardMissionStarted();
    context.read<StatsService>().recordStarted(_level, _competence);
  }

  void _speak(String text) {
    final access = context.read<AccessibilitySettingsService>();
    final tts = context.read<TtsService>();
    tts.setSpeechRate(access.voiceRate);
    tts.speak(text);
  }

  void _answer(String choice) {
    if (_selected != null) return;
    AppHaptics.light();
    final correct = choice == _q.answer;
    setState(() {
      _selected = choice;
      if (correct) _score++;
    });
    final audio = context.read<AudioService>();
    correct ? audio.onCorrectAnswer() : audio.onWrongAnswer();
  }

  void _next() {
    if (_qIndex < _tale.questions.length - 1) {
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
        .recordCompleted(_level, _competence, hintsUsed: 0);
    context.read<ProgressService>().addPoints('french', 15);
    context.read<AudioService>().onPerfect();
    if (!access.calmModeEnabled) {
      _confettiKey.currentState?.burst(ConfettiType.celebrate);
    }
    setState(() => _phase = _Phase.done);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_tale.emoji} ${_tale.title}'),
        backgroundColor: _levelColor.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Écouter l\'histoire',
            icon: const Icon(Icons.volume_up_rounded),
            onPressed: () => _speak(_tale.fullText),
          ),
        ],
      ),
      body: Stack(
        children: [
          switch (_phase) {
            _Phase.reading => _buildReading(),
            _Phase.questions => _buildQuestions(),
            _Phase.done => _buildDone(),
          },
          ConfettiOverlay(key: _confettiKey),
        ],
      ),
    );
  }

  Widget _buildReading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Text(_tale.emoji, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 8),
          Text(_tale.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          ..._tale.paragraphs.map((p) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _levelColor.withOpacity(0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(p,
                          style: const TextStyle(fontSize: 17, height: 1.7)),
                    ),
                    IconButton(
                      onPressed: () => _speak(p),
                      icon: const Icon(Icons.volume_up_rounded, size: 20),
                      tooltip: 'Écouter ce passage',
                      color: _levelColor,
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => setState(() => _phase = _Phase.questions),
            style: ElevatedButton.styleFrom(
              backgroundColor: _levelColor,
              minimumSize: const Size(240, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: const Text('J\'ai lu, je réponds',
                style: TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Arrêter la lecture'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_qIndex + 1) / _tale.questions.length,
            backgroundColor: Colors.grey.shade200,
            color: _levelColor,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 6),
          Text('Question ${_qIndex + 1} / ${_tale.questions.length}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
          const SizedBox(height: 14),

          // Le texte reste consultable : ce n'est pas un test de mémoire.
          ExpansionTile(
            title: const Text('📖 Relire l\'histoire',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            tilePadding: EdgeInsets.zero,
            children: _tale.paragraphs
                .map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(p,
                          style: const TextStyle(fontSize: 14, height: 1.6)),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),

          if (_q.isInference)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('🔍 La réponse n\'est pas écrite : il faut deviner',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ),

          Row(
            children: [
              Expanded(
                child: Text(_q.question,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
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
            Color fg = AppTheme.textDark;
            if (_selected != null) {
              if (c == _q.answer) {
                bg = const Color(0xFFE8F5E9);
                border = const Color(0xFF4CAF50);
                fg = const Color(0xFF2E7D32);
              } else if (c == _selected) {
                bg = const Color(0xFFF5F5F5);
              }
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _answer(c),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 2),
                  ),
                  child: Text(c,
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600, color: fg)),
                ),
              ),
            );
          }),

          // Explication après CHAQUE réponse
          if (_selected != null) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryYellow.withOpacity(0.5), width: 2),
              ),
              child: Text('💡 ${_q.explanation}',
                  style: const TextStyle(fontSize: 13, height: 1.5)),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: _levelColor,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                _qIndex < _tale.questions.length - 1
                    ? 'Question suivante ➡️'
                    : 'Terminer l\'histoire 🏆',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDone() {
    final calm = context.watch<AccessibilitySettingsService>().calmModeEnabled;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(calm ? '⭐' : '🌟', style: const TextStyle(fontSize: 66)),
            const SizedBox(height: 14),
            const Text('Histoire terminée !',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Text('$_score / ${_tale.questions.length} bonnes réponses',
                style: const TextStyle(fontSize: 16, color: AppTheme.textGrey)),
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
            const SizedBox(height: 26),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _levelColor,
                minimumSize: const Size(220, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text('Retour au parcours',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}
