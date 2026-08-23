/// Marché des nombres — composer une quantité avec des jetons.
///
/// Même principe que les barres de nombres, mais avec des grandeurs de la
/// vie courante : de l'argent, des poids, des contenances, des longueurs.
/// Ici les valeurs ne sont pas des puissances de dix bien rangées, donc
/// il faut choisir : c'est justement ce qu'on travaille.
///
/// Tout est stocké en nombres entiers dans la plus petite unité (centime,
/// gramme, millilitre, centimètre). Aucun calcul en virgule flottante :
/// l'égalité avec la cible doit être exacte.
library;

enum MarketUnit { euro, gramme, litre, metre }

extension MarketUnitInfo on MarketUnit {
  String get emoji => switch (this) {
        MarketUnit.euro => '🪙',
        MarketUnit.gramme => '⚖️',
        MarketUnit.litre => '🥤',
        MarketUnit.metre => '📏',
      };

  String get stallName => switch (this) {
        MarketUnit.euro => 'Le stand de la monnaie',
        MarketUnit.gramme => 'Le stand de la balance',
        MarketUnit.litre => 'Le stand des bouteilles',
        MarketUnit.metre => 'Le stand du mètre ruban',
      };

  /// Le nom du geste, pour la consigne.
  String get verb => switch (this) {
        MarketUnit.euro => 'Compose la somme',
        MarketUnit.gramme => 'Compose la masse',
        MarketUnit.litre => 'Compose la contenance',
        MarketUnit.metre => 'Compose la longueur',
      };

  /// Met en forme une valeur exprimée dans la plus petite unité.
  String format(int value) {
    switch (this) {
      case MarketUnit.euro:
        final e = value ~/ 100;
        final c = value % 100;
        if (e == 0) return '$c c';
        if (c == 0) return '$e €';
        return '$e € ${c.toString().padLeft(2, '0')}';
      case MarketUnit.gramme:
        final kg = value ~/ 1000;
        final g = value % 1000;
        if (kg == 0) return '$g g';
        if (g == 0) return '$kg kg';
        return '$kg kg $g g';
      case MarketUnit.litre:
        final l = value ~/ 1000;
        final ml = value % 1000;
        if (l == 0) return '$ml mL';
        if (ml == 0) return '$l L';
        return '$l L $ml mL';
      case MarketUnit.metre:
        final m = value ~/ 100;
        final cm = value % 100;
        if (m == 0) return '$cm cm';
        if (cm == 0) return '$m m';
        return '$m m $cm cm';
    }
  }
}

class MarketMission {
  final String id;
  final String level;
  final String competence;
  final String missionType;

  final MarketUnit unit;

  /// Ce qu'on achète / pèse / mesure, pour donner un contexte concret.
  final String objective;
  final String itemEmoji;

  /// La quantité à atteindre, dans la plus petite unité.
  final int target;

  /// Les jetons disponibles, dans la plus petite unité.
  /// Chacun peut être utilisé autant de fois que nécessaire.
  final List<int> tokens;

  final List<String> hints;

  const MarketMission({
    required this.id,
    required this.level,
    required this.competence,
    required this.missionType,
    required this.unit,
    required this.objective,
    required this.itemEmoji,
    required this.target,
    required this.tokens,
    required this.hints,
  });
}

class MarketData {
  static List<MarketMission> forLevel(String level) =>
      level == 'CE2' ? ce2 : ce1;

  // Jetons courants, du plus grand au plus petit.
  static const List<int> _piecesCE1 = [200, 100, 50, 20, 10, 5, 2, 1];
  static const List<int> _piecesSimples = [100, 50, 20, 10];
  static const List<int> _regle = [100, 50, 10, 5, 1];
  static const List<int> _poids = [1000, 500, 200, 100, 50, 10];
  static const List<int> _contenants = [1000, 500, 250, 100, 50];

