import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/sentence_workshop_data.dart';
import '../../services/accessibility_settings_service.dart';
import '../../services/audio_service.dart';
import '../../services/game_service.dart';
import '../../services/garden_service.dart';
import '../../services/progress_service.dart';
import '../../services/stats_service.dart';
import '../../services/tts_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/confetti_overlay.dart';
import '../sensory/sensory_room_screen.dart';

/// 🧱 Chantier des phrases — construire, repérer, accorder.
///
/// Les natures de mots ont un code couleur inspiré de Montessori, mais le
/// nom de la nature est toujours écrit : rien à mémoriser de tête.
class SentenceWorkshopScreen extends StatefulWidget {
  /// Si fourni, ne propose que les missions de cette competence
  /// (utilise par le mode histoire pour ouvrir une etape precise).
  final String? competence;
  const SentenceWorkshopScreen({super.key, this.competence});

  @override
  State<SentenceWorkshopScreen> createState() => _SentenceWorkshopScreenState();
}

enum _Phase { objective, playing, success }

class _SentenceWorkshopScreenState extends State<SentenceWorkshopScreen> {
  late final String _level;
  late final List<SentenceMission> _missions;

  int _index = 0;
  _Phase _phase = _Phase.objective;

  List<SentenceWord> _placed = [];
  List<SentenceWord> _reserve = [];
  String? _chosen;
  int _hintsShown = 0;
  String? _note;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  SentenceMission get _m => _missions[_index];
  Color get _levelColor =>
      _level == 'CE2' ? AppTheme.primaryPurple : AppTheme.primaryBlue;

  /// Restreint a la competence demandee ; si aucune ne correspond,
  /// on garde tout le niveau plutot que d'afficher un ecran vide.
  List<SentenceMission> _filtered(List<SentenceMission> all) {
    final c = widget.competence;
    if (c == null) return List.of(all);
    final sub = all.where((m) => m.competence == c).toList();
    return sub.isEmpty ? List.of(all) : sub;
  }

