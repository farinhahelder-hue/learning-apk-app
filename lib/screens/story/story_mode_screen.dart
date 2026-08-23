import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/official_curriculum.dart';
import '../../services/accessibility_settings_service.dart';
import '../../services/game_service.dart';
import '../../services/stats_service.dart';
import '../../services/tts_service.dart';
import '../../utils/app_theme.dart';
import '../games/dictee_image_screen.dart';
import '../games/number_bars_screen.dart';
import '../games/problem_mission_screen.dart';
import '../games/sentence_workshop_screen.dart';
import '../french/french_menu_screen.dart';
import '../french/phonetique_screen.dart';
import '../math/math_menu_screen.dart';
import '../math/multiplication_tables_screen.dart';
import '../science/science_menu_screen.dart';
import 'tale_reader_screen.dart';

/// 📜 Mode histoire — le voyage d'Emilie à travers le programme.
///
/// Chaque chapitre est un domaine du programme, présenté comme un lieu à
/// visiter. La progression est visible mais jamais urgente : rien ne se
/// perd, rien n'expire, et Emilie choisit l'ordre de ses étapes.
class StoryModeScreen extends StatelessWidget {
  const StoryModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameService>();
    final stats = context.watch<StatsService>();
    final level = gs.gradeLevel;
    final levelColor =
        level == 'CE2' ? AppTheme.primaryPurple : AppTheme.primaryBlue;

