import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/map_missions.dart';
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

/// 🗺️ Carte au trésor — se repérer et se déplacer sur un plan.
///
/// On avance case par case, et le chemin parcouru reste visible : Emilie
/// peut voir d'où elle vient. Aucun déplacement n'est « faux » — se
/// tromper de direction fait juste avancer ailleurs, et on peut revenir.
class TreasureMapScreen extends StatefulWidget {
  /// Si fourni, ne propose que les missions de cette compétence.
  final String? competence;
  const TreasureMapScreen({super.key, this.competence});

  @override
  State<TreasureMapScreen> createState() => _TreasureMapScreenState();
}

enum _Phase { objective, playing, success }

/// Les quatre directions, nommées différemment selon le niveau.
enum _Dir { nord, sud, est, ouest }

extension _DirInfo on _Dir {
  int get dCol => switch (this) {
        _Dir.est => 1,
        _Dir.ouest => -1,
        _Dir.nord => 0,
        _Dir.sud => 0,
      };

  int get dRow => switch (this) {
        _Dir.nord => -1,
        _Dir.sud => 1,
        _Dir.est => 0,
        _Dir.ouest => 0,
      };

  String get arrow => switch (this) {
        _Dir.nord => '⬆️',
        _Dir.sud => '⬇️',
        _Dir.ouest => '⬅️',
        _Dir.est => '➡️',
      };

  /// Nom affiché : les flèches parlent d'elles-mêmes en CE1, le CE2
  /// nomme les points cardinaux.
  String label(bool cardinal) => cardinal
      ? switch (this) {
          _Dir.nord => 'Nord',
          _Dir.sud => 'Sud',
          _Dir.est => 'Est',
          _Dir.ouest => 'Ouest',
        }
      : switch (this) {
          _Dir.nord => 'Haut',
          _Dir.sud => 'Bas',
          _Dir.est => 'Droite',
          _Dir.ouest => 'Gauche',
        };
}

class _TreasureMapScreenState extends State<TreasureMapScreen> {
  late final String _level;
  late final List<MapMission> _missions;

  int _index = 0;
  _Phase _phase = _Phase.objective;

  int _col = 0;
  int _row = 0;

  /// Les cases déjà parcourues, pour montrer le chemin.
  final List<int> _trail = [];

  int _moves = 0;
  int _hintsShown = 0;
  String? _note;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  MapMission get _m => _missions[_index];
  Color get _levelColor =>
      _level == 'CE2' ? AppTheme.primaryPurple : AppTheme.primaryBlue;

  List<MapMission> _filtered(List<MapMission> all) {
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
      _filtered(MapMissionsData.forLevel(_level)),
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

  String get _spokenObjective =>
      '${_m.story} Va de ${_m.startLabel} à ${_m.targetLabel}.';

  void _startMission() {
    context.read<GardenService>().rewardMissionStarted();
    context.read<StatsService>().recordStarted(_level, _m.competence);
    setState(() {
      _phase = _Phase.playing;
      _col = _m.start.col;
      _row = _m.start.row;
      _trail
        ..clear()
        ..add(_row * _m.cols + _col);
      _moves = 0;
      _hintsShown = 0;
      _note = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AccessibilitySettingsService>().autoReadEnabled) {
        _speak(_spokenObjective);
      }
    });
  }

  void _move(_Dir d) {
    final nc = _col + d.dCol;
    final nr = _row + d.dRow;

    // Sortir de la carte n'est pas une faute : on le dit, et rien d'autre.
    if (nc < 0 || nc >= _m.cols || nr < 0 || nr >= _m.rows) {
      AppHaptics.light();
      setState(() => _note = 'Tu es au bord de la carte de ce côté.');
      return;
    }

    AppHaptics.selection();
    context.read<AudioService>().onButtonTap();
    setState(() {
      _col = nc;
      _row = nr;
      _moves++;
      _note = null;
      final cell = _row * _m.cols + _col;
      if (!_trail.contains(cell)) _trail.add(cell);
    });

    if (_col == _m.target.col && _row == _m.target.row) {
      _onSuccess();
    }
  }

  void _backToStart() {
    AppHaptics.light();
    setState(() {
      _col = _m.start.col;
      _row = _m.start.row;
      _trail
        ..clear()
        ..add(_row * _m.cols + _col);
      _moves = 0;
      _note = null;
    });
  }

  void _showNextHint() {
    if (_hintsShown >= _m.hints.length) return;
    setState(() => _hintsShown++);
    _speak(_m.hints[_hintsShown - 1]);
  }

