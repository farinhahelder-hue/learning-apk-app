import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/dictee_image_data.dart';
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

/// 🖼️ Dictée image — écouter un mot, puis le construire avec des lettres
/// mobiles (ou des blocs phonologiques, selon le réglage).
///
/// Aucun son d'erreur, aucune croix rouge : quand une lettre ne convient
/// pas, elle revient doucement dans la réserve et le mot est répété.
class DicteeImageScreen extends StatefulWidget {
  /// Si fourni, ne propose que les mots de cette competence
  /// (utilise par le mode histoire pour ouvrir une etape precise).
  final String? competence;
  const DicteeImageScreen({super.key, this.competence});

  @override
  State<DicteeImageScreen> createState() => _DicteeImageScreenState();
}

enum _Phase { objective, playing, success }

class _DicteeImageScreenState extends State<DicteeImageScreen> {
  late final String _level;
  late final List<DicteeWord> _words;

  int _index = 0;
  _Phase _phase = _Phase.objective;

  /// Pièces posées par Emilie, dans l'ordre.
  List<String> _placed = [];

  /// Pièces encore disponibles (mélangées).
  List<String> _reserve = [];

  int _hintsShown = 0;
  String? _note;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  DicteeWord get _word => _words[_index];
  Color get _levelColor =>
      _level == 'CE2' ? AppTheme.primaryPurple : AppTheme.primaryBlue;

  /// Découpage attendu, figé au démarrage de la mission : si l'adulte change
  /// le réglage lettres/blocs pendant qu'Emilie joue, la mission en cours
  /// garde le découpage avec lequel elle a commencé.
  List<String> _targetPieces = [];

  /// Restreint a la competence demandee ; si aucune ne correspond,
  /// on garde tout le niveau plutot que d'afficher un ecran vide.
  List<DicteeWord> _filtered(List<DicteeWord> all) {
    final c = widget.competence;
    if (c == null) return List.of(all);
    final sub = all.where((m) => m.competence == c).toList();
    return sub.isEmpty ? List.of(all) : sub;
  }

  @override
  void initState() {
    super.initState();
    _level = context.read<GameService>().gradeLevel;
    _words = _filtered(DicteeImageData.forLevel(_level))..shuffle();
  }

  // ── Audio ────────────────────────────────────────────────
  void _speak(String text) {
    final access = context.read<AccessibilitySettingsService>();
    final tts = context.read<TtsService>();
    tts.setSpeechRate(access.voiceRate);
    tts.speak(text);
  }

  void _sayWord() => _speak(_word.word);

