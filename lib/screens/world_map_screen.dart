import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/game_service.dart';
import '../utils/curriculum.dart';
import '../utils/app_theme.dart';
import 'skill_screen.dart';

class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('🗺️ Carte du Monde'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.homeGradient),
        child: Column(
          children: [
            // Barre XP globale
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Niveau ${gs.level} 👑',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      Text('${gs.xp} XP',
                          style: const TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: gs.xpProgress,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade200,
                      color: AppTheme.primaryYellow,
                    ),
                  ),
                ],
              ),
            ),
            // Sélecteur de niveau : CE1 et CE2 sont bien séparés partout
            // (bleu = CE1, violet = CE2, même code couleur dans toute l'app)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _LevelChip(
                      label: 'Je joue en CE1',
                      color: AppTheme.primaryBlue,
                      selected: gs.gradeLevel == 'CE1',
                      onTap: () => gs.setGradeLevel('CE1'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _LevelChip(
                      label: 'Je joue en CE2',
                      color: AppTheme.primaryPurple,
                      selected: gs.gradeLevel == 'CE2',
                      onTap: () => gs.setGradeLevel('CE2'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: Curriculum.worlds.length,
                itemBuilder: (context, i) {
                  final world = Curriculum.worlds[i];
                  final color = Color(world['color'] as int);
                  final allSkills = world['skills'] as List<Map<String, dynamic>>;
                  final skills = allSkills.where((s) => s['level'] == gs.gradeLevel).toList();
                  final totalStars = skills.length * 3;
                  final earnedStars = skills.fold<int>(
                      0, (sum, s) => sum + gs.getSkillStars(world['id'] as String, s['id'] as String));

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SkillScreen(world: world),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color.withOpacity(0.8), color],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: color.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 6)),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(world['emoji'] as String, style: const TextStyle(fontSize: 42)),
                          const Spacer(),
                          Text(world['title'] as String,
                              style: const TextStyle(
                                color: Colors.white, fontSize: 15,
                                fontWeight: FontWeight.w800,
                              )),
                          const SizedBox(height: 6),
                          Row(
                            children: List.generate(3, (s) => Icon(
                              s < (totalStars == 0 ? 0 : earnedStars * 3 / totalStars).round()
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: Colors.yellow.shade200,
                              size: 18,
                            )),
                          ),
                          Text('$earnedStars/$totalStars ⭐',
                              style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                        ],
                      ),
                    ),
                  ).animate(delay: Duration(milliseconds: 80 * i)).fadeIn().scale(begin: const Offset(0.9, 0.9));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _LevelChip({
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: 2.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: selected ? Colors.white : AppTheme.textGrey,
          ),
        ),
      ),
    );
  }
}
