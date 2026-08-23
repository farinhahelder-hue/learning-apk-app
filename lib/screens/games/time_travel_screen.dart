import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/discovery_games_data.dart';
import '../../services/audio_service.dart';
import '../../services/game_service.dart';
import '../../services/progress_service.dart';
import '../../services/accessibility_settings_service.dart';
import '../../services/garden_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/confetti_overlay.dart';
import '../../utils/haptics.dart';

/// ⏳ Voyage dans le temps — remettre une frise dans l'ordre.
/// L'enfant tape les cartes une par une pour construire sa frise.
/// CE1 : le temps vécu (journée, saisons, vie).
/// CE2 : les grandes périodes historiques, personnages et inventions.
class TimeTravelScreen extends StatefulWidget {
  const TimeTravelScreen({super.key});

  @override
  State<TimeTravelScreen> createState() => _TimeTravelScreenState();
}

class _TimeTravelScreenState extends State<TimeTravelScreen> {
  late final String _level;
  late final List<TimelineRound> _rounds;

  int _roundIndex = 0;
  List<int> _shuffledOrder = [];   // indices d'origine, mélangés
  final List<int> _placed = [];    // indices d'origine, dans l'ordre choisi
  bool _checked = false;
  bool _wasCorrect = false;
  int _collected = 0;
  bool _finished = false;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  bool get _isCE2 => _level == 'CE2';

  @override
  void initState() {
    super.initState();
    _level = context.read<GameService>().gradeLevel;
    _rounds = _isCE2 ? TimeTravelData.ce2Rounds : TimeTravelData.ce1Rounds;
    _prepareRound();
  }

  TimelineRound get _round => _rounds[_roundIndex];

  void _prepareRound() {
    _shuffledOrder = List.generate(_round.emojis.length, (i) => i)..shuffle();
    _placed.clear();
    _checked = false;
    _wasCorrect = false;
  }

  void _onTapCard(int originalIndex) {
    if (_checked || _placed.contains(originalIndex)) return;
    AppHaptics.selection();
    context.read<AudioService>().onButtonTap();
    setState(() => _placed.add(originalIndex));

    if (_placed.length == _round.emojis.length) {
      _check();
    }
  }

  void _undo() {
    if (_checked || _placed.isEmpty) return;
    AppHaptics.selection();
    setState(() => _placed.removeLast());
  }

  void _check() {
    // La frise est correcte si les indices sont dans l'ordre 0,1,2,3...
    bool correct = true;
    for (var i = 0; i < _placed.length; i++) {
      if (_placed[i] != i) { correct = false; break; }
    }

    final calm = context.read<AccessibilitySettingsService>().calmModeEnabled;
    final audio = context.read<AudioService>();

    setState(() {
      _checked = true;
      _wasCorrect = correct;
      if (correct) _collected++;
    });

    if (correct) {
      AppHaptics.medium();
      audio.onCorrectAnswer();
      context.read<ProgressService>().addPoints('game', 15);
      if (!calm) _confettiKey.currentState?.burst();
    } else {
      audio.onWrongAnswer();
    }
  }

  void _next() {
    if (_roundIndex < _rounds.length - 1) {
      setState(() {
        _roundIndex++;
        _prepareRound();
      });
    } else {
      final calm = context.read<AccessibilitySettingsService>().calmModeEnabled;
      context.read<AudioService>().onPerfect();
      context.read<GardenService>().rewardActivityCompleted();
      if (!calm) _confettiKey.currentState?.burst(ConfettiType.celebrate);
      setState(() => _finished = true);
    }
  }

  void _retryRound() {
    setState(_prepareRound);
  }

  void _restartAll() {
    setState(() {
      _roundIndex = 0;
      _collected = 0;
      _finished = false;
      _prepareRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _isCE2 ? AppTheme.primaryPurple : AppTheme.primaryBlue;
    return Scaffold(
      appBar: AppBar(
        title: const Text('⏳ Voyage dans le temps'),
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
          _finished ? _buildResults(levelColor) : _buildGame(levelColor),
          ConfettiOverlay(key: _confettiKey),
        ],
      ),
    );
  }

  Widget _buildGame(Color levelColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text('Frise ${_roundIndex + 1} / ${_rounds.length}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textGrey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(_round.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Tape les cartes du plus ancien au plus récent',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
          const SizedBox(height: 20),

          // La frise en construction
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: levelColor.withOpacity(0.3), width: 2),
            ),
            child: Column(
              children: [
                const Text('⬅️ Le plus ancien          Le plus récent ➡️',
                    style: TextStyle(fontSize: 11, color: AppTheme.textGrey, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_round.emojis.length, (slot) {
                    final filled = slot < _placed.length;
                    final originalIndex = filled ? _placed[slot] : -1;
                    final slotOk = _checked && originalIndex == slot;
                    return Expanded(
                      child: Container(
                        height: 62,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: !filled
                              ? Colors.grey.shade100
                              : _checked
                                  ? (slotOk ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1))
                                  : levelColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: !filled
                                ? Colors.grey.shade300
                                : _checked
                                    ? (slotOk ? const Color(0xFF4CAF50) : AppTheme.primaryOrange)
                                    : levelColor,
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          filled ? _round.emojis[originalIndex] : '${slot + 1}',
                          style: TextStyle(
                            fontSize: filled ? 28 : 18,
                            color: filled ? null : Colors.grey.shade400,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Les cartes à placer
          if (!_checked)
            Wrap(
              spacing: 12, runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _shuffledOrder.map((originalIndex) {
                final used = _placed.contains(originalIndex);
                return GestureDetector(
                  onTap: () => _onTapCard(originalIndex),
                  child: AnimatedOpacity(
                    opacity: used ? 0.25 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 150,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: levelColor.withOpacity(0.35), width: 2),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(_round.emojis[originalIndex], style: const TextStyle(fontSize: 34)),
                          const SizedBox(height: 6),
                          Text(_round.labels[originalIndex],
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

          if (!_checked && _placed.isNotEmpty) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _undo,
              icon: const Icon(Icons.undo_rounded, size: 18),
              label: const Text('Annuler la dernière carte'),
            ),
          ],

          // Résultat de la frise + explication (toujours, pas juste correct/faux)
          if (_checked) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _wasCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _wasCorrect ? const Color(0xFF4CAF50) : AppTheme.primaryOrange,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _wasCorrect ? '🎉 Frise parfaite !' : '🌈 Presque ! Voici le bon ordre :',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8, runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: List.generate(_round.emojis.length, (i) => Text(
                      '${i + 1}. ${_round.emojis[i]} ${_round.labels[i]}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    )),
                  ),
                  const SizedBox(height: 10),
                  Text('💡 ${_round.explanation}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, height: 1.4, color: AppTheme.textDark)),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.15),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_wasCorrect) ...[
                  OutlinedButton(
                    onPressed: _retryRound,
                    child: const Text('🔄 Réessayer'),
                  ),
                  const SizedBox(width: 12),
                ],
                ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(backgroundColor: levelColor),
                  child: Text(
                    _roundIndex < _rounds.length - 1 ? 'Frise suivante ➡️' : 'Voir le résultat 🏆',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResults(Color levelColor) {
    final stars = _collected == _rounds.length ? 3 : (_collected >= _rounds.length * 0.6 ? 2 : 1);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(stars == 3 ? '🏆' : '🌟', style: const TextStyle(fontSize: 80)),
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
            Text('$_collected / ${_rounds.length} frises réussies du premier coup',
                style: const TextStyle(fontSize: 16, color: AppTheme.textGrey),
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _restartAll,
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
