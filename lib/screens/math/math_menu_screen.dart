import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';
import 'math_exercise_screen.dart';

class MathMenuScreen extends StatelessWidget {
  const MathMenuScreen({super.key});

  static const List<Map<String, dynamic>> _categories = [
    {
      'title': 'Additions',
      'emoji': '➕',
      'category': 'addition',
      'color': Color(0xFF4FC3F7)
    },
    {
      'title': 'Soustractions',
      'emoji': '➖',
      'category': 'subtraction',
      'color': Color(0xFF29B6F6)
    },
    {
      'title': 'Multiplications',
      'emoji': '✖️',
      'category': 'multiplication',
      'color': Color(0xFF0288D1)
    },
    {
      'title': 'Géométrie',
      'emoji': '🔺',
      'category': 'geometry',
      'color': Color(0xFF0277BD)
    },
    {
      'title': 'Logique & Mesures',
      'emoji': '🧩',
      'category': 'logic',
      'color': Color(0xFF01579B)
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mathématiques 🔢'),
        backgroundColor: AppTheme.mathColor.withOpacity(0.15),
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
            const Text(
              'Choisis un exercice !',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MathExerciseScreen(
                          category: cat['category'] as String,
                          title: cat['title'] as String,
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: (cat['color'] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: (cat['color'] as Color).withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(cat['emoji'] as String,
                              style: const TextStyle(fontSize: 36)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              cat['title'] as String,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: cat['color'] as Color,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              color: cat['color'] as Color, size: 18),
                        ],
                      ),
                    ),
                  )
                      .animate(delay: Duration(milliseconds: 100 * i))
                      .fadeIn()
                      .slideX(begin: 0.2);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