  // ══════════════════════════════════════════════════════════
  // CE1 — monnaie et longueurs
  // ══════════════════════════════════════════════════════════
  static const List<MarketMission> ce1 = [
    MarketMission(
      id: 'mk_ce1_01',
      level: 'CE1',
      competence: 'monnaie_ce1',
      missionType: 'Je découvre',
      unit: MarketUnit.euro,
      objective: 'Paye le pain',
      itemEmoji: '🥖',
      target: 130,
      tokens: _piecesSimples,
      hints: [
        '1 € 30, c\'est 1 euro et 30 centimes.',
        'Commence par la pièce de 1 € : il en faut une.',
        'Pour les 30 centimes : une pièce de 20 et une de 10.',
      ],
    ),
    MarketMission(
      id: 'mk_ce1_02',
      level: 'CE1',
      competence: 'monnaie_ce1',
      missionType: 'Je consolide',
      unit: MarketUnit.euro,
      objective: 'Paye les fraises',
      itemEmoji: '🍓',
      target: 275,
      tokens: _piecesCE1,
      hints: [
        '2 € 75, c\'est 2 euros et 75 centimes.',
        'Prends d\'abord la pièce de 2 €.',
        'Pour 75 centimes : 50 + 20 + 5.',
      ],
    ),
    MarketMission(
      id: 'mk_ce1_03',
      level: 'CE1',
      competence: 'monnaie_ce1',
      missionType: 'Je réussis',
      unit: MarketUnit.euro,
      objective: 'Paye le livre',
      itemEmoji: '📕',
      target: 487,
      tokens: _piecesCE1,
      hints: [
        '4 € 87, c\'est 4 euros et 87 centimes.',
        'Pour 4 € : deux pièces de 2 €.',
        'Pour 87 centimes : 50 + 20 + 10 + 5 + 2.',
      ],
    ),
    MarketMission(
      id: 'mk_ce1_04',
      level: 'CE1',
      competence: 'longueurs_ce1',
      missionType: 'Je découvre',
      unit: MarketUnit.metre,
      objective: 'Mesure le ruban',
      itemEmoji: '🎀',
      target: 60,
      tokens: _regle,
      hints: [
        '60 cm, c\'est moins d\'un mètre.',
        'Un mètre entier ferait 100 cm : c\'est trop.',
        'Prends une réglette de 50 cm et une de 10 cm.',
      ],
    ),
    MarketMission(
      id: 'mk_ce1_05',
      level: 'CE1',
      competence: 'longueurs_ce1',
      missionType: 'Je consolide',
      unit: MarketUnit.metre,
      objective: 'Mesure la planche',
      itemEmoji: '🪵',
      target: 165,
      tokens: _regle,
      hints: [
        '1 m 65, c\'est 1 mètre et 65 centimètres.',
        'Commence par la réglette de 100 cm : c\'est le mètre.',
        'Pour 65 cm : 50 + 10 + 5.',
      ],
    ),
    MarketMission(
      id: 'mk_ce1_06',
      level: 'CE1',
      competence: 'longueurs_ce1',
      missionType: 'Je réussis',
      unit: MarketUnit.metre,
      objective: 'Mesure la corde',
      itemEmoji: '🪢',
      target: 238,
      tokens: _regle,
      hints: [
        '2 m 38, c\'est 2 mètres et 38 centimètres.',
        'Deux réglettes de 100 cm pour les mètres.',
        'Pour 38 cm : 10 + 10 + 10 + 5 + 1 + 1 + 1.',
      ],
    ),
  ];

  // ══════════════════════════════════════════════════════════
  // CE2 — masses et contenances
  // ══════════════════════════════════════════════════════════
  static const List<MarketMission> ce2 = [
    MarketMission(
      id: 'mk_ce2_01',
      level: 'CE2',
      competence: 'masses_ce2',
      missionType: 'Je découvre',
      unit: MarketUnit.gramme,
      objective: 'Pèse les pommes',
      itemEmoji: '🍎',
      target: 700,
      tokens: _poids,
      hints: [
        '700 g, c\'est moins d\'un kilo.',
        'Le poids de 1 000 g serait trop lourd.',
        'Prends 500 g et 200 g.',
      ],
    ),
    MarketMission(
      id: 'mk_ce2_02',
      level: 'CE2',
      competence: 'masses_ce2',
      missionType: 'Je consolide',
      unit: MarketUnit.gramme,
      objective: 'Pèse la farine',
      itemEmoji: '🌾',
      target: 1250,
      tokens: _poids,
      hints: [
        '1 kg 250, c\'est 1 000 g plus 250 g.',
        'Commence par le poids de 1 kg.',
        'Pour 250 g : 200 + 50.',
      ],
    ),
    MarketMission(
      id: 'mk_ce2_03',
      level: 'CE2',
      competence: 'masses_ce2',
      missionType: 'Je réussis',
      unit: MarketUnit.gramme,
      objective: 'Pèse les cerises',
      itemEmoji: '🍒',
      target: 2360,
      tokens: _poids,
      hints: [
        '2 kg 360, c\'est 2 000 g plus 360 g.',
        'Deux poids de 1 kg pour commencer.',
        'Pour 360 g : 200 + 100 + 50 + 10.',
      ],
    ),
    MarketMission(
      id: 'mk_ce2_04',
      level: 'CE2',
      competence: 'contenances_ce2',
      missionType: 'Je découvre',
      unit: MarketUnit.litre,
      objective: 'Remplis la carafe',
      itemEmoji: '🏺',
      target: 750,
      tokens: _contenants,
      hints: [
        '750 mL, c\'est moins d\'un litre.',
        'Une bouteille de 1 L déborderait.',
        'Prends 500 mL et 250 mL.',
      ],
    ),
    MarketMission(
      id: 'mk_ce2_05',
      level: 'CE2',
      competence: 'contenances_ce2',
      missionType: 'Je consolide',
      unit: MarketUnit.litre,
      objective: 'Remplis le seau',
      itemEmoji: '🪣',
      target: 1600,
      tokens: _contenants,
      hints: [
        '1 L 600, c\'est 1 000 mL plus 600 mL.',
        'Commence par la bouteille de 1 L.',
        'Pour 600 mL : 500 + 100.',
      ],
    ),
    MarketMission(
      id: 'mk_ce2_06',
      level: 'CE2',
      competence: 'contenances_ce2',
      missionType: 'Je réussis',
      unit: MarketUnit.litre,
      objective: 'Remplis l\'arrosoir',
      itemEmoji: '🪴',
      target: 2850,
      tokens: _contenants,
      hints: [
        '2 L 850, c\'est 2 000 mL plus 850 mL.',
        'Deux bouteilles de 1 L pour commencer.',
        'Pour 850 mL : 500 + 250 + 100.',
      ],
    ),
  ];
}
