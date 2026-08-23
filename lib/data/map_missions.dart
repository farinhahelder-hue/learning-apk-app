/// Carte au trésor — se repérer et se déplacer sur un plan.
///
/// CE1 : on se déplace avec des flèches (haut, bas, gauche, droite).
/// CE2 : les mêmes déplacements, mais nommés nord, sud, est et ouest,
/// avec une rose des vents affichée en permanence. Le repère ne change
/// pas — seul le vocabulaire change, ce qui est exactement la marche à
/// franchir entre les deux niveaux.
///
/// Le nord est toujours vers le haut de l'écran : c'est la convention des
/// cartes, et la rose des vents le rappelle à chaque instant plutôt que
/// de demander de le retenir.
library;

class MapPlace {
  /// Colonne (0 = tout à gauche) et ligne (0 = tout en haut).
  final int col;
  final int row;

  final String emoji;
  final String label;

  const MapPlace({
    required this.col,
    required this.row,
    required this.emoji,
    required this.label,
  });
}

class MapMission {
  final String id;
  final String level;
  final String competence;
  final String missionType;

  final int cols;
  final int rows;
  final List<MapPlace> places;

  /// Libellés des lieux de départ et d'arrivée, à retrouver dans [places].
  final String startLabel;
  final String targetLabel;

  /// true pour le CE2 : nord / sud / est / ouest au lieu des flèches.
  final bool cardinal;

  /// Ce qu'on raconte pour donner envie d'y aller.
  final String story;

  final List<String> hints;

  const MapMission({
    required this.id,
    required this.level,
    required this.competence,
    required this.missionType,
    required this.cols,
    required this.rows,
    required this.places,
    required this.startLabel,
    required this.targetLabel,
    required this.cardinal,
    required this.story,
    required this.hints,
  });

  MapPlace get start => places.firstWhere((p) => p.label == startLabel);
  MapPlace get target => places.firstWhere((p) => p.label == targetLabel);

  /// Nombre minimum de déplacements : on ne se déplace qu'en ligne droite,
  /// donc c'est la distance de Manhattan.
  int get minimumMoves =>
      (target.col - start.col).abs() + (target.row - start.row).abs();
}

class MapMissionsData {
  static List<MapMission> forLevel(String level) =>
      level == 'CE2' ? ce2 : ce1;

  // Le plan du village, partagé par les missions CE1.
  static const List<MapPlace> _village = [
    MapPlace(col: 0, row: 0, emoji: '🏫', label: 'l\'école'),
    MapPlace(col: 3, row: 0, emoji: '🌳', label: 'le parc'),
    MapPlace(col: 1, row: 1, emoji: '🥖', label: 'la boulangerie'),
    MapPlace(col: 4, row: 1, emoji: '⛲', label: 'la fontaine'),
    MapPlace(col: 2, row: 2, emoji: '🏠', label: 'la maison'),
    MapPlace(col: 0, row: 3, emoji: '📚', label: 'la bibliothèque'),
    MapPlace(col: 3, row: 3, emoji: '🏊', label: 'la piscine'),
    MapPlace(col: 1, row: 4, emoji: '🛒', label: 'le marché'),
    MapPlace(col: 4, row: 4, emoji: '🚉', label: 'la gare'),
  ];

  // L'île au trésor, partagée par les missions CE2.
  static const List<MapPlace> _island = [
    MapPlace(col: 2, row: 0, emoji: '⛵', label: 'le bateau'),
    MapPlace(col: 0, row: 1, emoji: '🌴', label: 'les palmiers'),
    MapPlace(col: 4, row: 1, emoji: '🗻', label: 'le volcan'),
    MapPlace(col: 2, row: 2, emoji: '🏕️', label: 'le campement'),
    MapPlace(col: 0, row: 3, emoji: '🕳️', label: 'la grotte'),
    MapPlace(col: 4, row: 3, emoji: '💧', label: 'la cascade'),
    MapPlace(col: 1, row: 4, emoji: '🦜', label: 'le nid'),
    MapPlace(col: 3, row: 4, emoji: '💰', label: 'le trésor'),
  ];

