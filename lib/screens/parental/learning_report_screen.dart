import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/screen_time.dart';
import '../../services/accessibility_settings_service.dart';
import '../../services/audio_service.dart';
import '../../data/official_curriculum.dart';
import '../../services/stats_service.dart';
import '../../utils/app_theme.dart';

/// 📊 « Ce qui aide Emilie » — suivi pédagogique pour l'adulte.
///
/// Ce tableau reste descriptif : il montre ce qui s'est passé pendant les
/// séances, jamais une interprétation. L'application ne peut pas connaître
/// la cause d'une erreur ou d'un arrêt, donc elle ne la suppose pas.
class LearningReportScreen extends StatefulWidget {
  const LearningReportScreen({super.key});

  @override
  State<LearningReportScreen> createState() => _LearningReportScreenState();
}

class _LearningReportScreenState extends State<LearningReportScreen> {
  String _level = 'CE1';

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsService>();
    final screenTime = context.watch<ScreenTimeService>();
    final access = context.watch<AccessibilitySettingsService>();
    final audio = context.watch<AudioService>();

    final levelColor =
        _level == 'CE2' ? AppTheme.primaryPurple : AppTheme.primaryBlue;
    final competences = stats.competencesFor(_level);
    final observations = stats.observationsFor(_level);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Suivi des séances'),
        backgroundColor: AppTheme.primaryPurple.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Effacer le suivi',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmReset(context, stats),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Sélecteur de niveau — les données sont stockées séparément
          Row(
            children: [
              Expanded(
                child: _LevelTab(
                  label: 'CE1',
                  color: AppTheme.primaryBlue,
                  selected: _level == 'CE1',
                  onTap: () => setState(() => _level = 'CE1'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _LevelTab(
                  label: 'CE2',
                  color: AppTheme.primaryPurple,
                  selected: _level == 'CE2',
                  onTap: () => setState(() => _level = 'CE2'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (!stats.hasDataFor(_level))
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text('📭', style: TextStyle(fontSize: 44)),
                  const SizedBox(height: 12),
                  Text(
                    'Aucune séance enregistrée en $_level pour l\'instant.\n'
                    'Le suivi apparaîtra après les premières missions.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textGrey, height: 1.5),
                  ),
                ],
              ),
            )
          else ...[
            // ── Vue d'ensemble ──
            _Section('Vue d\'ensemble'),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    emoji: '▶️',
                    value: '${stats.startedFor(_level)}',
                    label: 'commencées',
                    color: levelColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    emoji: '✅',
                    value: '${stats.completedFor(_level)}',
                    label: 'terminées',
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    emoji: '🌟',
                    value: '${stats.autonomousFor(_level)}',
                    label: 'sans aide',
                    color: AppTheme.primaryYellow,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    emoji: '💡',
                    value: '${stats.withHelpFor(_level)}',
                    label: 'avec aide',
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
                ],
              ),
              child: Column(
                children: [
                  _MiniRow(
                    label: 'Aides demandées au total',
                    value: '${stats.hintsFor(_level)}',
                  ),
                  const Divider(height: 18),
                  _MiniRow(
                    label: 'Pauses proposées',
                    value: '${stats.pausesFor(_level)}',
                  ),
                  const Divider(height: 18),
                  _MiniRow(
                    label: 'Temps d\'écran aujourd\'hui',
                    value: '${screenTime.dailySeconds ~/ 60} min',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ── Observations ──
            _Section('Ce qui aide Emilie'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: observations
                    .map((o) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontSize: 15)),
                              Expanded(
                                child: Text(o,
                                    style: const TextStyle(fontSize: 13, height: 1.45)),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'ℹ️ Ce sont des observations, pas un diagnostic. L\'application '
                'ne peut pas savoir POURQUOI une mission a été arrêtée ou une '
                'aide demandée — seule votre observation directe le peut.',
                style: TextStyle(fontSize: 11, height: 1.5, color: AppTheme.textGrey),
              ),
            ),
            const SizedBox(height: 22),

            // ── Détail par compétence ──
            _Section('Compétences travaillées'),
            ...competences.map((e) {
              final st = e.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(StatsService.readableCompetence(e.key),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(e.key,
                        style: const TextStyle(
                            fontSize: 10, color: AppTheme.textGrey, height: 1.3)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 6,
                      children: [
                        _Tag('▶️ ${st.started} commencée(s)', levelColor),
                        _Tag('✅ ${st.completed} terminée(s)', AppTheme.primaryGreen),
                        if (st.autonomous > 0)
                          _Tag('🌟 ${st.autonomous} sans aide', AppTheme.primaryYellow),
                        if (st.withHelp > 0)
                          _Tag('💡 ${st.withHelp} avec aide', AppTheme.primaryOrange),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
          ],

          // ── Réglages actuels ──
          _Section('Réglages actuels d\'Emilie'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
              ],
            ),
            child: Column(
              children: [
                _MiniRow(
                    label: 'Profil sensoriel',
                    value: '${access.profile.emoji} ${access.profile.label}'),
                const Divider(height: 18),
                _MiniRow(
                    label: 'Mode calme',
                    value: access.calmModeEnabled ? 'activé' : 'désactivé'),
                const Divider(height: 18),
                _MiniRow(
                    label: 'Animations',
                    value: access.animationsEnabled ? 'activées' : 'coupées'),
                const Divider(height: 18),
                _MiniRow(
                    label: 'Lecture auto des consignes',
                    value: access.autoReadEnabled ? 'activée' : 'désactivée'),
                const Divider(height: 18),
                _MiniRow(label: 'Vitesse de voix', value: access.voiceRateLabel),
                const Divider(height: 18),
                _MiniRow(
                    label: 'Dictée en blocs de sons',
                    value: access.letterBlocksEnabled ? 'oui' : 'non (lettres)'),
                const Divider(height: 18),
                _MiniRow(
                    label: 'Vibrations',
                    value: access.hapticsEnabled ? 'activées' : 'coupées'),
                const Divider(height: 18),
                _MiniRow(label: 'Taille du texte', value: access.textScaleLabel),
                const Divider(height: 18),
                _MiniRow(
                    label: 'Pause proposée après',
                    value: screenTime.sessionLimitLabel),
                const Divider(height: 18),
                _MiniRow(
                    label: 'Musique / effets',
                    value:
                        '${audio.musicEnabled ? "musique on" : "musique off"} · '
                        '${audio.soundEnabled ? "effets on" : "effets off"}'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Couverture du parcours ──
          _Section('Couverture du parcours $_level'),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
              ],
            ),
            child: Column(
              children: [
                for (final d in OfficialCurriculum.all)
                  _DomainCoverage(
                    domain: d,
                    level: _level,
                    touched: d
                        .forLevel(_level)
                        .where((c) => competences
                            .any((e) => e.key == c.id && e.value.completed > 0))
                        .length,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(OfficialCurriculum.reference,
                    style: const TextStyle(
                        fontSize: 11, height: 1.5, color: AppTheme.textGrey)),
                const SizedBox(height: 8),
                Text(OfficialCurriculum.disclaimer,
                    style: const TextStyle(
                        fontSize: 11, height: 1.5, color: AppTheme.textGrey)),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, StatsService stats) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Effacer le suivi ?'),
        content: const Text(
            'Toutes les observations des séances (CE1 et CE2) seront supprimées. '
            'La progression et le jardin d\'Emilie ne sont pas touchés.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              stats.resetAll();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Effacer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section(this.title);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
      );
}

class _StatCard extends StatelessWidget {
  final String emoji, value, label;
  final Color color;
  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
        ],
      ),
    );
  }
}

class _MiniRow extends StatelessWidget {
  final String label, value;
  const _MiniRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryPurple)),
        ],
      );
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  const _Tag(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.14),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: color)),
      );
}

class _LevelTab extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _LevelTab({
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: selected ? color : Colors.grey.shade300, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: selected ? Colors.white : AppTheme.textGrey,
            )),
      ),
    );
  }
}

/// Une ligne « domaine → étapes déjà menées au bout », sans jugement.
class _DomainCoverage extends StatelessWidget {
  final CurriculumDomain domain;
  final String level;
  final int touched;

  const _DomainCoverage({
    required this.domain,
    required this.level,
    required this.touched,
  });

  @override
  Widget build(BuildContext context) {
    final total = domain.forLevel(level).length;
    final color = Color(domain.colorValue);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(domain.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(domain.label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : touched / total,
                    minHeight: 6,
                    backgroundColor: color.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text('$touched/$total',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}