  // ── Déroulé ──────────────────────────────────────────────
  void _startWord() {
    final useBlocks =
        context.read<AccessibilitySettingsService>().letterBlocksEnabled;
    context.read<GardenService>().rewardMissionStarted();
    context.read<StatsService>().recordStarted(_level, _word.competence);
    setState(() {
      _phase = _Phase.playing;
      _targetPieces = _word.piecesFor(useBlocks: useBlocks);
      _placed = [];
      _reserve = List.of(_targetPieces)..shuffle();
      _hintsShown = 0;
      _note = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _sayWord());
  }

  void _takePiece(int reserveIndex) {
    HapticFeedback.selectionClick();
    context.read<AudioService>().onButtonTap();
    setState(() {
      _note = null;
      _placed.add(_reserve.removeAt(reserveIndex));
    });
  }

  /// Retirer une pièce déjà posée : elle retourne dans la réserve.
  void _returnPiece(int placedIndex) {
    HapticFeedback.selectionClick();
    setState(() {
      _note = null;
      _reserve.add(_placed.removeAt(placedIndex));
    });
  }

  void _showNextHint() {
    final hints = _buildHints();
    if (_hintsShown >= hints.length) return;
    setState(() => _hintsShown++);
    _speak(hints[_hintsShown - 1]);
  }

  /// Aides graduées : d'abord réécouter, puis des indices de plus en plus
  /// précis. Jamais imposées, toujours à la demande d'Emilie.
  List<String> _buildHints() {
    final pieces = _targetPieces;
    return [
      'Écoute encore : ${_word.word}',
      'Ce mot a ${pieces.length} morceaux à placer.',
      'Il commence par « ${pieces.first} ».',
      'Il se termine par « ${pieces.last} ».',
    ];
  }

  void _validate() {
    final target = _targetPieces;
    final built = _placed.join();

    if (built == _word.word) {
      _onSuccess();
      return;
    }

    // Correction calme : on trouve le premier morceau qui ne convient pas,
    // on renvoie doucement ce morceau et les suivants dans la réserve.
    int firstWrong = 0;
    while (firstWrong < _placed.length &&
        firstWrong < target.length &&
        _placed[firstWrong] == target[firstWrong]) {
      firstWrong++;
    }

    HapticFeedback.lightImpact();
    setState(() {
      if (firstWrong < _placed.length) {
        final returned = _placed.sublist(firstWrong);
        _placed = _placed.sublist(0, firstWrong);
        _reserve.addAll(returned);
        _note = firstWrong == 0
            ? 'Essayons autrement. Réécoute le mot 👂'
            : 'Le début est bon ! Regarde la suite 👀';
      } else {
        _note = 'Il manque encore un morceau. Réécoute le mot 👂';
      }
    });
    _sayWord();
  }

  void _onSuccess() {
    final access = context.read<AccessibilitySettingsService>();
    context.read<GardenService>().rewardActivityCompleted();
    context.read<StatsService>()
        .recordCompleted(_level, _word.competence, hintsUsed: _hintsShown);
    context.read<ProgressService>().addPoints('french', 15);
    context.read<AudioService>().onCorrectAnswer();
    HapticFeedback.mediumImpact();

    if (!access.calmModeEnabled) _confettiKey.currentState?.burst();
    if (access.profile == SensoryProfile.dynamique) {
      _speak('Bravo ! Tu as écrit ${_word.word}');
    }
    setState(() => _phase = _Phase.success);
  }

  void _nextWord() {
    setState(() {
      _index = (_index + 1) % _words.length;
      _phase = _Phase.objective;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🖼️ Dictée image'),
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
            const Text('🖼️', style: TextStyle(fontSize: 70)),
            const SizedBox(height: 20),
            const Text('Écoute puis écris le mot',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text('Petite mission',
                style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: () => _speak('Écoute puis écris le mot'),
              icon: const Icon(Icons.volume_up_rounded),
              label: const Text('Écouter'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _startWord,
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
    final hints = _buildHints();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          // L'image
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _levelColor.withOpacity(0.3), width: 2),
            ),
            child: Text(_word.emoji, style: const TextStyle(fontSize: 72)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _sayWord,
            icon: const Icon(Icons.volume_up_rounded, size: 20),
            label: const Text('Réécouter le mot'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(200, 46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 18),

          // Le mot en construction
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 76),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _levelColor.withOpacity(0.07),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _levelColor.withOpacity(0.35), width: 2),
            ),
            child: _placed.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Choisis les morceaux en dessous 👇',
                          style: TextStyle(fontSize: 13, color: AppTheme.textGrey)),
                    ),
                  )
                : Wrap(
                    spacing: 8, runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: List.generate(_placed.length, (i) {
                      return GestureDetector(
                        onTap: () => _returnPiece(i),
                        child: _Piece(text: _placed[i], color: _levelColor, filled: true),
                      );
                    }),
                  ),
          ),
          if (_placed.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('Touche un morceau pour le remettre en bas',
                  style: TextStyle(fontSize: 11, color: AppTheme.textGrey)),
            ),

          const SizedBox(height: 18),

          // La réserve
          Wrap(
            spacing: 8, runSpacing: 8,
            alignment: WrapAlignment.center,
            children: List.generate(_reserve.length, (i) {
              return GestureDetector(
                onTap: () => _takePiece(i),
                child: _Piece(text: _reserve[i], color: AppTheme.textGrey, filled: false),
              );
            }),
          ),

          // Message calme
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

          // Aides déjà demandées
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
                  child: Text('💡 ${hints[i]}',
                      style: const TextStyle(fontSize: 13, height: 1.4)),
                )),
          ],

          const SizedBox(height: 16),
          Row(
            children: [
              if (_hintsShown < hints.length)
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
              if (_hintsShown < hints.length) const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _placed.isEmpty ? null : _validate,
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

  Widget _buildSuccess() {
    final calm = context.watch<AccessibilitySettingsService>().calmModeEnabled;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_word.emoji, style: const TextStyle(fontSize: 66)),
            const SizedBox(height: 10),
            Text(_word.word,
                style: TextStyle(
                    fontSize: 34, fontWeight: FontWeight.w900, color: _levelColor)),
            const SizedBox(height: 16),
            Text(calm ? '⭐' : '🌟', style: const TextStyle(fontSize: 54)),
            const SizedBox(height: 10),
            const Text('C\'est écrit !',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              _hintsShown > 0
                  ? 'Tu as demandé de l\'aide et tu as continué. C\'est une bonne stratégie.'
                  : 'Tu as écrit le mot toute seule. Bravo pour ton effort.',
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
            const SizedBox(height: 26),
            _ChoiceButton(
                emoji: '▶️', label: 'Un autre mot', color: _levelColor, onTap: _nextWord),
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

/// Un morceau de mot : lettre isolée ou bloc phonologique.
class _Piece extends StatelessWidget {
  final String text;
  final Color color;
  final bool filled;
  const _Piece({required this.text, required this.color, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      constraints: const BoxConstraints(minWidth: 46),
      decoration: BoxDecoration(
        color: filled ? color.withOpacity(0.18) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: filled ? color : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: filled ? color : AppTheme.textDark,
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
