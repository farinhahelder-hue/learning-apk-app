import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../services/game_service.dart';
import '../../utils/app_theme.dart';
import 'memory_match_screen.dart';
import 'sequence_game_screen.dart';
import 'question_rain_screen.dart';
import 'flash_quiz_screen.dart';
import 'dictee_image_screen.dart';
import 'number_bars_screen.dart';
import 'sentence_workshop_screen.dart';
import 'treasure_hunt_screen.dart';
import 'time_travel_screen.dart';
import 'weather_express_screen.dart';

/// Menu des mini-jeux : des activités amusantes et rejouables, sans pression
/// de temps par défaut, pour varier le "jouer et apprendre".
/// Les jeux liés au programme suivent le niveau choisi (CE1 ou CE2).
class MiniGamesMenuScreen extends StatelessWidget {
  const MiniGamesMenuScreen({super.key});

  /// Couleur d'identité du niveau : bleu pour le CE1, violet pour le CE2.
  static Color levelColor(String level) =>
      level == 'CE2' ? AppTheme.primaryPurple : AppTheme.primaryBlue;

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameService>();
    final lvColor = levelColor(gs.gradeLevel);

    // Jeux qui suivent le programme scolaire (contenu distinct CE1/CE2)
    final programGames = [
      {
        'title': 'Barres de nombres', 'emoji': '🔢',
        'subtitle': 'Construis les nombres avec des objets',
        'color': const Color(0xFF42A5F5),
        'builder': (BuildContext c) => const NumberBarsScreen(),
      },
      {
        'title': 'Dictée image', 'emoji': '🖼️',
        'subtitle': 'Écoute un mot et écris-le avec des lettres',
        'color': const Color(0xFFEC407A),
        'builder': (BuildContext c) => const DicteeImageScreen(),
      },
      {
        'title': 'Chantier des phrases', 'emoji': '🧱',
        'subtitle': 'Construis, repère et accorde les mots',
        'color': const Color(0xFF7E57C2),
        'builder': (BuildContext c) => const SentenceWorkshopScreen(),
      },
      {
        'title': 'Chasse au trésor', 'emoji': '🗺️',
        'subtitle': 'Repère-toi sur le plan et trouve le trésor',
        'color': const Color(0xFF26A69A),
        'builder': (BuildContext c) => const TreasureHuntScreen(),
      },
      {
        'title': 'Voyage dans le temps', 'emoji': '⏳',
        'subtitle': 'Remets la frise dans le bon ordre',
        'color': const Color(0xFF8D6E63),
        'builder': (BuildContext c) => const TimeTravelScreen(),
      },
      {
        'title': 'Météo Express', 'emoji': '🌦️',
        'subtitle': 'Deviens présentatrice météo',
        'color': const Color(0xFF29B6F6),
        'builder': (BuildContext c) => const WeatherExpressScreen(),
      },
      {
        'title': 'Pluie de Questions', 'emoji': '🌧️',
        'subtitle': 'Enchaîne les questions du programme, sans fin',
        'color': AppTheme.primaryBlue,
        'builder': (BuildContext c) => const QuestionRainScreen(),
      },
      {
        'title': 'Quiz Éclair', 'emoji': '⚡',
        'subtitle': '10 questions du programme, résultat en étoiles',
        'color': const Color(0xFFFFA000),
        'builder': (BuildContext c) => const FlashQuizScreen(),
      },
    ];

    // Jeux d'entraînement du cerveau, sans lien avec un niveau scolaire
    final funGames = [
      {
        'title': 'Jeu de mémoire', 'emoji': '🧠',
        'subtitle': 'Retrouve les paires de mascottes',
        'color': AppTheme.primaryPurple,
        'builder': (BuildContext c) => const MemoryMatchScreen(),
      },
      {
        'title': 'Séquence Motifs', 'emoji': '🎵',
        'subtitle': 'Répète la séquence de couleurs',
        'color': AppTheme.primaryGreen,
        'builder': (BuildContext c) => const SequenceGameScreen(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎮 Mini-jeux'),
        backgroundColor: lvColor.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Choix du niveau, bien visible ──
          const Text('Je joue en...',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800))
              .animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _LevelButton(
                  label: 'CE1',
                  color: AppTheme.primaryBlue,
                  selected: gs.gradeLevel == 'CE1',
                  onTap: () => gs.setGradeLevel('CE1'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LevelButton(
                  label: 'CE2',
                  color: AppTheme.primaryPurple,
                  selected: gs.gradeLevel == 'CE2',
                  onTap: () => gs.setGradeLevel('CE2'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Jeux du programme ──
          Row(
            children: [
              const Text('Jeux du programme',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: lvColor, borderRadius: BorderRadius.circular(12)),
                child: Text('Programme ${gs.gradeLevel}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...programGames.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _GameCard(game: e.value, index: e.key),
              )),

          const SizedBox(height: 12),
          const Text('Jeux pour s\'amuser',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Ces jeux sont les mêmes en CE1 et en CE2',
              style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
          const SizedBox(height: 12),
          ...funGames.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _GameCard(game: e.value, index: e.key),
              )),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final Map<String, dynamic> game;
  final int index;
  const _GameCard({required this.game, required this.index});

  @override
  Widget build(BuildContext context) {
    final color = game['color'] as Color;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: game['builder'] as WidgetBuilder),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Text(game['emoji'] as String, style: const TextStyle(fontSize: 38)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(game['title'] as String,
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: color)),
                  const SizedBox(height: 2),
                  Text(game['subtitle'] as String,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: 60 * index)).fadeIn().slideX(begin: 0.15);
  }
}

/// Gros bouton de choix de niveau — bleu pour le CE1, violet pour le CE2.
class _LevelButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _LevelButton({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? color : Colors.grey.shade300, width: 2.5),
          boxShadow: selected
              ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 5))]
              : [],
        ),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: selected ? Colors.white : AppTheme.textGrey,
                )),
            const SizedBox(height: 2),
            Text(selected ? '✓ niveau choisi' : 'toucher pour choisir',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white.withOpacity(0.9) : Colors.grey.shade400,
                )),
          ],
        ),
      ),
    );
  }
}
