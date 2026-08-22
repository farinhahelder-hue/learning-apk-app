import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/accessibility_settings_service.dart';
import '../../services/audio_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/breathing_bubble.dart';

/// 🫧 La salle sensorielle — un espace de pause, sans score et sans objectif.
///
/// Ce n'est ni un exercice caché, ni un dispositif médical : juste un endroit
/// calme où Emilie peut aller quand elle en a envie, et qu'elle peut quitter
/// à tout moment. Aucun message d'échec, aucune musique imposée.
class SensoryRoomScreen extends StatelessWidget {
  const SensoryRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      {
        'emoji': '🫧', 'title': 'Ondes douces',
        'subtitle': 'Touche l\'écran, des ondes apparaissent',
        'color': AppTheme.primaryBlue,
        'builder': (BuildContext c) => const _RippleRoom(),
      },
      {
        'emoji': '🎨', 'title': 'Dessin libre',
        'subtitle': 'Dessine ce que tu veux, sans consigne',
        'color': AppTheme.primaryPink,
        'builder': (BuildContext c) => const _DrawingRoom(),
      },
      {
        'emoji': '🌊', 'title': 'Respiration',
        'subtitle': 'Respire avec la bulle qui grandit',
        'color': AppTheme.primaryPurple,
        'builder': (BuildContext c) => const _BreathingRoom(),
      },
      {
        'emoji': '🔶', 'title': 'Bac à formes',
        'subtitle': 'Déplace les formes comme tu veux',
        'color': AppTheme.primaryOrange,
        'builder': (BuildContext c) => const _ShapesRoom(),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('🫧 Salle calme'),
        backgroundColor: AppTheme.primaryBlue.withOpacity(0.12),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.calmHomeGradient),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Un endroit tranquille, rien à réussir.\nTu peux partir quand tu veux.',
              style: TextStyle(fontSize: 14, color: AppTheme.textGrey, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ...activities.map((a) {
              final color = a['color'] as Color;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: a['builder'] as WidgetBuilder),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.35), width: 2),
                    ),
                    child: Row(
                      children: [
                        Text(a['emoji'] as String, style: const TextStyle(fontSize: 36)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a['title'] as String,
                                  style: TextStyle(
                                      fontSize: 17, fontWeight: FontWeight.w800, color: color)),
                              const SizedBox(height: 2),
                              Text(a['subtitle'] as String,
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
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
          ],
        ),
      ),
    );
  }
}

/// Barre de contrôle commune à toutes les activités calmes :
/// retour, couper les sons, arrêter les animations — toujours accessibles.
class _CalmScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> extraActions;

  const _CalmScaffold({
    required this.title,
    required this.child,
    this.extraActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioService>();
    final access = context.watch<AccessibilitySettingsService>();
    final silent = !audio.musicEnabled && !audio.soundEnabled;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white.withOpacity(0.9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Retour',
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          ...extraActions,
          IconButton(
            tooltip: silent ? 'Réactiver les sons' : 'Couper les sons',
            icon: Text(silent ? '🔕' : '🔊', style: const TextStyle(fontSize: 20)),
            onPressed: () {
              if (silent) {
                audio.toggleMusic();
                audio.toggleSound();
              } else {
                if (audio.musicEnabled) audio.toggleMusic();
                if (audio.soundEnabled) audio.toggleSound();
              }
            },
          ),
          IconButton(
            tooltip: access.animationsEnabled
                ? 'Arrêter les animations'
                : 'Réactiver les animations',
            icon: Text(access.animationsEnabled ? '✨' : '⏸️',
                style: const TextStyle(fontSize: 20)),
            onPressed: access.toggleAnimations,
          ),
        ],
      ),
      body: child,
    );
  }
}

// ══════════════════════════════════════════════════════════
// 1. Ondes douces
// ══════════════════════════════════════════════════════════

class _RippleRoom extends StatefulWidget {
  const _RippleRoom();
  @override
  State<_RippleRoom> createState() => _RippleRoomState();
}

class _RippleRoomState extends State<_RippleRoom> {
  final List<_RippleData> _ripples = [];
  int _counter = 0;

  static const _colors = [
    Color(0xFF4FC3F7), Color(0xFF81C784), Color(0xFFCE93D8),
    Color(0xFFFFD54F), Color(0xFFFF80AB),
  ];

