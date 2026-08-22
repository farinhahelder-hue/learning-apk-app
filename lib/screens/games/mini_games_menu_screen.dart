import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';
import 'memory_match_screen.dart';
import 'sequence_game_screen.dart';

/// Menu des mini-jeux : des activités amusantes et rejouables, sans pression
/// de temps par défaut, pour varier le "jouer et apprendre".
class MiniGamesMenuScreen extends StatelessWidget {
  const MiniGamesMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      {
        'title': 'Jeu de mémoire', 'emoji': '🧠',
        'subtitle': 'Retrouve les paires de mascottes',
        'color': AppTheme.primaryPurple,
        'builder': (BuildContext c) => const MemoryMatchScreen(),
      },
      {
        'title': 'Séquence Motifs', 'emoji': '🎵',
        'subtitle': 'Répète la séquence de couleurs',
        'color': AppTheme.primaryBlue,
        'builder': (BuildContext c) => const SequenceGameScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 Mini-jeux'),
        backgroundColor: AppTheme.primaryPurple.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choisis un jeu !',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700))
                .animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: games.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final g = games[i];
                  final color = g['color'] as Color;
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: g['builder'] as WidgetBuilder,
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          Text(g['emoji'] as String, style: const TextStyle(fontSize: 40)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(g['title'] as String,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
                                const SizedBox(height: 2),
                                Text(g['subtitle'] as String,
                                    style: const TextStyle(fontSize: 13, color: AppTheme.textGrey)),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: color, size: 18),
                        ],
                      ),
                    ),
                  ).animate(delay: Duration(milliseconds: 100 * i)).fadeIn().slideX(begin: 0.2);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
