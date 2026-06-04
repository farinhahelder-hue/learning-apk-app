import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';
import 'science_exercise_screen.dart';

class ScienceMenuScreen extends StatelessWidget {
  const ScienceMenuScreen({super.key});

  static const List<Map<String, dynamic>> _categories = [
    {'title': 'Les animaux',   'emoji': '🐾', 'category': 'animaux',     'color': Color(0xFF81C784)},
    {'title': 'Corps humain',  'emoji': '🦴', 'category': 'corps',       'color': Color(0xFF4CAF50)},
    {'title': 'La nature',     'emoji': '🌿', 'category': 'nature',      'color': Color(0xFF388E3C)},
    {'title': 'Météo & saisons','emoji': '☀️', 'category': 'meteo',       'color': Color(0xFF2E7D32)},
    {'title': 'Les plantes',   'emoji': '🌱', 'category': 'plantes',     'color': Color(0xFF1B5E20)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sciences 🔬'),
        backgroundColor: AppTheme.scienceColor.withOpacity(0.15),
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
            const Text('Choisis un exercice !',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700))
                .animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ScienceExerciseScreen(
                        category: cat['category'] as String, title: cat['title'] as String))),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: (cat['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: (cat['color'] as Color).withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          Text(cat['emoji'] as String, style: const TextStyle(fontSize: 36)),
                          const SizedBox(width: 16),
                          Expanded(child: Text(cat['title'] as String,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cat['color'] as Color))),
                          Icon(Icons.arrow_forward_ios, color: cat['color'] as Color, size: 18),
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