  void _addRipple(Offset pos) {
    setState(() {
      _counter++;
      _ripples.add(_RippleData(
        id: _counter,
        position: pos,
        color: _colors[_counter % _colors.length],
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final animate =
        context.watch<AccessibilitySettingsService>().animationsEnabled;

    return _CalmScaffold(
      title: '🫧 Ondes douces',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) => _addRipple(d.localPosition),
        onPanUpdate: (d) {
          if (_ripples.length < 40) _addRipple(d.localPosition);
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppTheme.calmHomeGradient),
          child: Stack(
            children: [
              if (_ripples.isEmpty)
                const Center(
                  child: Text(
                    'Touche l\'écran 👆',
                    style: TextStyle(fontSize: 16, color: AppTheme.textGrey),
                  ),
                ),
              ..._ripples.map((r) => _RippleDot(
                    key: ValueKey(r.id),
                    data: r,
                    animate: animate,
                    onDone: () {
                      if (!mounted) return;
                      setState(() => _ripples.removeWhere((x) => x.id == r.id));
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _RippleData {
  final int id;
  final Offset position;
  final Color color;
  const _RippleData({required this.id, required this.position, required this.color});
}

class _RippleDot extends StatefulWidget {
  final _RippleData data;
  final bool animate;
  final VoidCallback onDone;
  const _RippleDot({super.key, required this.data, required this.animate, required this.onDone});

  @override
  State<_RippleDot> createState() => _RippleDotState();
}

class _RippleDotState extends State<_RippleDot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.animate ? 1800 : 400),
    )..forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        final size = 30 + t * 130;
        return Positioned(
          left: widget.data.position.dx - size / 2,
          top: widget.data.position.dy - size / 2,
          child: Opacity(
            opacity: (1 - t).clamp(0.0, 1.0) * 0.7,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: widget.data.color, width: 3),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════
// 2. Dessin libre
// ══════════════════════════════════════════════════════════

class _DrawingRoom extends StatefulWidget {
  const _DrawingRoom();
  @override
  State<_DrawingRoom> createState() => _DrawingRoomState();
}

class _DrawingRoomState extends State<_DrawingRoom> {
  final List<_Stroke> _strokes = [];
  Color _color = const Color(0xFF4FC3F7);

  static const _palette = [
    Color(0xFF4FC3F7), Color(0xFFFF80AB), Color(0xFF81C784),
    Color(0xFFFFD54F), Color(0xFFCE93D8), Color(0xFF8D6E63),
  ];

  @override
  Widget build(BuildContext context) {
    return _CalmScaffold(
      title: '🎨 Dessin libre',
      extraActions: [
        IconButton(
          tooltip: 'Tout effacer',
          icon: const Icon(Icons.cleaning_services_rounded),
          onPressed: () => setState(_strokes.clear),
        ),
      ],
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onPanStart: (d) => setState(() =>
                  _strokes.add(_Stroke(color: _color, points: [d.localPosition]))),
              onPanUpdate: (d) => setState(() {
                if (_strokes.isNotEmpty) _strokes.last.points.add(d.localPosition);
              }),
              child: Container(
                width: double.infinity,
                color: const Color(0xFFFFFDF7),
                child: CustomPaint(
                  painter: _DrawingPainter(_strokes),
                  child: _strokes.isEmpty
                      ? const Center(
                          child: Text('Dessine avec ton doigt ✏️',
                              style: TextStyle(fontSize: 16, color: AppTheme.textGrey)),
                        )
                      : null,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _palette.map((c) {
                final selected = c == _color;
                return GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: selected ? 42 : 34,
                    height: selected ? 42 : 34,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? AppTheme.textDark : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stroke {
  final Color color;
  final List<Offset> points;
  _Stroke({required this.color, required this.points});
}

class _DrawingPainter extends CustomPainter {
  final List<_Stroke> strokes;
  const _DrawingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      if (s.points.length < 2) {
        if (s.points.isNotEmpty) {
          canvas.drawCircle(s.points.first, 3, paint..style = PaintingStyle.fill);
        }
        continue;
      }
      final path = Path()..moveTo(s.points.first.dx, s.points.first.dy);
      for (final p in s.points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}

// ══════════════════════════════════════════════════════════
// 3. Respiration visuelle
// ══════════════════════════════════════════════════════════

class _BreathingRoom extends StatelessWidget {
  const _BreathingRoom();

  @override
  Widget build(BuildContext context) {
    return _CalmScaffold(
      title: '🌊 Respiration',
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryPurple.withOpacity(0.45),
              AppTheme.primaryBlue.withOpacity(0.55),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          // La bulle est le cœur de l'activité : elle reste animée ici,
          // puisque c'est précisément ce qu'Emilie vient chercher.
          child: BreathingBubble(color: Colors.white, size: 150),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 4. Bac à formes
// ══════════════════════════════════════════════════════════

class _ShapesRoom extends StatefulWidget {
  const _ShapesRoom();
  @override
  State<_ShapesRoom> createState() => _ShapesRoomState();
}

class _ShapesRoomState extends State<_ShapesRoom> {
  late List<_Shape> _shapes;
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    final size = MediaQuery.of(context).size;
    final rand = math.Random();
    const emojis = ['🔵', '🔶', '🟩', '🔺', '🟣', '🟠', '⬜', '💠'];
    _shapes = List.generate(8, (i) {
      return _Shape(
        emoji: emojis[i % emojis.length],
        position: Offset(
          30 + rand.nextDouble() * (size.width - 110),
          80 + rand.nextDouble() * (size.height - 320),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _CalmScaffold(
      title: '🔶 Bac à formes',
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.calmHomeGradient),
        child: Stack(
          children: [
            const Positioned(
              top: 16, left: 0, right: 0,
              child: Text('Déplace les formes comme tu veux 👆',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppTheme.textGrey)),
            ),
            ..._shapes.map((s) => Positioned(
                  left: s.position.dx,
                  top: s.position.dy,
                  child: GestureDetector(
                    onPanUpdate: (d) => setState(() => s.position += d.delta),
                    child: Text(s.emoji, style: const TextStyle(fontSize: 58)),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _Shape {
  final String emoji;
  Offset position;
  _Shape({required this.emoji, required this.position});
}
