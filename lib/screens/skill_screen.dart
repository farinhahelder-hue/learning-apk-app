import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/game_service.dart';
import '../utils/app_theme.dart';
import 'arcade_game_screen.dart';

class SkillScreen extends StatelessWidget {
  final Map<String, dynamic> world;
  const SkillScreen({super.key, required this.world});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameService>();
    final skills = world['skills'] as List<Map<String, dynamic>>;
    final worldId = world['id'] as String;
    final color = Color(world['color'] as int);

    return Scaffold(
      appBar: AppBar(
        title: Text('${world['emoji']} ${world['title']}'),
        backgroundColor: color.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: skills.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final skill = skills[i];
          final skillId = skill['id'] as String;
          final stars = gs.getSkillStars(worldId, skillId);
          final wp = gs.getWorldProgress(worldId);
          final unlocked = wp.isSkillUnlocked(skillId, skills);
          final levelTag = skill['level'] as String;

          return GestureDetector(
            onTap: unlocked
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ArcadeGameScreen(
                          worldId: worldId,
                          skillId: skillId,
                          skillLabel: skill['label'] as String,
                          subject: world['subject'] as String,
                          color: color,
                        ),
                      ),
                    )
                : null,
            child: AnimatedOpacity(
              opacity: unlocked ? 1.0 : 0.45,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: stars > 0 ? color.withOpacity(0.5) : Colors.grey.shade200,
                    width: stars > 0 ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: unlocked ? color.withOpacity(0.15) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(unlocked ? '📍' : '🔒',
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(skill['label'] as String,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: levelTag == 'CE1' ? AppTheme.primaryBlue.withOpacity(0.15)
                                      : AppTheme.primaryPink.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(levelTag,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: levelTag == 'CE1' ? AppTheme.primaryBlue : AppTheme.primaryPink,
                                    )),
                              ),
                              const SizedBox(width: 8),
                              Text(skill['period'] as String,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Étoiles
                    Row(children: List.generate(3, (s) => Icon(
                      s < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: s < stars ? Colors.amber : Colors.grey.shade300,
                      size: 20,
                    ))),
                  ],
                ),
              ),
            ),
          ).animate(delay: Duration(milliseconds: 60 * i)).fadeIn().slideX(begin: 0.15);
        },
      ),
    );
  }
}
