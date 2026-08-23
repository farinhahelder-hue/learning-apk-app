import 'package:flutter/material.dart';

/// Renforcement du contraste, appliqué à toute l'application d'un seul
/// endroit.
///
/// Pourquoi un filtre et pas des couleurs différentes : les couleurs de
/// texte de l'application sont écrites dans des `const TextStyle`, à
/// travers une centaine de fichiers. Les rendre modifiables à chaud
/// casserait leur constance partout. Un filtre appliqué au-dessus de
/// l'arbre de widgets les atteint toutes sans en toucher aucune.
///
/// **Ce qu'il fait, mesuré.** Le texte gris sur fond clair passe d'un
/// rapport de contraste de 5,0 à 6,1 : c'est le cas le plus fréquent dans
/// l'application, et le gain est net.
///
/// **Ce qu'il ne fait pas.** Le texte blanc posé sur les cartes colorées
/// reste sous le seuil WCAG AA de 4,5 (environ 3,9 sur le bleu des maths)
/// et le filtre n'y change presque rien : il éclaircit le texte et le
/// fond dans le même sens. Y arriver demanderait d'assombrir les couleurs
/// de marque elles-mêmes — une décision de design, pas un réglage.
///
/// Le filtre n'est monté que si le réglage est actif : au niveau normal,
/// aucune couche supplémentaire n'est créée et le rendu ne coûte rien de
/// plus qu'avant.
class ContrastFilter {
  const ContrastFilter._();

  /// Les trois niveaux proposés. 1.0 = aucun filtre.
  static const double normal = 1.0;
  static const double renforce = 1.25;
  static const double maximum = 1.5;

  static const List<double> levels = [normal, renforce, maximum];

  static String labelFor(double level) {
    if (level <= 1.05) return 'Normal';
    if (level <= 1.3) return 'Renforcé';
    return 'Maximum';
  }

  /// Écarte les tons moyens du gris central, sans déplacer les teintes.
  ///
  /// Le pivot est le gris 50 % : au-dessus les couleurs s'éclaircissent,
  /// en dessous elles s'assombrissent. Les blancs restent blancs (la
  /// valeur sature à 255), et les gris de texte deviennent nettement plus
  /// sombres — c'est l'effet recherché.
  static ColorFilter matrixFor(double level) {
    final t = 127.5 * (1 - level);
    return ColorFilter.matrix(<double>[
      level, 0, 0, 0, t,
      0, level, 0, 0, t,
      0, 0, level, 0, t,
      0, 0, 0, 1, 0,
    ]);
  }

  /// Enveloppe [child] si besoin, et le rend tel quel sinon.
  static Widget wrap({required double level, required Widget child}) {
    if (level <= normal) return child;
    return ColorFiltered(colorFilter: matrixFor(level), child: child);
  }
}
