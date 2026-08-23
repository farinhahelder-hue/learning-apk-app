import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/story_factory_data.dart';
import '../../services/accessibility_settings_service.dart';
import '../../services/audio_service.dart';
import '../../services/game_service.dart';
import '../../services/garden_service.dart';
import '../../services/stats_service.dart';
import '../../services/story_factory_service.dart';
import '../../services/tts_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/haptics.dart';
import '../../widgets/confetti_overlay.dart';

/// ✒️ Fabrique à histoires — écrire un texte à soi.
///
/// Rien n'est corrigé ici, et c'est volontaire : une production d'écrit ne
/// se juge pas automatiquement. Il n'y a ni score, ni faute signalée, ni
/// version attendue. Ce qu'Emilie écrit est le résultat.
///
/// Écrire au clavier n'est jamais obligatoire : chaque étape propose des
/// amorces à toucher, et une histoire entière peut se composer sans taper
/// une seule lettre.
class StoryFactoryScreen extends StatefulWidget {
  /// Compétence du parcours à créditer. Hors parcours, on enregistre sous
  /// une clé générique : écrire reste écrire.
  final String competence;

  const StoryFactoryScreen({
    super.key,
    this.competence = 'production_ecrit',
  });

  @override
  State<StoryFactoryScreen> createState() => _StoryFactoryScreenState();
}

enum _Phase { ingredients, writing, reading }

class _StoryFactoryScreenState extends State<StoryFactoryScreen> {
  late final String _level;
  late final List<StoryStep> _steps;

  _Phase _phase = _Phase.ingredients;

  StoryIngredient? _who;
  StoryIngredient? _where;
  StoryIngredient? _object;
  StoryIngredient? _trouble;

  int _stepIndex = 0;

  /// Ce qu'Emilie a composé pour chaque étape, amorces et texte libre
  /// confondus.
  late final List<String> _written;
  final _controller = TextEditingController();
  final _titleController = TextEditingController();

  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  StoryStep get _step => _steps[_stepIndex];
  Color get _levelColor =>
      _level == 'CE2' ? AppTheme.primaryPurple : AppTheme.primaryPink;

  bool get _ingredientsReady =>
      _who != null && _where != null && _object != null && _trouble != null;

