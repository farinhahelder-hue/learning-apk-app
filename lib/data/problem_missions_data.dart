/// Mission-problème — résoudre un problème étape par étape.
///
/// Le découpage est volontairement explicite : lire, choisir l'opération,
/// puis donner le résultat. Le schéma en barres est un échafaudage
/// proposé à la demande, jamais imposé.

enum ProblemOp { ajouter, retirer, partager, comparer }

extension ProblemOpInfo on ProblemOp {
  String get label => switch (this) {
        ProblemOp.ajouter => 'Ajouter',
        ProblemOp.retirer => 'Retirer',
        ProblemOp.partager => 'Partager',
        ProblemOp.comparer => 'Comparer',
      };

  String get emoji => switch (this) {
        ProblemOp.ajouter => '➕',
        ProblemOp.retirer => '➖',
        ProblemOp.partager => '➗',
        ProblemOp.comparer => '⚖️',
      };

  String get hintText => switch (this) {
        ProblemOp.ajouter => 'On met ensemble, la quantité augmente.',
        ProblemOp.retirer => 'On enlève, la quantité diminue.',
        ProblemOp.partager => 'On fait des parts égales.',
        ProblemOp.comparer => 'On cherche la différence entre deux quantités.',
      };

  int get colorValue => switch (this) {
        ProblemOp.ajouter => 0xFF66BB6A,
        ProblemOp.retirer => 0xFFEF5350,
        ProblemOp.partager => 0xFF42A5F5,
        ProblemOp.comparer => 0xFFFFA726,
      };
}

/// Une étape de résolution : une opération, un résultat.
class ProblemStep {
  /// La question de cette étape, formulée simplement.
  final String question;

  final ProblemOp operation;

  /// Les deux nombres manipulés à cette étape (pour le schéma en barres).
  final int a;
  final int b;

  final int result;

  /// Choix de réponse proposés (contient toujours [result]).
  final List<int> choices;

  const ProblemStep({
    required this.question,
    required this.operation,
    required this.a,
    required this.b,
    required this.result,
    required this.choices,
  });

  /// L'opération écrite, par exemple « 12 + 7 = ? ».
  String get writtenOperation {
    final sign = switch (operation) {
      ProblemOp.ajouter => '+',
      ProblemOp.retirer => '−',
      ProblemOp.partager => '÷',
      ProblemOp.comparer => '−',
    };
    return '$a $sign $b = ?';
  }
}

class ProblemMission {
  final String id;
  final String level;
  final String competence;
  final String missionType;

  /// L'énoncé complet, lu à voix haute à la demande.
  final String statement;

  /// Une ou deux étapes (CE1 : une seule ; CE2 : jusqu'à deux).
  final List<ProblemStep> steps;

  /// Phrase-réponse finale, avec l'unité.
  final String answerSentence;

  final List<String> hints;

  const ProblemMission({
    required this.id,
    required this.level,
    required this.competence,
    required this.missionType,
    required this.statement,
    required this.steps,
    required this.answerSentence,
    required this.hints,
  });
}

class ProblemMissionsData {
  static List<ProblemMission> forLevel(String level) =>
      level == 'CE2' ? ce2 : ce1;

