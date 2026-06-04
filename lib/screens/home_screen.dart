import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../services/progress_service.dart';
import '../widgets/subject_card.dart';
import '../widgets/progress_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>().progress;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.homeGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour ${AppConstants.childName} ! 🌟',
                          style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          'Niveau ${progress.currentLevel} • ${progress.totalPoints} ⭐',
                          style: const TextStyle(
                            fontSize: 16, color: AppTheme.textGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _showParentalCodeDialog(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10, offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Text('🔒', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),
                const SizedBox(height: 20),
                // --- Bannière progression ---
                ProgressBanner(progress: progress)
                    .animate(delay: 200.ms).fadeIn(duration: 500.ms).slideX(begin: -0.2),
                const SizedBox(height: 28),
                const Text(
                  'Que veux-tu apprendre ?',
                  style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ).animate(delay: 300.ms).fadeIn(),
                const SizedBox(height: 16),
                // --- Cartes matières ---
                SubjectCard(
                  title: 'Mathématiques', emoji: '🔢',
                  subtitle: 'Additions • Multiplications • Géométrie',
                  gradient: AppTheme.mathGradient, points: progress.mathPoints,
                  onTap: () => Navigator.pushNamed(context, '/math'),
                ).animate(delay: 400.ms).fadeIn(duration: 500.ms).slideX(begin: 0.2),
                const SizedBox(height: 16),
                SubjectCard(
                  title: 'Français', emoji: '📚',
                  subtitle: 'Lecture • Orthographe • Conjugaison',
                  gradient: AppTheme.frenchGradient, points: progress.frenchPoints,
                  onTap: () => Navigator.pushNamed(context, '/french'),
                ).animate(delay: 500.ms).fadeIn(duration: 500.ms).slideX(begin: -0.2),
                const SizedBox(height: 16),
                SubjectCard(
                  title: 'Sciences', emoji: '🔬',
                  subtitle: 'Nature • Corps humain • Météo',
                  gradient: AppTheme.scienceGradient, points: progress.sciencePoints,
                  onTap: () => Navigator.pushNamed(context, '/science'),
                ).animate(delay: 600.ms).fadeIn(duration: 500.ms).slideX(begin: 0.2),
                const SizedBox(height: 24),
                // --- Badges ---
                if (progress.earnedBadges.isNotEmpty) ...[
                  const Text(
                    'Mes badges 🏅',
                    style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ).animate(delay: 700.ms).fadeIn(),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10, runSpacing: 10,
                    children: progress.earnedBadges.map((badgeId) {
                      final badge = AppConstants.badges
                          .firstWhere((b) => b['id'] == badgeId, orElse: () => {});
                      if (badge.isEmpty) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(badge['icon'] as String, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 6),
                            Text(badge['name'] as String,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      );
                    }).toList(),
                  ).animate(delay: 800.ms).fadeIn(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showParentalCodeDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Espace parents 🔒',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Entre le code parental :'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 4, obscureText: true,
              decoration: InputDecoration(
                hintText: '• • • •',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              if (controller.text == AppConstants.parentalCode) {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, '/parental');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Code incorrect ! Réessaie.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Entrer'),
          ),
        ],
      ),
    );
  }
}
