import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/mascot.dart';
import 'rive_mascot_widget.dart';

/// Carousel de sélection de mascotte
/// Affiché sur l'écran d'accueil ou en début d'exercice
/// L'enfant choisit sa mascotte du jour !
class MascotSelectorCarousel extends StatefulWidget {
  final ValueChanged<Mascot>? onSelected;
  final Mascot? initial;

  const MascotSelectorCarousel({
    super.key,
    this.onSelected,
    this.initial,
  });

  @override
  State<MascotSelectorCarousel> createState() =>
      _MascotSelectorCarouselState();
}

class _MascotSelectorCarouselState
    extends State<MascotSelectorCarousel> {
  late PageController _pageCtrl;
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial != null
        ? Mascots.all.indexOf(widget.initial!)
        : 0;
    if (_selected < 0) _selected = 0;
    _pageCtrl = PageController(
      initialPage: _selected,
      viewportFraction: 0.65,
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mascots = Mascots.all;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Choisis ta mascotte ! 🌟',
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF37474F),
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: mascots.length,
            onPageChanged: (i) {
              setState(() => _selected = i);
              HapticFeedback.selectionClick();
              widget.onSelected?.call(mascots[i]);
            },
            itemBuilder: (ctx, i) {
              final mascot  = mascots[i];
              final isActive = i == _selected;
              return AnimatedScale(
                scale: isActive ? 1.0 : 0.82,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                child: GestureDetector(
                  onTap: () => _pageCtrl.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isActive
                          ? mascot.color.withOpacity(0.15)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isActive
                            ? mascot.color
                            : Colors.grey.shade200,
                        width: isActive ? 3 : 1.5,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: mascot.color.withOpacity(0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RiveMascotWidget(
                          mascot: mascot,
                          mood: isActive
                              ? MascotMood.happy
                              : MascotMood.idle,
                          size: 100,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mascot.personality,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate(delay: (i * 80).ms).fadeIn().slideX(begin: 0.1);
            },
          ),
        ),

        const SizedBox(height: 12),

        // Indicateurs de page (points)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            mascots.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width:  i == _selected ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == _selected
                    ? mascots[_selected].color
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Bulle phrase de la mascotte sélectionnée
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: Container(
            key: ValueKey(_selected),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: mascots[_selected].color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              mascots[_selected].idlePhrases[0],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: mascots[_selected].color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
