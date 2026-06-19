import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

// 🏋️ Pause active - hybridation monde réel / numérique
// Déclenché après 15 minutes d'écran
class ActiveBreakScreen extends StatefulWidget {
  final VoidCallback onBreakDone;
  const ActiveBreakScreen({super.key, required this.onBreakDone});
  @override
  State<ActiveBreakScreen> createState() => _ActiveBreakScreenState();
}

class _ActiveBreakScreenState extends State<ActiveBreakScreen> {
  int _currentActivity = 0;
  int _countdown = 5; // secondes à attendre avant de pouvoir passer
  Timer? _timer;
  bool _canContinue = false;

  static const List<Map<String, dynamic>> _activities = [
    {
      'emoji': '👀',
      'title': 'Repos des yeux',
      'instruction':
          'Regarde au loin à travers la fenêtre pendant 20 secondes.\nLaisse tes yeux se reposer de l’écran.',
      'duration': 20,
      'color': 0xFF4FC3F7,
    },
    {
      'emoji': '🤸',
      'title': 'Sauts de kangourou !',
      'instruction':
          'Fais 10 sauts sur place !\n1, 2, 3... allez, tu peux le faire !',
      'duration': 15,
      'color': 0xFF81C784,
    },
    {
      'emoji': '🌊',
      'title': 'Respiration magique',
      'instruction':
          'Inspire lentement (4 secondes)...\nBloque (2 secondes)...\nExpire doucement (4 secondes).\nRecommence 3 fois.',
      'duration': 30,
      'color': 0xFFBA68C8,
    },
    {
      'emoji': '🔎',
      'title': 'Mission géométrie !',
      'instruction':
          'Va dans ta chambre et trouve :\n■ Un objet carré\n▲ Un objet triangulaire\n● Un objet rond',
      'duration': 45,
      'color': 0xFFFFB74D,
    },
    {
      'emoji': '💃',
      'title': 'La danse des lettres !',
      'instruction':
          'Danse et épelle ton prénom lettre par lettre !\nE - M - I - L - I - E !',
      'duration': 20,
      'color': 0xFFFF80AB,
    },
    {
      'emoji': '🧘',
      'title': 'Yoga du lion',
      'instruction':
          'Assieds-toi, inspire profondément...\nPuis ouvre grand la bouche et tire la langue comme un lion !\nROAAAAR ! Fais-le 5 fois.',
      'duration': 25,
      'color': 0xFFFF7043,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    final activity = _activities[_currentActivity];
    _countdown = activity['duration'] as int;
    _canContinue = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        t.cancel();
        setState(() {
          _countdown = 0;
          _canContinue = true;
        });
      }
    });
  }

  void _nextActivity() {
    if (_currentActivity < _activities.length - 1) {
      setState(() {
        _currentActivity++;
      });
      _startCountdown();
    } else {
      widget.onBreakDone();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final act = _activities[_currentActivity];
    final color = Color(act['color'] as int);
    final isLast = _currentActivity == _activities.length - 1;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.3), color.withOpacity(0.6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⏰ Pause Active !',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70)),
                const SizedBox(height: 8),
                const Text('Bravo ! C’est l’heure de bouger !',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                    textAlign: TextAlign.center),
                const SizedBox(height: 28),
                Text(act['emoji'] as String,
                        style: const TextStyle(fontSize: 100))
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 16),
                Text(act['title'] as String,
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(act['instruction'] as String,
                      style: const TextStyle(
                          fontSize: 17, color: Colors.white, height: 1.6),
                      textAlign: TextAlign.center),
                ),
                const SizedBox(height: 24),
                // Compte à rebours
                Text(
                  _canContinue ? '✅ C’est fait !' : '⏱ $_countdown s',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: _canContinue ? Colors.greenAccent : Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                if (_canContinue)
                  ElevatedButton(
                    onPressed: _nextActivity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: color,
                      minimumSize: const Size(200, 56),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      isLast ? '🚀 Retour au jeu !' : 'Activité suivante ➡',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                // Progression activités
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                      _activities.length,
                      (i) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: i == _currentActivity ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i <= _currentActivity
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
