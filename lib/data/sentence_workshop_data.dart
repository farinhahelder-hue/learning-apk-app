/// Chantier des phrases — construire, analyser et accorder.
///
/// Les natures de mots utilisent un code couleur inspiré de Montessori,
/// mais le nom de la nature est TOUJOURS écrit à côté : Emilie n'a jamais
/// à deviner une forme géométrique de mémoire.

enum WordNature { determinant, nom, verbe, adjectif, complement }

extension WordNatureInfo on WordNature {
  String get label => switch (this) {
        WordNature.determinant => 'déterminant',
        WordNature.nom => 'nom',
        WordNature.verbe => 'verbe',
        WordNature.adjectif => 'adjectif',
        WordNature.complement => 'complément',
      };

  /// Repère visuel secondaire, jamais utilisé seul.
  String get symbol => switch (this) {
        WordNature.determinant => '▵',
        WordNature.nom => '▲',
        WordNature.verbe => '●',
        WordNature.adjectif => '△',
        WordNature.complement => '▬',
      };

  /// Couleur (valeur ARGB, convertie en Color côté écran).
  int get colorValue => switch (this) {
        WordNature.determinant => 0xFF64B5F6, // bleu clair
        WordNature.nom => 0xFF1565C0, // bleu foncé
        WordNature.verbe => 0xFFE53935, // rouge
        WordNature.adjectif => 0xFF7E57C2, // violet
        WordNature.complement => 0xFF66BB6A, // vert
      };
}

class SentenceWord {
  final String text;
  final WordNature nature;
  const SentenceWord(this.text, this.nature);
}

/// Trois types de missions, toutes sur le même principe : une seule
/// intention pédagogique par mission.
enum SentenceKind {
  /// Remettre les mots dans l'ordre pour former une phrase.
  construire,

  /// Toucher le mot d'une nature donnée (le verbe, le nom…).
  reperer,

  /// Choisir la forme correctement accordée.
  accorder,
}

class SentenceMission {
  final String id;
  final String level;
  final String competence;
  final String missionType;
  final String objective;
  final SentenceKind kind;

  /// Les mots dans le BON ordre (mélangés à l'affichage pour `construire`).
  final List<SentenceWord> words;

  /// Pour `reperer` : la nature à retrouver.
  final WordNature? targetNature;

  /// Pour `accorder` : la phrase à trous, les choix, et la bonne réponse.
  final String? gapSentence;
  final List<String>? choices;
  final String? answer;

  final List<String> hints;

  const SentenceMission({
    required this.id,
    required this.level,
    required this.competence,
    required this.missionType,
    required this.objective,
    required this.kind,
    required this.hints,
    this.words = const [],
    this.targetNature,
    this.gapSentence,
    this.choices,
    this.answer,
  });

  /// La phrase correcte, reconstituée.
  String get sentence {
    if (words.isEmpty) return '';
    final buffer = StringBuffer();
    for (var i = 0; i < words.length; i++) {
      if (i > 0) buffer.write(' ');
      buffer.write(i == 0 ? _capitalise(words[i].text) : words[i].text);
    }
    buffer.write('.');
    return buffer.toString();
  }

