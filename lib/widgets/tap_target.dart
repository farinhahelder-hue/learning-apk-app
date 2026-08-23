import 'package:flutter/material.dart';

/// Garantit une zone tactile confortable autour d'un élément plus petit.
///
/// Material demande 48 dp au minimum. Pour une enfant de 7-8 ans dont la
/// motricité fine est encore en construction, c'est un plancher et non
/// un objectif : rater un bouton trois fois de suite décourage bien plus
/// qu'un exercice difficile.
///
/// **L'apparence ne change pas.** Seule la surface qui répond au doigt
/// s'agrandit, de façon invisible. C'est pour ça que la contrainte est un
/// minimum : un élément déjà plus grand garde sa taille.
///
/// [label] renseigne les lecteurs d'écran, qui ne voient qu'une icône.
class TapTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  /// Côté minimal de la zone sensible, en dp.
  final double size;

  /// Ce que le bouton fait, dit en toutes lettres.
  final String? label;

  const TapTarget({
    super.key,
    required this.child,
    this.onTap,
    this.size = 48,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final tappable = GestureDetector(
      // opaque : tout le carré répond, y compris les coins transparents
      // autour de l'icône.
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: size, minHeight: size),
        child: Center(child: child),
      ),
    );

    if (label == null) return tappable;
    return Semantics(button: true, label: label, child: tappable);
  }
}
