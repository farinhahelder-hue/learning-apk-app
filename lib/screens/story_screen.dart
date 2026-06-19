import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/story.dart';
import '../services/game_service.dart';
import '../utils/app_theme.dart';
import 'world_map_screen.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});
  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  int _currentChapterIndex = 0;
  bool _showingReward = false;

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameService>();
    // Calcul étoiles totales approximatif
    int totalStars = 0;
    gs.worldsProgress.forEach((_, wp) => totalStars += wp.totalStars);

    final current = Story.currentChapter(totalStars);
    final next = Story.nextChapter(totalStars);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📜 Aventure d’Emilie'),
        backgroundColor: AppTheme.primaryPurple.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.homeGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Chapitre actuel
              if (current != null)
                _ChapterCard(
                  chapter: current,
                  isActive: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WorldMapScreen()),
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1),

              const SizedBox(height: 20),

              // Prochain objectif
              if (next != null)
                _NextChapterTeaser(
                  chapter: next,
                  starsNeeded: next.requiredStars - totalStars,
                ).animate(delay: 300.ms).fadeIn(),

              const SizedBox(height: 20),

              // Timeline de l'aventure
              const Text('📜 Ton aventure',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              ...Story.chapters.asMap().entries.map((e) {
                final ch = e.value;
                final unlocked = totalStars >= ch.requiredStars;
                return _TimelineItem(
                  chapter: ch,
                  unlocked: unlocked,
                  isCurrent: current?.id == ch.id,
                )
                    .animate(delay: Duration(milliseconds: 100 * e.key))
                    .fadeIn()
                    .slideX(begin: 0.1);
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final StoryChapter chapter;
  final bool isActive;
  final VoidCallback onTap;
  const _ChapterCard(
      {required this.chapter, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
                color: Colors.purple.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(chapter.emoji, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mission en cours 🟣',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    Text(chapter.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                  ],
                )),
              ],
            ),
            const SizedBox(height: 16),
            Text(chapter.narrative,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.5)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('🚀 Jouer cette mission !',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextChapterTeaser extends StatelessWidget {
  final StoryChapter chapter;
  final int starsNeeded;
  const _NextChapterTeaser({required this.chapter, required this.starsNeeded});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(chapter.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Prochaine mission 🔒',
                    style: TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
                Text(chapter.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text('🔒 Encore $starsNeeded ⭐ pour débloquer',
                    style: const TextStyle(
                        color: AppTheme.primaryPink, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final StoryChapter chapter;
  final bool unlocked;
  final bool isCurrent;
  const _TimelineItem(
      {required this.chapter, required this.unlocked, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: unlocked ? AppTheme.primaryBlue : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(unlocked ? '✅' : '🔒',
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
            Container(width: 2, height: 32, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isCurrent
                  ? AppTheme.primaryBlue.withOpacity(0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrent ? AppTheme.primaryBlue : Colors.grey.shade200,
                width: isCurrent ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Text(chapter.emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(chapter.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: unlocked ? AppTheme.textDark : Colors.grey,
                      )),
                ),
                if (isCurrent)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('EN COURS',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