  // ══════════════════════════════════════════════════════════
  // CE1 — flèches, plan du village
  // ══════════════════════════════════════════════════════════
  static const List<MapMission> ce1 = [
    MapMission(
      id: 'mp_ce1_01',
      level: 'CE1',
      competence: 'se_reperer_espace_ce1',
      missionType: 'Je découvre',
      cols: 5,
      rows: 5,
      places: _village,
      startLabel: 'l\'école',
      targetLabel: 'la boulangerie',
      cardinal: false,
      story: 'Après l\'école, Bébé Phoque va chercher du pain.',
      hints: [
        'La boulangerie est un peu plus bas et un peu à droite.',
        'Descends d\'une case, puis va d\'une case vers la droite.',
        'Il faut deux déplacements en tout.',
      ],
    ),
    MapMission(
      id: 'mp_ce1_02',
      level: 'CE1',
      competence: 'se_reperer_espace_ce1',
      missionType: 'Je consolide',
      cols: 5,
      rows: 5,
      places: _village,
      startLabel: 'la maison',
      targetLabel: 'le marché',
      cardinal: false,
      story: 'Papa Écureuil part faire les courses au marché.',
      hints: [
        'Le marché est plus bas que la maison, et vers la gauche.',
        'Descends de deux cases, puis va d\'une case vers la gauche.',
        'Il faut trois déplacements en tout.',
      ],
    ),
    MapMission(
      id: 'mp_ce1_03',
      level: 'CE1',
      competence: 'se_reperer_espace_ce1',
      missionType: 'Je réussis',
      cols: 5,
      rows: 5,
      places: _village,
      startLabel: 'la bibliothèque',
      targetLabel: 'la fontaine',
      cardinal: false,
      story: 'Ninon a fini son livre. Elle rejoint ses amis à la fontaine.',
      hints: [
        'La fontaine est bien plus haut, et tout à droite.',
        'Monte de deux cases, puis va vers la droite.',
        'Il faut six déplacements en tout.',
      ],
    ),
  ];

  // ══════════════════════════════════════════════════════════
  // CE2 — points cardinaux, île au trésor
  // ══════════════════════════════════════════════════════════
  static const List<MapMission> ce2 = [
    MapMission(
      id: 'mp_ce2_01',
      level: 'CE2',
      competence: 'points_cardinaux_ce2',
      missionType: 'Je découvre',
      cols: 5,
      rows: 5,
      places: _island,
      startLabel: 'le bateau',
      targetLabel: 'le campement',
      cardinal: true,
      story: 'L\'équipage débarque et rejoint le campement.',
      hints: [
        'Sur une carte, le nord est vers le haut : va donc vers le sud.',
        'Le campement est juste en dessous du bateau.',
        'Il faut deux déplacements vers le sud.',
      ],
    ),
    MapMission(
      id: 'mp_ce2_02',
      level: 'CE2',
      competence: 'points_cardinaux_ce2',
      missionType: 'Je consolide',
      cols: 5,
      rows: 5,
      places: _island,
      startLabel: 'le campement',
      targetLabel: 'la cascade',
      cardinal: true,
      story: 'Il faut aller remplir les gourdes à la cascade.',
      hints: [
        'La cascade est à droite sur la carte : c\'est l\'est.',
        'Elle est aussi plus bas : c\'est le sud.',
        'Deux déplacements vers l\'est, un vers le sud.',
      ],
    ),
    MapMission(
      id: 'mp_ce2_03',
      level: 'CE2',
      competence: 'points_cardinaux_ce2',
      missionType: 'Je réussis',
      cols: 5,
      rows: 5,
      places: _island,
      startLabel: 'la grotte',
      targetLabel: 'le trésor',
      cardinal: true,
      story: 'La carte de Barbe Noire mène enfin au trésor.',
      hints: [
        'Le trésor est à droite de la grotte : vers l\'est.',
        'Il est aussi un peu plus bas : vers le sud.',
        'Trois déplacements vers l\'est, un vers le sud.',
      ],
    ),
  ];
}