  // ── CE1 : problèmes en une étape ──
  static const List<ProblemMission> ce1 = [
    ProblemMission(
      id: 'pb_ce1_01',
      level: 'CE1',
      competence: 'probleme_addition_une_etape_ce1',
      missionType: 'Je découvre',
      statement:
          'Emilie a 12 billes. Son frère lui en donne 7. Combien de billes a-t-elle maintenant ?',
      steps: [
        ProblemStep(
          question: 'Combien de billes en tout ?',
          operation: ProblemOp.ajouter,
          a: 12, b: 7, result: 19,
          choices: [17, 19, 21, 5],
        ),
      ],
      answerSentence: 'Emilie a 19 billes.',
      hints: [
        'Elle en avait déjà, et on lui en donne encore : la quantité augmente.',
        'C\'est une addition : 12 + 7.',
        '12 + 7 = 19.',
      ],
    ),
    ProblemMission(
      id: 'pb_ce1_02',
      level: 'CE1',
      competence: 'probleme_soustraction_une_etape_ce1',
      missionType: 'Je consolide',
      statement:
          'Il y a 20 gâteaux dans la boîte. Les enfants en mangent 8. Combien reste-t-il de gâteaux ?',
      steps: [
        ProblemStep(
          question: 'Combien de gâteaux restent ?',
          operation: ProblemOp.retirer,
          a: 20, b: 8, result: 12,
          choices: [12, 28, 10, 18],
        ),
      ],
      answerSentence: 'Il reste 12 gâteaux.',
      hints: [
        'On mange des gâteaux : la quantité diminue.',
        'C\'est une soustraction : 20 − 8.',
        '20 − 8 = 12.',
      ],
    ),
    ProblemMission(
      id: 'pb_ce1_03',
      level: 'CE1',
      competence: 'probleme_comparaison_ce1',
      missionType: 'Je consolide',
      statement:
          'Léa a 15 images. Tom en a 9. Combien Léa a-t-elle d\'images de plus que Tom ?',
      steps: [
        ProblemStep(
          question: 'Combien d\'images de plus ?',
          operation: ProblemOp.comparer,
          a: 15, b: 9, result: 6,
          choices: [6, 24, 4, 9],
        ),
      ],
      answerSentence: 'Léa a 6 images de plus que Tom.',
      hints: [
        'On veut savoir l\'écart entre les deux quantités.',
        'Pour comparer, on soustrait : 15 − 9.',
        '15 − 9 = 6.',
      ],
    ),
    ProblemMission(
      id: 'pb_ce1_04',
      level: 'CE1',
      competence: 'probleme_addition_une_etape_ce1',
      missionType: 'Je réussis',
      statement:
          'Dans le bus il y a 24 personnes. À l\'arrêt, 13 personnes montent. Combien de personnes y a-t-il dans le bus ?',
      steps: [
        ProblemStep(
          question: 'Combien de personnes en tout ?',
          operation: ProblemOp.ajouter,
          a: 24, b: 13, result: 37,
          choices: [37, 11, 27, 34],
        ),
      ],
      answerSentence: 'Il y a 37 personnes dans le bus.',
      hints: [
        'Des personnes montent : il y en a plus qu\'avant.',
        'C\'est une addition : 24 + 13.',
        '24 + 13 = 37.',
      ],
    ),
  ];

