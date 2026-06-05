import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/mascot.dart';
import '../../utils/app_theme.dart';
import 'french_exercise_screen.dart';

class FrenchMenuScreen extends StatelessWidget {
  const FrenchMenuScreen({super.key});

  static const List<Map<String, dynamic>> _categories = [
    {'title': 'Ecriture',       'emoji': '✏️', 'category': 'ecriture',      'color': Color(0xFF6BB9F0), 'mascot': Mascot.seal},
    {'title': 'Lecture',        'emoji': '📖', 'category': 'lecture',       'color': Color(0xFFFF80AB), 'mascot': Mascot.seal},
    {'title': 'Completrer',    'emoji': '🔤', 'category': 'complet',      'color': Color(0xFFD4956A), 'mascot': Mascot.squirrel},
    {'title': 'Orthographe',    'emoji': '🔠', 'category': 'orthographe',  'color': Color(0xFFEC407A), 'mascot': Mascot.seal},
    {'title': 'Conjugaison',    'emoji': '🔁', 'category': 'conjugaison',   'color': Color(0xFFE91E63), 'mascot': Mascot.squirrel},
    {'title': 'Phonetique',     'emoji': '🎤', 'category': 'phonetique',   'color': Color(0xFFB966D9), 'mascot': Mascot.jellyfish},
    {'title': 'Vocabulaire',    'emoji': '💬', 'category': 'vocabulaire',  'color': Color(0xFFC2185B), 'mascot': Mascot.jellyfish},
    {'title': 'Grammaire',      'emoji': '📝', 'category': 'grammaire',    'color': Color(0xFF880E4F), 'mascot': Mascot.seal},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Francais 📚'),
        backgroundColor: AppTheme.frenchColor.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Show mascots at top
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < Mascot.all.length; i++)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Mascot.all[i].color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(Mascot.all[i].emoji, style: const TextStyle(fontSize: 32)),
                  ).animate(delay: (i * 200).ms)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveY(begin: 0, end: -8, duration: 1.seconds),
              ],
            ),
          ).animate().fadeIn(),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('Choisis un exercice !',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.pink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('🦭  🐿️  🎐', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final catMascot = cat['mascot'] as Mascot;
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FrenchExerciseScreen(
                        category: cat['category'] as String,
                        title: cat['title'] as String,
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [(cat['color'] as Color).withOpacity(0.2), (cat['color'] as Color).withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: (cat['color'] as Color).withOpacity(0.4), width: 2),
                      boxShadow: [
                        BoxShadow(color: (cat['color'] as Color).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(cat['emoji'] as String, style: const TextStyle(fontSize: 40)),
                        const SizedBox(height: 8),
                        Text(cat['title'] as String,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cat['color'] as Color)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: catMascot.color.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(catMascot.name, style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: Duration(milliseconds: 100 * i))
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.8, 0.8));
              },
            ),
          ),
        ],
      ),
    );
  }
}
