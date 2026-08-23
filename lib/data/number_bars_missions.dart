/// Micro-missions « Barres de nombres ».
///
/// Chaque mission porte une compétence explicite et un niveau de référence :
/// côté enfant on n'affiche que le nom de la mission, côté parent on peut
/// afficher la compétence exacte. Les deux vues décrivent la même donnée.
class NumberBarsMission {
  final String id;

  /// Niveau de référence ('CE1' ou 'CE2') — visible seulement côté parent.
  final String level;

  /// Compétence travaillée, pour le tableau parental.
  final String competence;

  /// Nom de la mission tel qu'Emilie le voit (jamais « niveau faible »
  /// ni « rattrapage ») : « Je découvre », « Je consolide », « Je réussis ».
  final String missionType;

  /// Consigne courte, lue à voix haute si le réglage est actif.
  final String objective;

  /// Le nombre à construire.
  final int target;

  /// Aides graduées, révélées une par une à la demande d'Emilie.
  final List<String> hints;

  const NumberBarsMission({
    required this.id,
    required this.level,
    required this.competence,
    required this.missionType,
    required this.objective,
    required this.target,
    required this.hints,
  });

  /// Le CE2 travaille aussi les milliers.
  bool get useThousands => level == 'CE2';
}

class NumberBarsData {
  static List<NumberBarsMission> forLevel(String level) =>
      level == 'CE2' ? ce2 : ce1;

  // ── CE1 : nombres jusqu'à 1 000, unités / dizaines / centaines ──
  static const List<NumberBarsMission> ce1 = [
    NumberBarsMission(
      id: 'nb_ce1_01',
      level: 'CE1',
      competence: 'composer_nombres_jusqua_100',
      missionType: 'Je découvre',
      objective: 'Construis le nombre 24',
      target: 24,
      hints: [
        '24, c\'est 2 dizaines et 4 unités.',
        'Commence par mettre 2 barres de dizaines.',
        'Ajoute ensuite 4 petits cubes.',
      ],
    ),
    NumberBarsMission(
      id: 'nb_ce1_02',
      level: 'CE1',
      competence: 'composer_nombres_jusqua_100',
      missionType: 'Je consolide',
      objective: 'Construis le nombre 57',
      target: 57,
      hints: [
        '57, c\'est 5 dizaines et 7 unités.',
        'Les dizaines sont les barres, les unités les petits cubes.',
        'Mets d\'abord les 5 barres.',
      ],
    ),
    NumberBarsMission(
      id: 'nb_ce1_03',
      level: 'CE1',
      competence: 'composer_decomposer_nombres_jusqua_1000',
      missionType: 'Je découvre',
      objective: 'Construis le nombre 130',
      target: 130,
      hints: [
        '130, c\'est 1 centaine et 3 dizaines.',
        'Il n\'y a aucune unité toute seule dans 130.',
        'Mets 1 plaque de centaine, puis 3 barres.',
      ],
    ),
    NumberBarsMission(
      id: 'nb_ce1_04',
      level: 'CE1',
      competence: 'composer_decomposer_nombres_jusqua_1000',
      missionType: 'Je consolide',
      objective: 'Construis le nombre 245',
      target: 245,
      hints: [
        '245, c\'est 2 centaines, 4 dizaines et 5 unités.',
        'Regarde bien chaque chiffre : le 2, le 4, puis le 5.',
        'Commence par les 2 plaques de centaines.',
      ],
    ),
    NumberBarsMission(
      id: 'nb_ce1_05',
      level: 'CE1',
      competence: 'composer_decomposer_nombres_jusqua_1000',
      missionType: 'Je réussis',
      objective: 'Construis le nombre 408',
      target: 408,
      hints: [
        '408, c\'est 4 centaines, 0 dizaine et 8 unités.',
        'Le zéro veut dire qu\'il n\'y a aucune barre de dizaine.',
        'Mets 4 plaques, laisse les dizaines vides, puis 8 cubes.',
      ],
    ),
    NumberBarsMission(
      id: 'nb_ce1_06',
      level: 'CE1',
      competence: 'grouper_dix_unites_en_dizaine',
      missionType: 'Je découvre',
      objective: 'Construis le nombre 60',
      target: 60,
      hints: [
        '60, c\'est 6 dizaines.',
        'Si tu mets 10 petits cubes, ils se regroupent en 1 barre !',
        'Tu peux aussi mettre directement 6 barres.',
      ],
    ),
  ];

  // ── CE2 : grands nombres, milliers ──
  static const List<NumberBarsMission> ce2 = [
    NumberBarsMission(
      id: 'nb_ce2_01',
      level: 'CE2',
      competence: 'composer_decomposer_nombres_jusqua_10000',
      missionType: 'Je découvre',
      objective: 'Construis le nombre 1 250',
      target: 1250,
      hints: [
        '1 250, c\'est 1 millier, 2 centaines et 5 dizaines.',
        'Il n\'y a aucune unité seule dans 1 250.',
        'Commence par le cube de millier.',
      ],
    ),
    NumberBarsMission(
      id: 'nb_ce2_02',
      level: 'CE2',
      competence: 'composer_decomposer_nombres_jusqua_10000',
      missionType: 'Je consolide',
      objective: 'Construis le nombre 3 407',
      target: 3407,
      hints: [
        '3 407, c\'est 3 milliers, 4 centaines, 0 dizaine et 7 unités.',
        'Attention au zéro : aucune barre de dizaine.',
        'Mets 3 cubes de milliers, puis 4 plaques.',
      ],
    ),
    NumberBarsMission(
      id: 'nb_ce2_03',
      level: 'CE2',
      competence: 'composer_decomposer_nombres_jusqua_10000',
      missionType: 'Je consolide',
      objective: 'Construis le nombre 2 036',
      target: 2036,
      hints: [
        '2 036, c\'est 2 milliers, 0 centaine, 3 dizaines et 6 unités.',
        'Le zéro des centaines : on ne met aucune plaque.',
        'Milliers, puis rien en centaines, puis 3 barres et 6 cubes.',
      ],
    ),
    NumberBarsMission(
      id: 'nb_ce2_04',
      level: 'CE2',
      competence: 'valeur_position_chiffre',
      missionType: 'Je réussis',
      objective: 'Construis le nombre 5 555',
      target: 5555,
      hints: [
        'Le même chiffre 5 n\'a pas la même valeur selon sa place !',
        '5 milliers, 5 centaines, 5 dizaines et 5 unités.',
        'Mets 5 objets dans chaque colonne.',
      ],
    ),
    NumberBarsMission(
      id: 'nb_ce2_05',
      level: 'CE2',
      competence: 'composer_decomposer_nombres_jusqua_10000',
      missionType: 'Je réussis',
      objective: 'Construis le nombre 4 090',
      target: 4090,
      hints: [
        '4 090, c\'est 4 milliers, 0 centaine, 9 dizaines et 0 unité.',
        'Deux zéros : aucune plaque de centaine, aucun cube seul.',
        'Mets 4 cubes de milliers et 9 barres de dizaines.',
      ],
    ),
    NumberBarsMission(
      id: 'nb_ce2_06',
      level: 'CE2',
      competence: 'grouper_dix_unites_en_dizaine',
      missionType: 'Je découvre',
      objective: 'Construis le nombre 1 000',
      target: 1000,
      hints: [
        '1 000, c\'est 1 millier.',
        '10 plaques de centaines se regroupent en 1 cube de millier !',
        'Tu peux aussi mettre directement 1 cube de millier.',
      ],
    ),
  ];
}