  // ── CE2 : partage et problèmes en deux étapes ──
  static const List<ProblemMission> ce2 = [
    ProblemMission(
      id: 'pb_ce2_01',
      level: 'CE2',
      competence: 'probleme_partage_ce2',
      missionType: 'Je découvre',
      statement:
          'On partage 24 bonbons entre 4 enfants, de façon équitable. Combien de bonbons reçoit chaque enfant ?',
      steps: [
        ProblemStep(
          question: 'Combien de bonbons pour chaque enfant ?',
          operation: ProblemOp.partager,
          a: 24, b: 4, result: 6,
          choices: [6, 8, 20, 28],
        ),
      ],
      answerSentence: 'Chaque enfant reçoit 6 bonbons.',
      hints: [
        'Partager équitablement, c\'est faire des parts égales.',
        'C\'est une division : 24 ÷ 4.',
        '24 ÷ 4 = 6.',
      ],
    ),
    ProblemMission(
      id: 'pb_ce2_02',
      level: 'CE2',
      competence: 'probleme_deux_etapes_ce2',
      missionType: 'Je consolide',
      statement:
          'Paul achète 2 paquets de 9 stylos. Il en donne 5 à sa sœur. Combien de stylos lui reste-t-il ?',
      steps: [
        ProblemStep(
          question: 'Étape 1 : combien de stylos a-t-il achetés en tout ?',
          operation: ProblemOp.ajouter,
          a: 9, b: 9, result: 18,
          choices: [18, 11, 9, 27],
        ),
        ProblemStep(
          question: 'Étape 2 : combien lui en reste-t-il après en avoir donné 5 ?',
          operation: ProblemOp.retirer,
          a: 18, b: 5, result: 13,
          choices: [13, 23, 11, 15],
        ),
      ],
      answerSentence: 'Il lui reste 13 stylos.',
      hints: [
        'Ce problème demande DEUX étapes.',
        'D\'abord le total : 2 paquets de 9, c\'est 9 + 9 = 18.',
        'Ensuite on retire 5 : 18 − 5 = 13.',
      ],
    ),
    ProblemMission(
      id: 'pb_ce2_03',
      level: 'CE2',
      competence: 'probleme_deux_etapes_ce2',
      missionType: 'Je consolide',
      statement:
          'Une boîte contient 40 perles. On en utilise 15, puis on en ajoute 9. Combien de perles y a-t-il dans la boîte ?',
      steps: [
        ProblemStep(
          question: 'Étape 1 : combien reste-t-il après en avoir utilisé 15 ?',
          operation: ProblemOp.retirer,
          a: 40, b: 15, result: 25,
          choices: [25, 55, 35, 15],
        ),
        ProblemStep(
          question: 'Étape 2 : combien après en avoir ajouté 9 ?',
          operation: ProblemOp.ajouter,
          a: 25, b: 9, result: 34,
          choices: [34, 16, 31, 44],
        ),
      ],
      answerSentence: 'Il y a 34 perles dans la boîte.',
      hints: [
        'Ce problème demande DEUX étapes, dans l\'ordre.',
        'D\'abord on enlève : 40 − 15 = 25.',
        'Ensuite on ajoute : 25 + 9 = 34.',
      ],
    ),
    ProblemMission(
      id: 'pb_ce2_04',
      level: 'CE2',
      competence: 'probleme_partage_ce2',
      missionType: 'Je réussis',
      statement:
          'Un fleuriste a 56 roses. Il fait des bouquets de 8 roses. Combien de bouquets peut-il faire ?',
      steps: [
        ProblemStep(
          question: 'Combien de bouquets ?',
          operation: ProblemOp.partager,
          a: 56, b: 8, result: 7,
          choices: [7, 6, 48, 64],
        ),
      ],
      answerSentence: 'Il peut faire 7 bouquets.',
      hints: [
        'On fait des groupes égaux de 8 roses.',
        'C\'est une division : 56 ÷ 8.',
        '56 ÷ 8 = 7.',
      ],
    ),
    ProblemMission(
      id: 'pb_ce2_05',
      level: 'CE2',
      competence: 'division_partage_ce2',
      missionType: 'Je découvre',
      statement:
          'Emilie range 18 crayons dans 3 trousses, autant dans chacune. '
          'Combien de crayons dans chaque trousse ?',
      steps: [
        ProblemStep(
          question: 'Combien de crayons dans chaque trousse ?',
          operation: ProblemOp.partager,
          a: 18, b: 3, result: 6,
          choices: [6, 5, 15, 21],
        ),
      ],
      answerSentence: 'Il y a 6 crayons dans chaque trousse.',
      hints: [
        'Autant dans chacune : les parts sont égales.',
        'C\'est une division : 18 ÷ 3.',
        '18 ÷ 3 = 6.',
      ],
    ),
    ProblemMission(
      id: 'pb_ce2_06',
      level: 'CE2',
      competence: 'division_partage_ce2',
      missionType: 'Je réussis',
      statement:
          'Un maître-nageur répartit 35 enfants en 5 groupes égaux. '
          'Combien d\'enfants dans chaque groupe ?',
      steps: [
        ProblemStep(
          question: 'Combien d\'enfants par groupe ?',
          operation: ProblemOp.partager,
          a: 35, b: 5, result: 7,
          choices: [7, 6, 30, 40],
        ),
      ],
      answerSentence: 'Il y a 7 enfants dans chaque groupe.',
      hints: [
        'Des groupes égaux : chacun a le même nombre d\'enfants.',
        'C\'est une division : 35 ÷ 5.',
        '35 ÷ 5 = 7.',
      ],
    ),
  ];
}
