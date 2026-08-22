import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/audio_service.dart';
import '../../services/progress_service.dart';
import '../../utils/app_theme.dart';

/// Jeu de séquence façon "Simon" : répéter une séquence de couleurs qui
/// s'allonge à chaque tour. Pas de chronomètre, pas de son d'erreur — en cas
/// de faux pas, on recommence gentiment, le meilleur score reste affiché.
class SequenceGameScreen extends StatefulWidget {
  const SequenceGameScreen({super.key});

  @override
  State<SequenceGameScreen> createState() => _SequenceGameScreenState();
}

class _SequenceGameScreenState extends State<SequenceGameScreen> {
  static const _colors = [
    AppTheme.primaryBlue,
    AppTheme.primaryPink,
    AppTheme.primaryYellow,
    AppTheme.primaryGreen,
  ];
  static const _emojis = ['🔵', '💗', '⭐', '🍀'];
  static const _startLength = 3;

  final _rand = Random();
  List<int> _sequence = [];
  int _playerStep = 0;
  int _bestLength = 0;
  int _activeButton = -1;
  bool _accepting = false;
  bool _isPlaying = false;
  String _message = 'Regarde bien la séquence...';

  @override
  void initState() {
    super.initState();
    _startRound(fresh: true);
  }

  void _startRound({required bool fresh}) {
    if (fresh) {
      _sequence = List.generate(_startLength, (_) => _rand.nextInt(4));
    }
    _playerStep = 0;
    _accepting = false;
    setState(() => _message = 'Regarde bien la séquence...');
    _playSequence();
  }

  Future<void> _playSequence() async {
    setState(() => _isPlaying = true);
    await Future.delayed(const Duration(milliseconds: 400));
    for (final i in _sequence) {
      if (!mounted) return;
      setState(() => _activeButton = i);
      context.read<AudioService>().onButtonTap();
      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      setState(() => _activeButton = -1);
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (!mounted) return;
    setState(() {
      _isPlaying = false;
      _accepting = true;
      _message = 'À toi de jouer !';
    });
  }

  void _onTapButton(int i) {
    if (!_accepting || _isPlaying) return;

    setState(() => _activeButton = i);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _activeButton = -1);
    });

    if (_sequence[_playerStep] == i) {
      context.read<AudioService>().onButtonTap();
      _playerStep++;
      if (_playerStep == _sequence.length) {
        _accepting = false;
        if (_sequence.length > _bestLength) _bestLength = _sequence.length;
        context.read<AudioService>().onStarEarned();
        context.read<ProgressService>().addPoints('game', 10);
        setState(() => _message = 'Bravo ! Séquence suivante...');
        Future.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          setState(() => _sequence = [..._sequence, _rand.nextInt(4)]);
          _startRound(fresh: false);
        });
      }
    } else {
      _accepting = false;
      setState(() => _message = 'On recommence en douceur ! 🌈');
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        _startRound(fresh: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎵 Séquence Motifs'),
        backgroundColor: AppTheme.primaryBlue.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text('Meilleure séquence : $_bestLength',
                style: const TextStyle(fontSize: 16, color: AppTheme.textGrey, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(_message,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center)
                .animate(key: ValueKey(_message)).fadeIn(duration: 300.ms),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: List.generate(4, (i) {
                  final active = _activeButton == i;
                  return GestureDetector(
                    onTap: () => _onTapButton(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: active ? _colors[i] : _colors[i].withOpacity(0.35),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: active
                            ? [BoxShadow(color: _colors[i].withOpacity(0.6), blurRadius: 20, spreadRadius: 2)]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(_emojis[i], style: const TextStyle(fontSize: 48)),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
