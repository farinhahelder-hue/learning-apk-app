import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/mascot.dart';
import '../../services/audio_service.dart';
import '../../services/progress_service.dart';
import '../../services/accessibility_settings_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/confetti_overlay.dart';

/// Jeu de mémoire : retrouver les paires de mascottes.
/// Jamais de pénalité sur une paire ratée — juste on réessaie.
class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _Card {
  final Mascot mascot;
  bool flipped = false;
  bool matched = false;
  _Card(this.mascot);
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  static const _pairCount = 6;
  late List<_Card> _cards;
  int? _firstIndex;
  bool _busy = false;
  int _attempts = 0;
  int _matches = 0;
  bool _finished = false;
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    final mascots = Mascots.all.take(_pairCount).toList();
    final pairs = [...mascots, ...mascots];
    pairs.shuffle();
    _cards = pairs.map((m) => _Card(m)).toList();
    _firstIndex = null;
    _busy = false;
    _attempts = 0;
    _matches = 0;
    _finished = false;
  }

  void _onTapCard(int index) {
    if (_busy || _cards[index].flipped || _cards[index].matched || _finished) return;

    setState(() => _cards[index].flipped = true);

    if (_firstIndex == null) {
      _firstIndex = index;
      return;
    }

    _attempts++;
    final first = _firstIndex!;
    _firstIndex = null;
    _busy = true;

    final isMatch = _cards[first].mascot.id == _cards[index].mascot.id;
    final audio = context.read<AudioService>();

    if (isMatch) {
      setState(() {
        _cards[first].matched = true;
        _cards[index].matched = true;
        _matches++;
        _busy = false;
      });
      audio.onCorrectAnswer();
      if (_matches == _pairCount) {
        _finishGame();
      }
    } else {
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          _cards[first].flipped = false;
          _cards[index].flipped = false;
          _busy = false;
        });
      });
    }
  }

  void _finishGame() {
    final calm = context.read<AccessibilitySettingsService>().calmModeEnabled;
    final stars = _attempts <= 8 ? 3 : (_attempts <= 12 ? 2 : 1);
    context.read<ProgressService>().addPoints('game', stars * 15);
    final audio = context.read<AudioService>();
    audio.onPerfect();
    if (!calm) _confettiKey.currentState?.burst(ConfettiType.celebrate);
    setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 Jeu de mémoire'),
        backgroundColor: AppTheme.primaryPurple.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text('$_matches / $_pairCount paires',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_finished) _buildResults() else _buildGrid(),
          ConfettiOverlay(key: _confettiKey),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, i) {
          final card = _cards[i];
          final showFace = card.flipped || card.matched;
          return GestureDetector(
            onTap: () => _onTapCard(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: showFace
                    ? card.mascot.color.withOpacity(card.matched ? 0.25 : 0.2)
                    : AppTheme.primaryPurple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: card.matched
                      ? const Color(0xFF81C784)
                      : AppTheme.primaryPurple.withOpacity(0.3),
                  width: card.matched ? 3 : 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                showFace ? card.mascot.emoji : '❔',
                style: const TextStyle(fontSize: 34),
              ),
            ),
          ).animate(target: card.matched ? 1 : 0).scale(
              begin: const Offset(1, 1), end: const Offset(1.08, 1.08));
        },
      ),
    );
  }

  Widget _buildResults() {
    final stars = _attempts <= 8 ? 3 : (_attempts <= 12 ? 2 : 1);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 16),
            Text('Bravo Emilie !',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (s) => Icon(
                s < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                color: s < stars ? Colors.amber : Colors.grey.shade300,
                size: 44,
              )),
            ),
            const SizedBox(height: 12),
            Text('Toutes les paires trouvées en $_attempts essais !',
                style: const TextStyle(fontSize: 16, color: AppTheme.textGrey)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => setState(_newGame),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPurple),
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
