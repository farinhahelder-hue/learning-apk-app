import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import '../utils/app_theme.dart';

class AvatarScreen extends StatelessWidget {
  const AvatarScreen({super.key});

  static const Map<String, Map<String, dynamic>> _avatars = {
    'avatar_star': {'emoji': '⭐', 'name': 'Emilie Étoile', 'xp': 0},
    'avatar_unicorn': {'emoji': '🦄', 'name': 'Emilie Licorne', 'xp': 100},
    'avatar_rocket': {'emoji': '🚀', 'name': 'Emilie Fusée', 'xp': 300},
    'avatar_crown': {'emoji': '👑', 'name': 'Emilie Reine', 'xp': 600},
    'avatar_dragon': {'emoji': '🐉', 'name': 'Emilie Dragon', 'xp': 1000},
  };

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Avatars 🎞️'),
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
            const Text('Choisis ton avatar !',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Gagne des XP pour débloquer de nouveaux avatars 💫',
                style: TextStyle(color: AppTheme.textGrey)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: _avatars.entries.map((entry) {
                  final unlocked = gs.unlockedAvatars.contains(entry.key);
                  final selected = gs.currentAvatar == entry.key;
                  final info = entry.value;
                  return GestureDetector(
                    onTap: unlocked ? () => gs.changeAvatar(entry.key) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primaryPurple.withOpacity(0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: selected
                              ? AppTheme.primaryPurple
                              : Colors.grey.shade200,
                          width: selected ? 3 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(unlocked ? info['emoji'] as String : '🔒',
                              style: const TextStyle(fontSize: 52)),
                          const SizedBox(height: 8),
                          Text(
                              unlocked
                                  ? info['name'] as String
                                  : '??? ${info['xp']} XP',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: unlocked
                                    ? AppTheme.textDark
                                    : AppTheme.textGrey,
                              ),
                              textAlign: TextAlign.center),
                          if (selected)
                            const Text('✓ Sélectionné',
                                style: TextStyle(
                                    color: AppTheme.primaryPurple,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
