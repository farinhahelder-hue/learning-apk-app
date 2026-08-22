import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/discovery_games_data.dart';
import '../../services/audio_service.dart';
import '../../services/game_service.dart';
import '../../services/progress_service.dart';
import '../../services/accessibility_settings_service.dart';
import '../../services/tts_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/confetti_overlay.dart';

/// 🌦️ Météo Express — Emilie devient présentatrice météo.
/// CE1 : reconnaître les symboles, associer tenue et saison.
/// CE2 : lire un tableau de températures, comparer, météo vs climat.
/// Chaque réponse est suivie d'une explication, jamais d'un simple "faux".
class WeatherExpressScreen extends StatefulWidget {
  const WeatherExpressScreen({super.key});

  @override
  State<WeatherExpressScreen> createState() => _WeatherExpressScreenState();
}

class _WeatherExpressScreenState extends State<WeatherExpressScreen> {
  late final String _level;
  late List<WeatherQuestion> _questions;

  int _index = 0;
  int _score = 0;
  String? _selected;
  bool _finished = false;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  bool get _isCE2 => _level == 'CE2';
  bool get _answered => _selected != null;

  @override
  void initState() {
    super.initState();
    _level = context.read<GameService>().gradeLevel;
    _questions = List.of(
      _isCE2 ? WeatherExpressData.ce2Questions : WeatherExpressData.ce1Questions,
    )..shuffle();
  }

  WeatherQuestion get _q => _questions[_index];

  void _onAnswer(String choice) {
    if (_answered) return;
    final correct = choice == _q.answer;
    final calm = context.read<AccessibilitySettingsService>().calmModeEnabled;
    final audio = context.read<AudioService>();

    HapticFeedback.lightImpact();
    setState(() {
      _selected = choice;
      if (correct) _score++;
    });

    if (correct) {
      audio.onCorrectAnswer();
      context.read<ProgressService>().addPoints('game', 10);
      if (!calm) _confettiKey.currentState?.burst();
    } else {
      audio.onWrongAnswer();
    }
  }

  void _next() {
    if (_index < _questions.length - 1) {
      setState(() {
        _index++;
        _selected = null;
      });
    } else {
      final calm = context.read<AccessibilitySettingsService>().calmModeEnabled;
      context.read<AudioService>().onPerfect();
      if (!calm) _confettiKey.currentState?.burst(ConfettiType.celebrate);
      setState(() => _finished = true);
    }
  }

  void _listen() {
    context.read<TtsService>().speak(_q.prompt);
  }

  void _restart() {
    setState(() {
      _questions.shuffle();
      _index = 0;
      _score = 0;
      _selected = null;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _isCE2 ? AppTheme.primaryPurple : AppTheme.primaryBlue;
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌦️ Météo Express'),
        backgroundColor: levelColor.withOpacity(0.15),
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
                decoration: BoxDecoration(color: levelColor, borderRadius: BorderRadius.circular(12)),
                child: Text('Programme $_level',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _finished ? _buildResults(levelColor) : _buildQuestion(levelColor),
          ConfettiOverlay(key: _confettiKey),
        ],
      ),
    );
  }

  Widget _buildQuestion(Color levelColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_index + 1) / _questions.length,
            backgroundColor: Colors.grey.shade200,
            color: levelColor,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 6),
          Text('Bulletin ${_index + 1} / ${_questions.length}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
          const SizedBox(height: 16),

          // Grand symbole météo
          Text(_q.bigSymbol, style: const TextStyle(fontSize: 76))
              .animate(key: ValueKey(_index))
              .fadeIn(duration: 350.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

          const SizedBox(height: 12),

          // Tableau de températures (CE2)
          if (_q.tableRows != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: levelColor.withOpacity(0.3), width: 2),
              ),
              child: Column(
                children: _q.tableRows!.map((row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(row[0], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: levelColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(row[1],
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: levelColor)),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Consigne + bouton écouter
          Row(
            children: [
              Expanded(
                child: Text(_q.prompt,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              ),
              IconButton(
                onPressed: _listen,
                icon: const Icon(Icons.volume_up_rounded),
                tooltip: 'Écouter la consigne',
                color: levelColor,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Réponses
          ..._q.choices.map((choice) {
            Color bg = Colors.white;
            Color border = Colors.grey.shade200;
            Color fg = AppTheme.textDark;
            if (_answered) {
              if (choice == _q.answer) {
                bg = const Color(0xFFE8F5E9); border = const Color(0xFF4CAF50); fg = const Color(0xFF2E7D32);
              } else if (choice == _selected) {
                bg = const Color(0xFFF5F5F5); border = Colors.grey.shade300;
              }
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => _onAnswer(choice),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 2),
                  ),
                  child: Text(choice,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: fg)),
                ),
              ),
            );
          }),

          // Explication après CHAQUE réponse, bonne ou non
          if (_answered) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryYellow.withOpacity(0.5), width: 2),
              ),
              child: Text('💡 ${_q.explanation}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w600)),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.15),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: levelColor,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: Text(
                _index < _questions.length - 1 ? 'Bulletin suivant ➡️' : 'Voir le résultat 🏆',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResults(Color levelColor) {
    final pct = _questions.isEmpty ? 0.0 : _score / _questions.length;
    final stars = pct >= 1.0 ? 3 : (pct >= 0.7 ? 2 : (pct >= 0.4 ? 1 : 0));
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(stars == 3 ? '📺🏆' : '📺🌟', style: const TextStyle(fontSize: 70)),
            const SizedBox(height: 12),
            const Text('Bulletin météo terminé !',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (s) => Icon(
                s < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                color: s < stars ? Colors.amber : Colors.grey.shade300,
                size: 44,
              )),
            ),
            const SizedBox(height: 12),
            Text('$_score / ${_questions.length} bonnes réponses',
                style: const TextStyle(fontSize: 16, color: AppTheme.textGrey)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _restart,
              style: ElevatedButton.styleFrom(backgroundColor: levelColor),
              child: const Text('🔄 Rejouer', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Retour aux mini-jeux'),
            ),
          ],
        ),
      ),
    );
  }
}