    final domains = OfficialCurriculum.all;
    final total = OfficialCurriculum.totalCompetences(level);
    final done = domains.fold<int>(
      0,
      (sum, d) =>
          sum +
          d.forLevel(level).where((c) {
            final st = stats
                .competencesFor(level)
                .where((e) => e.key == c.id)
                .toList();
            return st.isNotEmpty && st.first.value.completed > 0;
          }).length,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('📜 Mon parcours'),
        backgroundColor: levelColor.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.homeGradient),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Le fil de l'histoire ──
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [levelColor.withOpacity(0.85), levelColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Text('🗺️', style: TextStyle(fontSize: 44)),
                  const SizedBox(height: 10),
                  Text('Le voyage d\'Emilie — Parcours $level',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  const Text(
                    'Emilie avance sur son chemin. Certaines étapes sont '
                    'nouvelles, d\'autres servent à renforcer ses pouvoirs. '
                    'Elle avance à son rythme.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : done / total,
                      minHeight: 10,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('$done étape(s) découverte(s) sur $total',
                      style: const TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Les chapitres ──
            ...domains.map((d) {
              final comps = d.forLevel(level);
              final color = Color(d.colorValue);
              final chapterDone = comps.where((c) {
                final st = stats
                    .competencesFor(level)
                    .where((e) => e.key == c.id)
                    .toList();
                return st.isNotEmpty && st.first.value.completed > 0;
              }).length;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StoryChapterScreen(domain: d, level: level),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.35), width: 2),
                    ),
                    child: Row(
                      children: [
                        Text(d.emoji, style: const TextStyle(fontSize: 38)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d.place,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: color)),
                              const SizedBox(height: 2),
                              Text(d.label,
                                  style: const TextStyle(
                                      fontSize: 12, color: AppTheme.textGrey)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: LinearProgressIndicator(
                                        value: comps.isEmpty
                                            ? 0
                                            : chapterDone / comps.length,
                                        minHeight: 6,
                                        backgroundColor: color.withOpacity(0.15),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(color),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('$chapterDone/${comps.length}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: color)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, color: color, size: 18),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),
            // ── Mention honnête sur la référence au programme ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ℹ️ À propos du programme',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(OfficialCurriculum.reference,
                      style: const TextStyle(
                          fontSize: 11, height: 1.5, color: AppTheme.textGrey)),
                  const SizedBox(height: 6),
                  Text(OfficialCurriculum.disclaimer,
                      style: const TextStyle(
                          fontSize: 11, height: 1.5, color: AppTheme.textGrey)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Un chapitre = un domaine du programme, présenté comme un lieu.
class StoryChapterScreen extends StatelessWidget {
  final CurriculumDomain domain;
  final String level;

  const StoryChapterScreen({
    super.key,
    required this.domain,
    required this.level,
  });

  void _launch(BuildContext context, Competence c) {
    Widget? screen;
    switch (c.activity) {
      case LearningActivity.numberBars:
        screen = NumberBarsScreen(competence: c.id);
        break;
      case LearningActivity.dictee:
        screen = DicteeImageScreen(competence: c.id);
        break;
      case LearningActivity.sentence:
        screen = SentenceWorkshopScreen(competence: c.id);
        break;
      case LearningActivity.problem:
        screen = ProblemMissionScreen(competence: c.id);
        break;
      case LearningActivity.tale:
        screen = TaleReaderScreen(competence: c.id);
        break;
      case LearningActivity.multiplication:
        screen = MultiplicationTablesScreen(competence: c.id);
        break;
      case LearningActivity.phonetique:
        screen = PhonetiqueScreen(competence: c.id);
        break;
      case LearningActivity.mathQuiz:
        screen = const MathMenuScreen();
        break;
      case LearningActivity.frenchQuiz:
        screen = const FrenchMenuScreen();
        break;
      case LearningActivity.scienceQuiz:
        screen = const ScienceMenuScreen();
        break;
      case LearningActivity.comingSoon:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
  }

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsService>();
    final color = Color(domain.colorValue);
    final comps = domain.forLevel(level);
    final animations =
        context.watch<AccessibilitySettingsService>().animationsEnabled;

    return Scaffold(
      appBar: AppBar(
        title: Text('${domain.emoji} ${domain.label}'),
        backgroundColor: color.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(12)),
                child: Text('Parcours $level',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── La narration du lieu ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: Column(
              children: [
                Text(domain.emoji,
                    style: TextStyle(fontSize: animations ? 46 : 40)),
                const SizedBox(height: 8),
                Text(domain.place,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900, color: color)),
                const SizedBox(height: 10),
                Text(domain.narration,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, height: 1.6)),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    final access = context.read<AccessibilitySettingsService>();
                    final tts = context.read<TtsService>();
                    tts.setSpeechRate(access.voiceRate);
                    tts.speak(domain.narration);
                  },
                  icon: const Icon(Icons.volume_up_rounded, size: 18),
                  label: const Text('Écouter'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Les étapes de ce lieu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),

          ...comps.map((c) {
            final entry = stats
                .competencesFor(level)
                .where((e) => e.key == c.id)
                .toList();
            final completed = entry.isNotEmpty ? entry.first.value.completed : 0;
            final available = c.activity.isAvailable;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: available ? () => _launch(context, c) : null,
                child: Opacity(
                  opacity: available ? 1 : 0.55,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: completed > 0
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade200,
                        width: completed > 0 ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(completed > 0 ? '✅' : c.activity.emoji,
                            style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.childLabel,
                                  style: const TextStyle(
                                      fontSize: 15, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 3),
                              Text(
                                available
                                    ? '${c.activity.emoji} ${c.activity.label}'
                                    : '🚧 Bientôt disponible',
                                style: const TextStyle(
                                    fontSize: 11, color: AppTheme.textGrey),
                              ),
                              if (completed > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text('Déjà visitée $completed fois',
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF4CAF50),
                                          fontWeight: FontWeight.w700)),
                                ),
                            ],
                          ),
                        ),
                        if (available)
                          Icon(Icons.arrow_forward_ios, color: color, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Aucune étape ne se perd. Tu peux revenir quand tu veux, '
              'refaire une étape déjà visitée, ou passer à un autre lieu.',
              style: TextStyle(fontSize: 11, height: 1.5, color: AppTheme.textGrey),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
