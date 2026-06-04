import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../services/game_service.dart';
import '../../models/achievement.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('🏆 Mes Achievements'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<GameService>(
        builder: (context, gameService, _) {
          final achievements = gameService.getAchievements();
          final unlocked = achievements.where((a) => a.unlockedAt != null).toList();
          final locked = achievements.where((a) => a.unlockedAt == null).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats
              _buildStatsCard(unlocked.length, achievements.length),
              const SizedBox(height: 24),

              // Unlocked
              if (unlocked.isNotEmpty) ...[
                _buildSectionTitle('✅ Déverrouillés (${unlocked.length})'),
                const SizedBox(height: 12),
                ...unlocked.asMap().entries.map((e) =>
                    _AchievementCard(achievement: e.value, unlocked: true)
                        .animate(delay: (e.key * 80).ms).fadeIn().scale()),
                const SizedBox(height: 24),
              ],

              // Locked
              _buildSectionTitle('🔒 À débloquer (${locked.length})'),
              const SizedBox(height: 12),
              ...locked.asMap().entries.map((e) =>
                  _AchievementCard(achievement: e.value, unlocked: false)
                      .animate(delay: (e.key * 80).ms).fadeIn().scale()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(int unlocked, int total) {
    final percent = total > 0 ? (unlocked / total * 100).round() : 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$unlocked / $total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Achievements complétés',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: unlocked / (total > 0 ? total : 1),
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.amber),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$percent%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool unlocked;

  const _AchievementCard({
    required this.achievement,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: unlocked ? const Color(0xFF2d2d44) : const Color(0xFF1a1a2e),
        borderRadius: BorderRadius.circular(16),
        border: unlocked
            ? Border.all(color: Colors.amber.withOpacity(0.5), width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: unlocked ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                unlocked ? achievement.icon : '❓',
                style: TextStyle(
                  fontSize: unlocked ? 28 : 24,
                  color: unlocked ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: TextStyle(
                    color: unlocked ? Colors.white : Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(unlocked ? 0.7 : 0.4),
                    fontSize: 13,
                  ),
                ),
                if (!unlocked) ...[
                  const SizedBox(height: 6),
                  _buildProgressHint(),
                ],
              ],
            ),
          ),
          // Checkmark
          if (unlocked)
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
        ],
      ),
    );
  }

  Widget _buildProgressHint() {
    String hint = '';
    switch (achievement.type) {
      case 'points':
        hint = 'Gagnez des points dans les exercices';
        break;
      case 'streak':
        hint = 'Jouez plusieurs jours de suite';
        break;
      case 'perfect':
        hint = 'Obtenez 100% à un exercice';
        break;
      case 'combo':
        hint = 'Enchaînez plusieurs bonnes réponses';
        break;
      case 'stars':
        hint = 'Collectez des étoiles';
        break;
    }
    return Row(
      children: [
        const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 14),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            hint,
            style: const TextStyle(color: Colors.amber, fontSize: 11),
          ),
        ),
      ],
    );
  }
}