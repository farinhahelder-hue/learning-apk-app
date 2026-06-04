import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../services/progress_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';

class ParentalDashboardScreen extends StatelessWidget {
  const ParentalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<ProgressService>();
    final p   = svc.progress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Parents 👨‍👩‍👧'),
        backgroundColor: AppTheme.primaryPurple.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Réinitialiser la progression',
            onPressed: () => _confirmReset(context, svc),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Récapitulatif global ---
            _SectionTitle(title: 'Récapitulatif 📊'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCE93D8), Color(0xFF9C27B0)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _WhiteStat(label: 'Total pts', value: '${p.totalPoints}'),
                  _WhiteStat(label: 'Niveau',    value: '${p.currentLevel}'),
                  _WhiteStat(label: 'Badges',    value: '${p.earnedBadges.length}'),
                  _WhiteStat(label: 'Série',     value: '${p.streakDays}j'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // --- Progression par matière ---
            _SectionTitle(title: 'Progression par matière'),
            const SizedBox(height: 12),
            _SubjectProgress(
              label: 'Mathématiques 🔢', points: p.mathPoints,
              color: AppTheme.mathColor, max: 300,
            ),
            const SizedBox(height: 10),
            _SubjectProgress(
              label: 'Français 📚', points: p.frenchPoints,
              color: AppTheme.frenchColor, max: 300,
            ),
            const SizedBox(height: 10),
            _SubjectProgress(
              label: 'Sciences 🔬', points: p.sciencePoints,
              color: AppTheme.scienceColor, max: 300,
            ),
            const SizedBox(height: 24),
            // --- Badges obtenus ---
            _SectionTitle(title: 'Badges obtenus 🏅'),
            const SizedBox(height: 12),
            if (p.earnedBadges.isEmpty)
              const Text('Aucun badge pour l’instant. Encourage Emilie !',
                  style: TextStyle(color: AppTheme.textGrey))
            else
              Wrap(
                spacing: 10, runSpacing: 10,
                children: p.earnedBadges.map((id) {
                  final badge = AppConstants.badges
                      .firstWhere((b) => b['id'] == id, orElse: () => {});
                  if (badge.isEmpty) return const SizedBox.shrink();
                  return Chip(
                    avatar: Text(badge['icon'] as String),
                    label: Text(badge['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    backgroundColor: AppTheme.primaryPurple.withOpacity(0.15),
                  );
                }).toList(),
              ),
            const SizedBox(height: 24),
            // --- Conseils ---
            _SectionTitle(title: 'Conseils pour les parents 💡'),
            const SizedBox(height: 12),
            ..._tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontSize: 18, color: AppTheme.primaryPurple)),
                  Expanded(child: Text(tip, style: const TextStyle(fontSize: 14, height: 1.5))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  static const List<String> _tips = [
    'Sessions recommandées : 10–15 minutes par jour pour maintenir l’attention.',
    'Célébrez chaque badge obtenu — la motivation positive est clé à cet âge.',
    'Alternativer les matières évite la monotonie et stimule l’apprentissage.',
    'Le code parental par défaut est 1234 — changez-le dans le fichier constants.dart.',
    'En cas de difficulté persistante, répétez les exercices de niveau 1 (difficulté facile).',
  ];

  void _confirmReset(BuildContext context, ProgressService svc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Réinitialiser ?'),
        content: const Text('Toute la progression d’Emilie sera effacée. Êtes-vous sûr ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              svc.resetProgress();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Réinitialiser', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark));
}

class _WhiteStat extends StatelessWidget {
  final String label, value;
  const _WhiteStat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
      Text(label,  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
    ],
  );
}

class _SubjectProgress extends StatelessWidget {
  final String label;
  final int points;
  final Color color;
  final int max;
  const _SubjectProgress({required this.label, required this.points, required this.color, required this.max});

  @override
  Widget build(BuildContext context) {
    final double pct = (points / max).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              Text('$points pts', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            percent: pct, lineHeight: 10,
            backgroundColor: Colors.grey.shade200,
            progressColor: color,
            barRadius: const Radius.circular(10),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