  @override
  void initState() {
    super.initState();
    _level = context.read<GameService>().gradeLevel;
    _missions = _filtered(SentenceWorkshopData.forLevel(_level))..shuffle();
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
      _phase = _Phase.playing;
      _placed = [];
      _reserve = List.of(_m.words)..shuffle();
      _chosen = null;
      _hintsShown = 0;
      _note = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AccessibilitySettingsService>().autoReadEnabled) {
        _speak(_m.objective);
      }
    });
  }

  void _showNextHint() {
    if (_hintsShown >= _m.hints.length) return;
    setState(() => _hintsShown++);
    _speak(_m.hints[_hintsShown - 1]);
  }

  // ── Interactions selon le type de mission ────────────────
  void _takeWord(int i) {
    HapticFeedback.selectionClick();
    context.read<AudioService>().onButtonTap();
    setState(() {
      _note = null;
      _placed.add(_reserve.removeAt(i));
    });
  }

  void _returnWord(int i) {
    HapticFeedback.selectionClick();
    setState(() {
      _note = null;
      _reserve.add(_placed.removeAt(i));
    });
  }

  void _tapNature(SentenceWord w) {
    if (_chosen != null) return;
    HapticFeedback.lightImpact();
    setState(() => _chosen = w.text);
    if (w.nature == _m.targetNature) {
      _onSuccess();
    } else {
      setState(() {
        _note = 'Ce mot est un ${w.nature.label}. '
            'On cherche le ${_m.targetNature!.label} — essaie encore 👀';
        _chosen = null;
      });
    }
  }

  void _tapChoice(String choice) {
    if (_chosen != null) return;
    HapticFeedback.lightImpact();
    if (choice == _m.answer) {
      setState(() => _chosen = choice);
      _onSuccess();
    } else {
      setState(() => _note = 'Essayons autrement. Veux-tu une aide ? 💡');
    }
  }

  void _validateOrder() {
    final expected = _m.words.map((w) => w.text).toList();
    final built = _placed.map((w) => w.text).toList();

    if (built.length == expected.length) {
      var same = true;
      for (var i = 0; i < expected.length; i++) {
        if (built[i] != expected[i]) { same = false; break; }
      }
      if (same) { _onSuccess(); return; }
    }

    // Correction douce : on garde le début correct, le reste revient.
    int firstWrong = 0;
    while (firstWrong < _placed.length &&
        firstWrong < expected.length &&
        _placed[firstWrong].text == expected[firstWrong]) {
      firstWrong++;
    }
    HapticFeedback.lightImpact();
    setState(() {
      if (firstWrong < _placed.length) {
        final returned = _placed.sublist(firstWrong);
        _placed = _placed.sublist(0, firstWrong);
        _reserve.addAll(returned);
        _note = firstWrong == 0
            ? 'Essayons autrement. Par quel mot commence la phrase ? 👀'
            : 'Le début est bon ! Regarde la suite 👀';
      } else {
        _note = 'Il manque encore un mot à placer.';
      }
    });
  }

  void _onSuccess() {
    final access = context.read<AccessibilitySettingsService>();
    context.read<GardenService>().rewardActivityCompleted();
    context.read<StatsService>()
        .recordCompleted(_level, _m.competence, hintsUsed: _hintsShown);
    context.read<ProgressService>().addPoints('french', 15);
    context.read<AudioService>().onCorrectAnswer();
    HapticFeedback.mediumImpact();

    if (!access.calmModeEnabled) _confettiKey.currentState?.burst();
    if (access.profile == SensoryProfile.dynamique) {
      _speak('Bravo Emilie !');
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
        title: const Text('🧱 Chantier des phrases'),
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
            const Text('🧱', style: TextStyle(fontSize: 70)),
            const SizedBox(height: 20),
            Text(_m.objective,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, height: 1.4)),
            const SizedBox(height: 10),
            const Text('Petite mission',
                style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
            const SizedBox(height: 26),
            OutlinedButton.icon(
              onPressed: () => _speak(_m.objective),
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

  Widget _buildPlaying() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          // Consigne
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
                  child: Text(_m.objective,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                ),
                IconButton(
                  onPressed: () => _speak(_m.objective),
                  icon: const Icon(Icons.volume_up_rounded),
                  tooltip: 'Réécouter',
                  color: _levelColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          switch (_m.kind) {
            SentenceKind.construire => _buildConstruire(),
            SentenceKind.reperer => _buildReperer(),
            SentenceKind.accorder => _buildAccorder(),
          },

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
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, height: 1.4)),
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

          const SizedBox(height: 16),
          Row(
            children: [
              if (_hintsShown < _m.hints.length)
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
              if (_m.kind == SentenceKind.construire) ...[
                if (_hintsShown < _m.hints.length) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _placed.isEmpty ? null : _validateOrder,
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

  // ── Type 1 : construire la phrase ────────────────────────
  Widget _buildConstruire() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 84),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _levelColor.withOpacity(0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _levelColor.withOpacity(0.35), width: 2),
          ),
          child: _placed.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Text('Choisis les mots en dessous 👇',
                        style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
                  ),
                )
              : Wrap(
                  spacing: 8, runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: List.generate(_placed.length, (i) => GestureDetector(
                        onTap: () => _returnWord(i),
                        child: _WordChip(word: _placed[i], placed: true),
                      )),
                ),
        ),
        if (_placed.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text('Touche un mot pour le remettre en bas',
                style: TextStyle(fontSize: 11, color: AppTheme.textGrey)),
          ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 8, runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(_reserve.length, (i) => GestureDetector(
                onTap: () => _takeWord(i),
                child: _WordChip(word: _reserve[i], placed: false),
              )),
        ),
      ],
    );
  }

  // ── Type 2 : repérer une nature ──────────────────────────
  Widget _buildReperer() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Color(_m.targetNature!.colorValue).withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'On cherche : ${_m.targetNature!.symbol}  ${_m.targetNature!.label}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: Color(_m.targetNature!.colorValue),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10, runSpacing: 10,
          alignment: WrapAlignment.center,
          children: _m.words
              .map((w) => GestureDetector(
                    onTap: () => _tapNature(w),
                    // Sur ce type de mission, la nature reste cachée :
                    // c'est justement ce qu'Emilie doit trouver.
                    child: _WordChip(word: w, placed: false, hideNature: true),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ── Type 3 : accorder ────────────────────────────────────
  Widget _buildAccorder() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _levelColor.withOpacity(0.3), width: 2),
          ),
          child: Text(
            _chosen == null
                ? _m.gapSentence!
                : _m.gapSentence!.replaceFirst('___', _chosen!),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, height: 1.5),
          ),
        ),
        const SizedBox(height: 8),
        IconButton(
          onPressed: () => _speak(_m.gapSentence!.replaceAll('___', 'quoi ?')),
          icon: const Icon(Icons.volume_up_rounded),
          tooltip: 'Écouter la phrase',
          color: _levelColor,
        ),
        const SizedBox(height: 8),
        ...(_m.choices ?? []).map((c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _tapChoice(c),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                  decoration: BoxDecoration(
                    color: _chosen == c ? const Color(0xFFE8F5E9) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _chosen == c ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Text(c,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSuccess() {
    final calm = context.watch<AccessibilitySettingsService>().calmModeEnabled;
    final sentence = _m.kind == SentenceKind.accorder
        ? _m.gapSentence!.replaceFirst('___', _m.answer!)
        : _m.sentence;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(calm ? '⭐' : '🌟', style: const TextStyle(fontSize: 66)),
            const SizedBox(height: 14),
            const Text('C\'est réussi !',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _levelColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(sentence,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w800, color: _levelColor)),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _speak(sentence),
              icon: const Icon(Icons.volume_up_rounded, size: 18),
              label: const Text('Écouter la phrase'),
            ),
            const SizedBox(height: 12),
            Text(
              _hintsShown > 0
                  ? 'Tu as demandé de l\'aide et tu as continué. C\'est une bonne stratégie.'
                  : 'Tu as trouvé toute seule. Bravo pour ton effort.',
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
                emoji: '▶️', label: 'Une autre phrase', color: _levelColor, onTap: _nextMission),
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

/// Un mot du chantier. La couleur rappelle sa nature, mais le NOM de la
/// nature est toujours écrit dessous — sauf sur les missions « repérer »,
/// où c'est justement ce qu'Emilie doit trouver.
class _WordChip extends StatelessWidget {
  final SentenceWord word;
  final bool placed;
  final bool hideNature;

  const _WordChip({
    required this.word,
    required this.placed,
    this.hideNature = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(word.nature.colorValue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: hideNature
            ? Colors.white
            : (placed ? color.withOpacity(0.16) : Colors.white),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hideNature ? Colors.grey.shade400 : color,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(word.text,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: hideNature ? AppTheme.textDark : color,
              )),
          if (!hideNature) ...[
            const SizedBox(height: 2),
            Text('${word.nature.symbol} ${word.nature.label}',
                style: TextStyle(fontSize: 10, color: color.withOpacity(0.85))),
          ],
        ],
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
