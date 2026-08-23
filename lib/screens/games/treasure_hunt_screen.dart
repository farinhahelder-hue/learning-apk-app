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

/// 🗺️ Chasse au trésor — se repérer sur un plan.
/// L'enfant déplace vraiment son personnage sur une grille avec des
/// flèches, au lieu de choisir une réponse dans une liste.
/// CE1 : rejoindre des lieux familiers. CE2 : points cardinaux et légende.
class TreasureHuntScreen extends StatefulWidget {
  const TreasureHuntScreen({super.key});

  @override
  State<TreasureHuntScreen> createState() => _TreasureHuntScreenState();
}

class _TreasureHuntScreenState extends State<TreasureHuntScreen> {
  late final String _level;
  late final List<MapLandmark> _landmarks;
  late final List<TreasureMission> _missions;

  int _missionIndex = 0;
  int _row = 2, _col = 2; // position de départ : centre du plan
  int _moves = 0;
  final List<String> _collected = [];
  bool _justArrived = false;
  bool _finished = false;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  bool get _isCE2 => _level == 'CE2';

  @override
  void initState() {
    super.initState();
    _level = context.read<GameService>().gradeLevel;
    _landmarks = _isCE2 ? TreasureHuntData.ce2Landmarks : TreasureHuntData.ce1Landmarks;
    // Copie explicite avant mélange : les listes de données sont const.
    // Les repères de la carte, eux, gardent leur ordre — ce sont des
    // positions, pas des questions.
    _missions = List.of(
        _isCE2 ? TreasureHuntData.ce2Missions : TreasureHuntData.ce1Missions)
      ..shuffle();
  }

  TreasureMission get _mission => _missions[_missionIndex];

  void _move(int dRow, int dCol) {
    if (_justArrived || _finished) return;
    final newRow = (_row + dRow).clamp(0, TreasureHuntData.gridSize - 1);
    final newCol = (_col + dCol).clamp(0, TreasureHuntData.gridSize - 1);
    if (newRow == _row && newCol == _col) return; // bord du plan

    AppHaptics.selection();
    context.read<AudioService>().onButtonTap();
    setState(() {
      _row = newRow;
      _col = newCol;
      _moves++;
    });

    if (_row == _mission.targetRow && _col == _mission.targetCol) {
      _onArrived();
    }
  }

  void _onArrived() {
    final calm = context.read<AccessibilitySettingsService>().calmModeEnabled;
    AppHaptics.medium();
    context.read<AudioService>().onCorrectAnswer();
    context.read<ProgressService>().addPoints('game', 10);
    setState(() {
      _justArrived = true;
      _collected.add(_mission.reward);
    });
    if (!calm) _confettiKey.currentState?.burst();

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      if (_missionIndex < _missions.length - 1) {
        setState(() {
          _missionIndex++;
          _justArrived = false;
        });
      } else {
        _finish();
      }
    });
  }

  void _finish() {
    final calm = context.read<AccessibilitySettingsService>().calmModeEnabled;
    context.read<AudioService>().onPerfect();
    context.read<ProgressService>().addPoints('game', 25);
    context.read<GardenService>().rewardActivityCompleted();
    if (!calm) _confettiKey.currentState?.burst(ConfettiType.celebrate);
    setState(() => _finished = true);
  }

  void _restart() {
    setState(() {
      _missionIndex = 0;
      _row = 2; _col = 2;
      _moves = 0;
      _collected.clear();
      _justArrived = false;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = _isCE2 ? AppTheme.primaryPurple : AppTheme.primaryBlue;
    return Scaffold(
      appBar: AppBar(
        title: Text('🗺️ Chasse au trésor'),
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
                decoration: BoxDecoration(
                  color: levelColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Programme $_level',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Consigne
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _justArrived ? const Color(0xFFE8F5E9) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _justArrived ? const Color(0xFF4CAF50) : levelColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text('Mission ${_missionIndex + 1} / ${_missions.length}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textGrey, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  _justArrived ? '🎉 Bravo ! Tu as trouvé ${_mission.reward}' : _mission.instruction,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _justArrived ? const Color(0xFF2E7D32) : AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ).animate(key: ValueKey('$_missionIndex$_justArrived')).fadeIn(duration: 300.ms),

          const SizedBox(height: 8),
          // Boussole (CE2 uniquement)
          if (_isCE2)
            const Text('🧭  N ↑   S ↓   O ←   E →',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textGrey)),
          const SizedBox(height: 12),

          _buildGrid(levelColor),

          const SizedBox(height: 8),
          // Légende
          Wrap(
            spacing: 12, runSpacing: 4,
            alignment: WrapAlignment.center,
            children: _landmarks
                .map((l) => Text('${l.emoji} ${l.name}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)))
                .toList(),
          ),

          const SizedBox(height: 16),
          _buildDPad(levelColor),
          const SizedBox(height: 12),
          if (_collected.isNotEmpty)
            Text('Trésors trouvés : ${_collected.join(' ')}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildGrid(Color levelColor) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8E9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: levelColor.withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: List.generate(TreasureHuntData.gridSize, (r) {
            return Expanded(
              child: Row(
                children: List.generate(TreasureHuntData.gridSize, (c) {
                  final isPlayer = r == _row && c == _col;
                  final isTarget = r == _mission.targetRow && c == _mission.targetCol;
                  MapLandmark? landmark;
                  for (final l in _landmarks) {
                    if (l.row == r && l.col == c) { landmark = l; break; }
                  }
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isTarget && !_justArrived
                            ? AppTheme.primaryYellow.withOpacity(0.35)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isTarget && !_justArrived
                              ? AppTheme.primaryOrange
                              : Colors.grey.shade200,
                          width: isTarget && !_justArrived ? 2 : 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        isPlayer ? '🧒' : (landmark?.emoji ?? (isTarget && !_justArrived ? '❓' : '')),
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDPad(Color levelColor) {
    Widget arrow(IconData icon, int dRow, int dCol, String label) {
      return GestureDetector(
        onTap: () => _move(dRow, dCol),
        child: Container(
          width: 62, height: 62,
          decoration: BoxDecoration(
            color: levelColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: levelColor.withOpacity(0.4), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: levelColor),
              if (_isCE2)
                Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: levelColor)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        arrow(Icons.keyboard_arrow_up_rounded, -1, 0, 'N'),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            arrow(Icons.keyboard_arrow_left_rounded, 0, -1, 'O'),
            const SizedBox(width: 62),
            arrow(Icons.keyboard_arrow_right_rounded, 0, 1, 'E'),
          ],
        ),
        const SizedBox(height: 8),
        arrow(Icons.keyboard_arrow_down_rounded, 1, 0, 'S'),
      ],
    );
  }

  Widget _buildResults(Color levelColor) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            const Text('Carte au trésor complète !',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(_collected.join(' '), style: const TextStyle(fontSize: 34)),
            const SizedBox(height: 12),
            Text('${_missions.length} missions réussies en $_moves déplacements',
                style: const TextStyle(fontSize: 15, color: AppTheme.textGrey),
                textAlign: TextAlign.center),
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