  static String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class SentenceWorkshopData {
  static List<SentenceMission> forLevel(String level) =>
      level == 'CE2' ? ce2 : ce1;

  // ── CE1 : nom, déterminant, verbe, accords simples ──
  static const List<SentenceMission> ce1 = [
    SentenceMission(
      id: 'sw_ce1_01',
      level: 'CE1',
      competence: 'construire_phrase_simple_ce1',
      missionType: 'Je découvre',
      objective: 'Remets les mots dans l\'ordre',
      kind: SentenceKind.construire,
      words: [
        SentenceWord('le', WordNature.determinant),
        SentenceWord('chat', WordNature.nom),
        SentenceWord('dort', WordNature.verbe),
      ],
      hints: [
        'Une phrase commence souvent par un déterminant.',
        'Le déterminant est juste avant le nom : « le chat ».',
        'Le verbe dit ce que fait le chat.',
      ],
    ),
    SentenceMission(
      id: 'sw_ce1_02',
      level: 'CE1',
      competence: 'construire_phrase_simple_ce1',
      missionType: 'Je consolide',
      objective: 'Remets les mots dans l\'ordre',
      kind: SentenceKind.construire,
      words: [
        SentenceWord('la', WordNature.determinant),
        SentenceWord('fille', WordNature.nom),
        SentenceWord('mange', WordNature.verbe),
        SentenceWord('une pomme', WordNature.complement),
      ],
      hints: [
        'Commence par qui fait l\'action : « la fille ».',
        'Ensuite vient le verbe : que fait-elle ?',
        'Le complément vient à la fin : ce qu\'elle mange.',
      ],
    ),
    SentenceMission(
      id: 'sw_ce1_03',
      level: 'CE1',
      competence: 'reperer_le_verbe_ce1',
      missionType: 'Je découvre',
      objective: 'Touche le VERBE de la phrase',
      kind: SentenceKind.reperer,
      targetNature: WordNature.verbe,
      words: [
        SentenceWord('le', WordNature.determinant),
        SentenceWord('garçon', WordNature.nom),
        SentenceWord('court', WordNature.verbe),
      ],
      hints: [
        'Le verbe dit ce que quelqu\'un FAIT.',
        'Essaie : « le garçon est en train de... » ?',
        'C\'est le mot « court ».',
      ],
    ),
    SentenceMission(
      id: 'sw_ce1_04',
      level: 'CE1',
      competence: 'reperer_le_nom_ce1',
      missionType: 'Je consolide',
      objective: 'Touche le NOM de la phrase',
      kind: SentenceKind.reperer,
      targetNature: WordNature.nom,
      words: [
        SentenceWord('une', WordNature.determinant),
        SentenceWord('fleur', WordNature.nom),
        SentenceWord('pousse', WordNature.verbe),
      ],
      hints: [
        'Le nom désigne une chose, un animal ou une personne.',
        'Il vient juste après le déterminant « une ».',
        'C\'est le mot « fleur ».',
      ],
    ),
    SentenceMission(
      id: 'sw_ce1_05',
      level: 'CE1',
      competence: 'accord_sujet_verbe_ce1',
      missionType: 'Je réussis',
      objective: 'Choisis la bonne forme du verbe',
      kind: SentenceKind.accorder,
      gapSentence: 'Les chats ___ sur le canapé.',
      choices: ['dorment', 'dort'],
      answer: 'dorment',
      hints: [
        'Combien y a-t-il de chats ?',
        'Quand il y en a plusieurs, le verbe change aussi.',
        'Avec « les chats », on écrit « dorment ».',
      ],
    ),
    SentenceMission(
      id: 'sw_ce1_06',
      level: 'CE1',
      competence: 'accord_sujet_verbe_ce1',
      missionType: 'Je réussis',
      objective: 'Choisis la bonne forme du verbe',
      kind: SentenceKind.accorder,
      gapSentence: 'Mon frère ___ à la balle.',
      choices: ['joue', 'jouent'],
      answer: 'joue',
      hints: [
        'Il n\'y a qu\'une seule personne : mon frère.',
        'Avec une seule personne, le verbe reste au singulier.',
        'On écrit « joue ».',
      ],
    ),
  ];

  // ── CE2 : groupe nominal, adjectifs, accords plus complexes ──
  static const List<SentenceMission> ce2 = [
    SentenceMission(
      id: 'sw_ce2_01',
      level: 'CE2',
      competence: 'groupe_nominal_enrichi_ce2',
      missionType: 'Je découvre',
      objective: 'Remets les mots dans l\'ordre',
      kind: SentenceKind.construire,
      words: [
        SentenceWord('ma', WordNature.determinant),
        SentenceWord('grande', WordNature.adjectif),
        SentenceWord('sœur', WordNature.nom),
        SentenceWord('lit', WordNature.verbe),
        SentenceWord('un livre', WordNature.complement),
      ],
      hints: [
        'Le groupe nominal complet est « ma grande sœur ».',
        'L\'adjectif « grande » se place avant le nom ici.',
        'Ensuite viennent le verbe puis le complément.',
      ],
    ),
    SentenceMission(
      id: 'sw_ce2_02',
      level: 'CE2',
      competence: 'construire_phrase_avec_complement_ce2',
      missionType: 'Je consolide',
      objective: 'Remets les mots dans l\'ordre',
      kind: SentenceKind.construire,
      words: [
        SentenceWord('les', WordNature.determinant),
        SentenceWord('enfants', WordNature.nom),
        SentenceWord('jouent', WordNature.verbe),
        SentenceWord('dans le jardin', WordNature.complement),
      ],
      hints: [
        'Qui fait l\'action ? « les enfants ».',
        'Le verbe vient juste après le groupe sujet.',
        'Le complément dit OÙ ils jouent.',
      ],
    ),
    SentenceMission(
      id: 'sw_ce2_03',
      level: 'CE2',
      competence: 'reperer_adjectif_ce2',
      missionType: 'Je consolide',
      objective: 'Touche l\'ADJECTIF de la phrase',
      kind: SentenceKind.reperer,
      targetNature: WordNature.adjectif,
      words: [
        SentenceWord('un', WordNature.determinant),
        SentenceWord('vieux', WordNature.adjectif),
        SentenceWord('arbre', WordNature.nom),
        SentenceWord('tombe', WordNature.verbe),
      ],
      hints: [
        'L\'adjectif dit COMMENT est le nom.',
        'Il donne une information sur l\'arbre.',
        'C\'est le mot « vieux ».',
      ],
    ),
    SentenceMission(
      id: 'sw_ce2_04',
      level: 'CE2',
      competence: 'accord_nom_adjectif_ce2',
      missionType: 'Je réussis',
      objective: 'Choisis la bonne forme de l\'adjectif',
      kind: SentenceKind.accorder,
      gapSentence: 'Les fleurs sont ___.',
      choices: ['belles', 'beau', 'belle'],
      answer: 'belles',
      hints: [
        'Les fleurs : féminin et pluriel.',
        'L\'adjectif doit s\'accorder avec le nom.',
        'On écrit « belles » : féminin pluriel.',
      ],
    ),
    SentenceMission(
      id: 'sw_ce2_05',
      level: 'CE2',
      competence: 'conjugaison_imparfait_ce2',
      missionType: 'Je réussis',
      objective: 'Choisis le verbe à l\'imparfait',
      kind: SentenceKind.accorder,
      gapSentence: 'Hier, nous ___ dans le parc.',
      choices: ['marchions', 'marchons', 'marcherons'],
      answer: 'marchions',
      hints: [
        '« Hier » indique le passé.',
        'À l\'imparfait avec « nous », la terminaison est -ions.',
        'On écrit « marchions ».',
      ],
    ),
    SentenceMission(
      id: 'sw_ce2_06',
      level: 'CE2',
      competence: 'accord_sujet_verbe_ce2',
      missionType: 'Je consolide',
      objective: 'Choisis la bonne forme du verbe',
      kind: SentenceKind.accorder,
      gapSentence: 'Mes amies ___ souvent chez moi.',
      choices: ['viennent', 'vient', 'venez'],
      answer: 'viennent',
      hints: [
        'Combien d\'amies ? Regarde le « s » de « amies ».',
        'Le sujet est au pluriel, donc le verbe aussi.',
        'On écrit « viennent ».',
      ],
    ),
  ];
}