  void _onSuccess() {
    final access = context.read<AccessibilitySettingsService>();

    context.read<GardenService>().rewardActivityCompleted();
    context.read<ProgressService>().addPoints('math', 15);
    context.read<StatsService>()
        .recordCompleted(_level, _m.competence, hintsUsed: _hintsShown);

    context.read<AudioService>().onCorrectAnswer();
    AppHaptics.medium();
    if (!access.calmModeEnabled) {
      _confettiKey.currentState?.burst();
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
        title: const Text('🗺️ Carte au trésor'),
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
              child: Text(_m.missionType,
                  style: TextStyle(
                      color: _levelColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 13)),
            ),
            const SizedBox(height: 24),
            const Text('🗺️', style: TextStyle(fontSize: 76)),
            const SizedBox(height: 18),
            Text(_m.story,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, height: 1.5)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _levelColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('${_m.start.emoji}  ${_m.startLabel}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const Icon(Icons.arrow_downward_rounded),
                  Text('${_m.target.emoji}  ${_m.targetLabel}',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: _levelColor)),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
              child: const Text('En route',
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

  // ── 2. La carte ──────────────────────────────────────────
  Widget _buildPlaying() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
                  child: Text('Va jusqu\'à ${_m.target.emoji} ${_m.targetLabel}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w800)),
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
          const SizedBox(height: 12),

          // La rose des vents, seulement en CE2 — et affichée en
          // permanence : on ne demande pas de retenir où est le nord.
          if (_m.cardinal) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _levelColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  Text('N', style: TextStyle(fontWeight: FontWeight.w900)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('O  ', style: TextStyle(fontWeight: FontWeight.w900)),
                      Text('🧭', style: TextStyle(fontSize: 22)),
                      Text('  E', style: TextStyle(fontWeight: FontWeight.w900)),
                    ],
                  ),
                  Text('S', style: TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Le quadrillage
          LayoutBuilder(builder: (context, c) {
            final side = c.maxWidth / _m.cols;
            return Column(
              children: [
                for (var r = 0; r < _m.rows; r++)
                  Row(
                    children: [
                      for (var col = 0; col < _m.cols; col++)
                        _buildCell(col, r, side),
                    ],
                  ),
              ],
            );
          }),
          const SizedBox(height: 12),

          if (_note != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_note!,
                  style: const TextStyle(fontSize: 13, height: 1.4)),
            ),
            const SizedBox(height: 12),
          ],

          // Les commandes
          Column(
            children: [
              _DirButton(
                dir: _Dir.nord,
                cardinal: _m.cardinal,
                color: _levelColor,
                onTap: () => _move(_Dir.nord),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DirButton(
                    dir: _Dir.ouest,
                    cardinal: _m.cardinal,
                    color: _levelColor,
                    onTap: () => _move(_Dir.ouest),
                  ),
                  const SizedBox(width: 60),
                  _DirButton(
                    dir: _Dir.est,
                    cardinal: _m.cardinal,
                    color: _levelColor,
                    onTap: () => _move(_Dir.est),
                  ),
                ],
              ),
              _DirButton(
                dir: _Dir.sud,
                cardinal: _m.cardinal,
                color: _levelColor,
                onTap: () => _move(_Dir.sud),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('$_moves déplacement(s)',
              style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),

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
                child: Text('💡 ${_m.hints[i]}',
                    style: const TextStyle(fontSize: 13, height: 1.4)),
              ),
            ),
          ],

          const SizedBox(height: 12),
          Row(
            children: [
              if (_hintsShown < _m.hints.length)
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
              if (_hintsShown < _m.hints.length) const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _backToStart,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Repartir du début'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCell(int col, int row, double side) {
    final cell = row * _m.cols + col;
    final here = col == _col && row == _row;
    final visited = _trail.contains(cell);

    final place = _m.places
        .where((p) => p.col == col && p.row == row)
        .cast<MapPlace?>()
        .firstWhere((p) => true, orElse: () => null);

    final isTarget = place?.label == _m.targetLabel;

    return SizedBox(
      width: side,
      height: side,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: here
              ? _levelColor.withOpacity(0.30)
              : isTarget
                  ? AppTheme.primaryGreen.withOpacity(0.20)
                  : visited
                      ? _levelColor.withOpacity(0.08)
                      : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: here
                ? _levelColor
                : isTarget
                    ? AppTheme.primaryGreen
                    : Colors.grey.shade300,
            width: here || isTarget ? 3 : 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (place != null)
                Text(place.emoji, style: TextStyle(fontSize: side * 0.32)),
              if (here)
                Text('📍', style: TextStyle(fontSize: side * 0.28)),
            ],
          ),
        ),
      ),
    );
  }

  // ── 3. Arrivée ───────────────────────────────────────────
  Widget _buildSuccess() {
    final calm = context.watch<AccessibilitySettingsService>().calmModeEnabled;
    final direct = _moves == _m.minimumMoves;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(calm ? '⭐' : '🎉', style: const TextStyle(fontSize: 76)),
            const SizedBox(height: 16),
            Text('Tu es arrivée à ${_m.targetLabel} !',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              direct
                  ? 'Tu as pris le chemin le plus court.'
                  : 'Tu es arrivée à bon port. Le chemin compte autant '
                      'que le nombre de pas.',
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

            _ChoiceButton(
              emoji: '▶️',
              label: 'Une autre carte',
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

/// Un bouton de direction : la flèche ET le mot, jamais l'un sans l'autre.
class _DirButton extends StatelessWidget {
  final _Dir dir;
  final bool cardinal;
  final Color color;
  final VoidCallback onTap;

  const _DirButton({
    required this.dir,
    required this.cardinal,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 96,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            children: [
              Text(dir.arrow, style: const TextStyle(fontSize: 24)),
              Text(dir.label(cardinal),
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: color)),
            ],
          ),
        ),
      ),
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