  @override
  void initState() {
    super.initState();
    _level = context.read<GameService>().gradeLevel;
    _steps = StoryFactoryData.stepsFor(_level);
    _written = List.filled(_steps.length, '', growable: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _speak(String text) {
    final access = context.read<AccessibilitySettingsService>();
    final tts = context.read<TtsService>();
    tts.setSpeechRate(access.voiceRate);
    tts.speak(text);
  }

  /// Remplace les marqueurs par les ingrédients choisis.
  String _fill(String template) => template
      .replaceAll('{qui}', _who?.text ?? '')
      .replaceAll('{ou}', _where?.text ?? '')
      .replaceAll('{objet}', _object?.text ?? '')
      .replaceAll('{souci}', _trouble?.text ?? '');

  /// Le paragraphe complet d'une étape : l'amorce toute faite, puis ce
  /// qu'Emilie a ajouté.
  String _paragraph(int i) {
    final opener = _fill(_steps[i].opener);
    final own = _written[i].trim();
    if (own.isEmpty) return opener;
    return '$opener $own';
  }

  List<String> get _paragraphs =>
      List.generate(_steps.length, _paragraph);

  // ── Composition ──────────────────────────────────────────
  void _addSuggestion(String s) {
    AppHaptics.selection();
    context.read<AudioService>().onButtonTap();
    final filled = _fill(s);
    setState(() {
      final current = _controller.text.trim();
      _controller.text = current.isEmpty ? filled : '$current $filled';
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    });
  }

  void _startWriting() {
    context.read<GardenService>().rewardMissionStarted();
    context.read<StatsService>().recordStarted(_level, widget.competence);
    setState(() {
      _phase = _Phase.writing;
      _stepIndex = 0;
      _controller.clear();
    });
  }

  void _nextStep() {
    setState(() {
      _written[_stepIndex] = _controller.text;
      if (_stepIndex < _steps.length - 1) {
        _stepIndex++;
        _controller.text = _written[_stepIndex];
      } else {
        _phase = _Phase.reading;
        _titleController.text = 'L\'histoire de ${_who?.label ?? 'mon héros'}';
      }
    });
  }

  void _previousStep() {
    setState(() {
      _written[_stepIndex] = _controller.text;
      if (_stepIndex > 0) {
        _stepIndex--;
        _controller.text = _written[_stepIndex];
      } else {
        _phase = _Phase.ingredients;
      }
    });
  }

  Future<void> _keepStory() async {
    final access = context.read<AccessibilitySettingsService>();
    final title = _titleController.text.trim().isEmpty
        ? 'Mon histoire'
        : _titleController.text.trim();

    await context.read<StoryFactoryService>().add(WrittenStory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          level: _level,
          title: title,
          paragraphs: _paragraphs,
          writtenAt: DateTime.now(),
        ));

    if (!mounted) return;
    context.read<GardenService>().rewardActivityCompleted();
    context.read<StatsService>()
        .recordCompleted(_level, widget.competence, hintsUsed: 0);
    context.read<AudioService>().onPerfect();
    if (!access.calmModeEnabled) {
      _confettiKey.currentState?.burst();
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ton histoire est rangée dans tes histoires 📚')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('✒️ Fabrique à histoires'),
        backgroundColor: _levelColor.withOpacity(0.15),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          switch (_phase) {
            _Phase.ingredients => _buildIngredients(),
            _Phase.writing => _buildWriting(),
            _Phase.reading => _buildReading(),
          },
          ConfettiOverlay(key: _confettiKey),
        ],
      ),
    );
  }

  // ── 1. Les ingrédients ───────────────────────────────────
  Widget _buildIngredients() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _levelColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _levelColor.withOpacity(0.3), width: 2),
          ),
          child: const Column(
            children: [
              Text('✒️', style: TextStyle(fontSize: 44)),
              SizedBox(height: 8),
              Text('Choisis les ingrédients de ton histoire',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
              SizedBox(height: 6),
              Text(
                'Personne ne corrigera ce que tu écris. Ton histoire sera '
                'gardée telle que tu l\'as faite.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, height: 1.5, color: AppTheme.textGrey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _IngredientPicker(
          title: 'Qui ?',
          items: StoryFactoryData.characters,
          selected: _who,
          color: _levelColor,
          onPick: (i) => setState(() => _who = i),
        ),
        _IngredientPicker(
          title: 'Où ?',
          items: StoryFactoryData.places,
          selected: _where,
          color: _levelColor,
          onPick: (i) => setState(() => _where = i),
        ),
        _IngredientPicker(
          title: 'Avec quoi ?',
          items: StoryFactoryData.objects,
          selected: _object,
          color: _levelColor,
          onPick: (i) => setState(() => _object = i),
        ),
        _IngredientPicker(
          title: 'Quel souci ?',
          items: StoryFactoryData.troubles,
          selected: _trouble,
          color: _levelColor,
          onPick: (i) => setState(() => _trouble = i),
        ),

        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _ingredientsReady ? _startWriting : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _levelColor,
            minimumSize: const Size(double.infinity, 56),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: Text(
            _ingredientsReady
                ? 'Commencer mon histoire'
                : 'Choisis les quatre ingrédients',
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── 2. L'écriture ────────────────────────────────────────
  Widget _buildWriting() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        LinearProgressIndicator(
          value: (_stepIndex + 1) / _steps.length,
          backgroundColor: Colors.grey.shade200,
          color: _levelColor,
          minHeight: 8,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 6),
        Text('Partie ${_stepIndex + 1} / ${_steps.length}',
            style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
        const SizedBox(height: 14),

        Text(_step.prompt,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),

        // L'amorce, déjà écrite : Emilie n'a jamais la page blanche.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _levelColor.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(_fill(_step.opener),
                    style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        fontStyle: FontStyle.italic)),
              ),
              IconButton(
                onPressed: () => _speak(_fill(_step.opener)),
                icon: const Icon(Icons.volume_up_rounded, size: 20),
                color: _levelColor,
                tooltip: 'Écouter le début',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // La suite : à toucher, ou à écrire, ou les deux.
        TextField(
          controller: _controller,
          maxLines: 5,
          minLines: 3,
          style: const TextStyle(fontSize: 16, height: 1.5),
          decoration: InputDecoration(
            hintText: 'Touche une idée en dessous, ou écris ici…',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text('💡 ${_step.nudge}',
                  style: const TextStyle(
                      fontSize: 11, height: 1.4, color: AppTheme.textGrey)),
            ),
            if (_controller.text.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _controller.clear()),
                child: const Text('Effacer'),
              ),
          ],
        ),
        const SizedBox(height: 12),

        const Text('Des idées à toucher',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ..._step.suggestions.map((s) {
          final filled = _fill(s);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => _addSuggestion(s),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _levelColor.withOpacity(0.35)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        size: 18, color: _levelColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(filled,
                          style: const TextStyle(fontSize: 14, height: 1.4)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(_stepIndex == 0 ? 'Ingrédients' : 'Partie d\'avant'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                // Aucune longueur minimale exigée : une partie peut
                // rester très courte, ou même se réduire à son amorce.
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _levelColor,
                  minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _stepIndex < _steps.length - 1
                      ? 'Partie suivante ➡️'
                      : 'Relire mon histoire 📖',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── 3. La relecture ──────────────────────────────────────
  Widget _buildReading() {
    final paragraphs = _paragraphs;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('📖', style: TextStyle(fontSize: 48), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        TextField(
          controller: _titleController,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          decoration: InputDecoration(
            labelText: 'Le titre de ton histoire',
            filled: true,
            fillColor: Colors.white,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 18),

        ...paragraphs.map((p) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _levelColor.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(p,
                        style: const TextStyle(fontSize: 16, height: 1.7)),
                  ),
                  IconButton(
                    onPressed: () => _speak(p),
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                    color: _levelColor,
                    tooltip: 'Écouter ce passage',
                  ),
                ],
              ),
            )),

        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _speak(paragraphs.join(' ')),
          icon: const Icon(Icons.volume_up_rounded),
          label: const Text('Écouter toute mon histoire'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => setState(() {
            _phase = _Phase.writing;
            _stepIndex = _steps.length - 1;
            _controller.text = _written[_stepIndex];
          }),
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Changer quelque chose'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _keepStory,
          style: ElevatedButton.styleFrom(
            backgroundColor: _levelColor,
            minimumSize: const Size(double.infinity, 56),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: const Text('Garder mon histoire 📚',
              style: TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

/// Une rangée d'ingrédients à choisir, avec le choix courant mis en avant.
class _IngredientPicker extends StatelessWidget {
  final String title;
  final List<StoryIngredient> items;
  final StoryIngredient? selected;
  final Color color;
  final ValueChanged<StoryIngredient> onPick;

  const _IngredientPicker({
    required this.title,
    required this.items,
    required this.selected,
    required this.color,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              if (selected != null)
                Text(selected!.label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final item = items[i];
                final isPicked = selected?.label == item.label;
                return GestureDetector(
                  onTap: () {
                    AppHaptics.selection();
                    onPick(item);
                  },
                  child: Container(
                    width: 88,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPicked ? color.withOpacity(0.15) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isPicked ? color : Colors.grey.shade300,
                        width: isPicked ? 3 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(item.emoji, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(item.label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
