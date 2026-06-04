import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final worlds = [
      _WorldData(
        id: 'numbers',
        name: 'Royaume des Nombres',
        emoji: '🔢',
        color: AppTheme.mathGradient,
        skills: ['Additions', 'Soustractions', 'Multiplications', 'Divisions', 'Nombres jusqu\'à 1000'],
        totalStars: 15,
        earnedStars: 8,
      ),
      _WorldData(
        id: 'shapes',
        name: 'Forêt des Formes',
        emoji: '🔺',
        color: AppTheme.scienceGradient,
        skills: ['Formes 2D', 'Formes 3D', 'Symétrie', 'Périmètre'],
        totalStars: 12,
        earnedStars: 6,
      ),
      _WorldData(
        id: 'measures',
        name: 'Village des Mesures',
        emoji: '📏',
        color: AppTheme.frenchGradient,
        skills: ['Longueurs', 'Masses', 'Euros', 'Temps'],
        totalStars: 12,
        earnedStars: 3,
        locked: true,
      ),
      _WorldData(
        id: 'reading',
        name: 'Bibliothèque Magique',
        emoji: '📚',
        color: AppTheme.mathGradient,
        skills: ['Lecture simple', 'Compréhension', 'Poésie'],
        totalStars: 9,
        earnedStars: 9,
      ),
      _WorldData(
        id: 'spelling',
        name: 'Château de l\'Orthographe',
        emoji: '✏️',
        color: AppTheme.frenchGradient,
        skills: ['Mots CE1', 'Accents', 'Homophones', 'Pluriel'],
        totalStars: 12,
        earnedStars: 4,
      ),
      _WorldData(
        id: 'grammar',
        name: 'Tour de la Grammaire',
        emoji: '📝',
        color: AppTheme.scienceGradient,
        skills: ['Phrase', 'GN/GV', 'Adjectifs', 'Accord S-V'],
        totalStars: 12,
        earnedStars: 0,
        locked: true,
      ),
      _WorldData(
        id: 'conjugation',
        name: 'Labo de Conjugaison',
        emoji: '🔁',
        color: AppTheme.mathGradient,
        skills: ['Présent', 'Passé composé', 'Futur', 'Imparfait'],
        totalStars: 12,
        earnedStars: 0,
        locked: true,
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        '🗺️ Carte des Mondes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Total Stars
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      '${worlds.fold(0, (sum, w) => sum + w.earnedStars)} / ${worlds.fold(0, (sum, w) => sum + w.totalStars)} étoiles',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),
              // Worlds Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: worlds.length,
                  itemBuilder: (context, index) {
                    final world = worlds[index];
                    return _WorldCard(world: world)
                        .animate(delay: (index * 100).ms)
                        .fadeIn()
                        .scale(begin: const Offset(0.8, 0.8));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorldData {
  final String id;
  final String name;
  final String emoji;
  final Gradient color;
  final List<String> skills;
  final int totalStars;
  final int earnedStars;
  final bool locked;

  _WorldData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.skills,
    required this.totalStars,
    required this.earnedStars,
    this.locked = false,
  });
}

class _WorldCard extends StatelessWidget {
  final _WorldData world;

  const _WorldCard({required this.world});

  @override
  Widget build(BuildContext context) {
    final progress = world.totalStars > 0
        ? world.earnedStars / world.totalStars
        : 0.0;

    return GestureDetector(
      onTap: world.locked
          ? () => _showLockedDialog(context)
          : () => _navigateToSkills(context),
      child: Container(
        decoration: BoxDecoration(
          gradient: world.locked ? null : world.color,
          color: world.locked ? Colors.grey.shade400 : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Emoji
                  Text(
                    world.locked ? '🔒' : world.emoji,
                    style: const TextStyle(fontSize: 36),
                  ),
                  const SizedBox(height: 8),
                  // Name
                  Text(
                    world.name,
                    style: TextStyle(
                      color: world.locked ? Colors.white70 : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Stars
                  Row(
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '${world.earnedStars}/${world.totalStars}',
                        style: TextStyle(
                          color: world.locked ? Colors.white54 : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation(Colors.amber),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            if (world.locked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🔒', style: TextStyle(fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🔒', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            const Text('Monde verrouillé'),
          ],
        ),
        content: Text(
          'Termine d\'explorer les mondes précédents pour débloquer "${world.name}" !',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToSkills(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SkillListScreen(world: world),
      ),
    );
  }
}

class _SkillListScreen extends StatelessWidget {
  final _WorldData world;

  const _SkillListScreen({required this.world});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${world.emoji} ${world.name}'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: world.skills.length,
        itemBuilder: (context, index) {
          final skill = world.skills[index];
          final earned = index < 2;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: earned ? Colors.green.shade100 : Colors.grey.shade200,
                child: earned
                    ? const Text('⭐', style: TextStyle(fontSize: 20))
                    : const Text('🔒', style: TextStyle(fontSize: 16)),
              ),
              title: Text(
                skill,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: earned ? AppTheme.textDark : Colors.grey,
                ),
              ),
              subtitle: Text(
                earned ? '⭐⭐⭐ Complété !' : 'Non commencé',
                style: TextStyle(
                  color: earned ? Colors.green : Colors.grey,
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(Icons.play_arrow, color: AppTheme.primaryBlue),
              onTap: earned
                  ? () {
                      // TODO: Navigate to arcade game for this skill
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lancement de "$skill" 🎮')),
                      );
                    }
                  : null,
            ),
          ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: -0.1);
        },
      ),
    );
  }
}