import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/accessibility_settings_service.dart';
import '../../services/game_service.dart';
import '../../services/story_factory_service.dart';
import '../../services/tts_service.dart';
import '../../utils/app_theme.dart';
import 'story_factory_screen.dart';

/// 📚 Les histoires écrites par Emilie.
///
/// Une bibliothèque, pas un carnet de notes : les histoires sont rangées
/// de la plus récente à la plus ancienne, sans compteur de régularité et
/// sans rien qui expire. Sauter trois semaines ne coûte rien.
class MyStoriesScreen extends StatelessWidget {
  const MyStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<StoryFactoryService>();
    final level = context.watch<GameService>().gradeLevel;
    final color =
        level == 'CE2' ? AppTheme.primaryPurple : AppTheme.primaryPink;

    // Toutes les histoires sont montrées, quel que soit le niveau au
    // moment de l'écriture : ce qu'Emilie a écrit en CE1 lui appartient
    // toujours en CE2.
    final stories = service.stories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Mes histoires'),
        backgroundColor: color.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: stories.isEmpty
          ? _buildEmpty(context, color)
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  stories.length == 1
                      ? 'Tu as écrit 1 histoire.'
                      : 'Tu as écrit ${stories.length} histoires.',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                ...stories.map((s) => _StoryCard(story: s, color: color)),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const StoryFactoryScreen()),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Écrire une nouvelle histoire'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  Widget _buildEmpty(BuildContext context, Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📚', style: TextStyle(fontSize: 66)),
            const SizedBox(height: 16),
            const Text('Ta bibliothèque est vide pour l\'instant',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            const Text(
              'Les histoires que tu écriras seront rangées ici. Tu pourras '
              'les relire et les écouter quand tu veux.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, height: 1.6, color: AppTheme.textGrey),
            ),
            const SizedBox(height: 26),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoryFactoryScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                minimumSize: const Size(240, 56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text('Écrire ma première histoire',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  final WrittenStory story;
  final Color color;

  const _StoryCard({required this.story, required this.color});

  void _speak(BuildContext context, String text) {
    final access = context.read<AccessibilitySettingsService>();
    final tts = context.read<TtsService>();
    tts.setSpeechRate(access.voiceRate);
    tts.speak(text);
  }

  String get _date {
    final d = story.writtenAt;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25), width: 2),
      ),
      child: Theme(
        // Retire le trait de séparation par défaut de l'ExpansionTile.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Text(story.level == 'CE2' ? '📗' : '📘',
              style: const TextStyle(fontSize: 26)),
          title: Text(story.title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          subtitle: Text('Écrite le $_date',
              style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            ...story.paragraphs.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(p,
                            style:
                                const TextStyle(fontSize: 14, height: 1.6)),
                      ),
                      IconButton(
                        onPressed: () => _speak(context, p),
                        icon: const Icon(Icons.volume_up_rounded, size: 18),
                        color: color,
                        tooltip: 'Écouter ce passage',
                      ),
                    ],
                  ),
                )),
            OutlinedButton.icon(
              onPressed: () => _speak(context, story.fullText),
              icon: const Icon(Icons.volume_up_rounded, size: 18),
              label: const Text('Écouter toute l\'histoire'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
