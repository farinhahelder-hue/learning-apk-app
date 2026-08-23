/// Structure du parcours CE1 / CE2.
///
/// ⚠️ IMPORTANT — portée exacte de cette référence :
///
/// L'ORGANISATION en domaines suit celle des programmes du cycle 2 publiés
/// au Bulletin officiel du 31 octobre 2024, applicables depuis la rentrée
/// 2025 (français : Lecture, Écriture, Oral, Vocabulaire,
/// Grammaire/Orthographe).
///
/// En revanche, le DÉTAIL des compétences listées ci-dessous a été rédigé
/// pour cette application : il n'a pas été recopié du texte officiel, dont
/// les annexes n'ont pas pu être consultées directement. Il doit donc être
/// relu et validé par un enseignant avant d'être présenté comme conforme
/// au programme.
///
/// Référence : https://www.education.gouv.fr/bo/2024/Hebdo41/MENE2415135A
library;

/// Le type d'activité qui travaille une compétence.
enum LearningActivity {
  numberBars,
  dictee,
  sentence,
  problem,
  tale,
  multiplication,
  phonetique,
  market,
  storyFactory,
  treasureMap,
  mathQuiz,
  frenchQuiz,
  scienceQuiz,
  comingSoon,
}

extension LearningActivityInfo on LearningActivity {
  String get label => switch (this) {
        LearningActivity.numberBars => 'Barres de nombres',
        LearningActivity.dictee => 'Dictée image',
        LearningActivity.sentence => 'Chantier des phrases',
        LearningActivity.problem => 'Mission-problème',
        LearningActivity.tale => 'Histoire à lire',
        LearningActivity.multiplication => 'Tables de multiplication',
        LearningActivity.phonetique => 'Atelier des sons',
        LearningActivity.market => 'Marché des nombres',
        LearningActivity.storyFactory => 'Fabrique à histoires',
        LearningActivity.treasureMap => 'Carte au trésor',
        LearningActivity.mathQuiz => 'Quiz maths',
        LearningActivity.frenchQuiz => 'Quiz français',
        LearningActivity.scienceQuiz => 'Quiz sciences',
        LearningActivity.comingSoon => 'Bientôt disponible',
      };

  String get emoji => switch (this) {
        LearningActivity.numberBars => '🔢',
        LearningActivity.dictee => '🖼️',
        LearningActivity.sentence => '🧱',
        LearningActivity.problem => '🧩',
        LearningActivity.tale => '📖',
        LearningActivity.multiplication => '✖️',
        LearningActivity.phonetique => '🔊',
        LearningActivity.market => '🧺',
        LearningActivity.storyFactory => '✒️',
        LearningActivity.treasureMap => '🗺️',
        LearningActivity.mathQuiz => '➕',
        LearningActivity.frenchQuiz => '✏️',
        LearningActivity.scienceQuiz => '🔬',
        LearningActivity.comingSoon => '🚧',
      };

  bool get isAvailable => this != LearningActivity.comingSoon;
}

/// Une compétence du parcours.
class Competence {
  /// Identifiant technique, réutilisé par le suivi parental.
  final String id;

  /// Formulation côté enfant : ce qu'elle va faire.
  final String childLabel;

  /// Formulation côté adulte : la compétence visée.
  final String adultLabel;

  final LearningActivity activity;

  const Competence({
    required this.id,
    required this.childLabel,
    required this.adultLabel,
    required this.activity,
  });
}

/// Un domaine du programme = un chapitre du mode histoire.
class CurriculumDomain {
  final String id;
  final String subject; // 'francais' | 'maths'
  final String label;
  final String emoji;
  final int colorValue;

  /// Décor du chapitre dans le mode histoire.
  final String place;
  final String narration;

  final List<Competence> ce1;
  final List<Competence> ce2;

  const CurriculumDomain({
    required this.id,
    required this.subject,
    required this.label,
    required this.emoji,
    required this.colorValue,
    required this.place,
    required this.narration,
    required this.ce1,
    required this.ce2,
  });

  List<Competence> forLevel(String level) => level == 'CE2' ? ce2 : ce1;
}

class OfficialCurriculum {
  static const String reference =
      'Organisation inspirée des programmes du cycle 2 — BO du 31 octobre 2024, '
      'en application depuis la rentrée 2025.';

  static const String disclaimer =
      'La structure en domaines suit celle du programme officiel. Le détail des '
      'compétences a été rédigé pour cette application et n\'a pas été recopié du '
      'texte du ministère : il reste à faire valider par un enseignant.';

  static List<CurriculumDomain> get all => [...french, ...maths];

  // ══════════════════════════════════════════════════════════
  // FRANÇAIS — domaines du BO : Lecture, Écriture, Oral,
  // Vocabulaire, Grammaire/Orthographe
  // ══════════════════════════════════════════════════════════
  static const List<CurriculumDomain> french = [
    CurriculumDomain(
      id: 'fr_lecture',
      subject: 'francais',
      label: 'Lecture',
      emoji: '📖',
      colorValue: 0xFFFF80AB,
      place: 'La Bibliothèque aux mille histoires',
      narration:
          'Papa Phoque pousse la porte d\'une bibliothèque immense. '
          '« Ici, chaque livre attend quelqu\'un pour le lire. Tu viens ? »',
      ce1: [
        Competence(
          id: 'lecture_mots_ce1',
          childLabel: 'Lire des mots et des phrases',
          adultLabel: 'Lire des mots et des phrases courtes de façon fluide',
          activity: LearningActivity.frenchQuiz,
        ),
        Competence(
          id: 'lecture_comprehension_ce1',
          childLabel: 'Comprendre une petite histoire',
          adultLabel: 'Comprendre un texte court et répondre à des questions',
          activity: LearningActivity.tale,
        ),
        Competence(
          id: 'lecture_voix_haute_ce1',
          childLabel: 'Écouter et suivre une histoire',
          adultLabel: 'Écouter un texte lu et en restituer le sens',
          activity: LearningActivity.tale,
        ),
      ],
      ce2: [
        Competence(
          id: 'lecture_texte_long_ce2',
          childLabel: 'Lire une histoire plus longue',
          adultLabel: 'Lire et comprendre un texte narratif plus long',
          activity: LearningActivity.tale,
        ),
        Competence(
          id: 'lecture_inference_ce2',
          childLabel: 'Deviner ce qui n\'est pas écrit',
          adultLabel: 'Inférer une information implicite dans un texte',
          activity: LearningActivity.tale,
        ),
        Competence(
          id: 'lecture_personnages_ce2',
          childLabel: 'Reconnaître les personnages',
          adultLabel: 'Identifier personnages, lieux et déroulé du récit',
          activity: LearningActivity.tale,
        ),
      ],
    ),
    CurriculumDomain(
      id: 'fr_ecriture',
      subject: 'francais',
      label: 'Écriture',
      emoji: '✍️',
      colorValue: 0xFFEC407A,
      place: 'L\'Atelier des mots',
      narration:
          'Dans l\'atelier, des lettres flottent dans l\'air. '
          'Monika en attrape une : « Pipipi ! On écrit quoi aujourd\'hui ? »',
      ce1: [
        Competence(
          id: 'ecrire_mots_frequents_ce1',
          childLabel: 'Écrire des mots que tu connais',
          adultLabel: 'Écrire correctement des mots fréquents',
          activity: LearningActivity.dictee,
        ),
        Competence(
          id: 'ecrire_mots_avec_accents_ce1',
          childLabel: 'Écrire les mots avec des accents',
          adultLabel: 'Placer correctement les accents',
          activity: LearningActivity.dictee,
        ),
        Competence(
          id: 'graphie_ou_ce1',
          childLabel: 'Écrire le son « ou »',
          adultLabel: 'Maîtriser la graphie du son [u]',
          activity: LearningActivity.dictee,
        ),
        Competence(
          id: 'graphie_ch_ce1',
          childLabel: 'Écrire le son « ch »',
          adultLabel: 'Maîtriser la graphie du son [ʃ]',
          activity: LearningActivity.dictee,
        ),
        Competence(
          id: 'graphie_eau_ce1',
          childLabel: 'Écrire le son « eau »',
          adultLabel: 'Maîtriser la graphie « eau » du son [o]',
          activity: LearningActivity.dictee,
        ),
        Competence(
          id: 'graphies_ai_on_ce1',
          childLabel: 'Écrire les sons « ai » et « on »',
          adultLabel: 'Maîtriser les graphies « ai » et « on »',
          activity: LearningActivity.dictee,
        ),
        Competence(
          id: 'production_ecrit_ce1',
          childLabel: 'Écrire une histoire à moi',
          adultLabel: 'Produire un court texte narratif',
          activity: LearningActivity.storyFactory,
        ),
      ],
      ce2: [
        Competence(
          id: 'ecrire_mots_complexes_ce2',
          childLabel: 'Écrire des mots plus longs',
          adultLabel: 'Écrire des mots complexes et polysyllabiques',
          activity: LearningActivity.dictee,
        ),
        Competence(
          id: 'lettre_muette_finale_ce2',
          childLabel: 'Les lettres qu\'on n\'entend pas',
          adultLabel: 'Identifier et écrire les lettres muettes finales',
          activity: LearningActivity.dictee,
        ),
        Competence(
          id: 'graphie_gn_ce2',
          childLabel: 'Écrire le son « gn »',
          adultLabel: 'Maîtriser la graphie du son [ɲ]',
          activity: LearningActivity.dictee,
        ),
        Competence(
          id: 'graphie_ill_ce2',
          childLabel: 'Écrire le son « ill »',
          adultLabel: 'Maîtriser la graphie du son [j]',
          activity: LearningActivity.dictee,
        ),
        Competence(
          id: 'graphies_oi_eau_ce2',
          childLabel: 'Écrire « oi » et « eau »',
          adultLabel: 'Maîtriser les graphies « oi » et « eau »',
          activity: LearningActivity.dictee,
        ),
        Competence(
          id: 'graphie_ph_ce2',
          childLabel: 'Écrire le son « ph »',
          adultLabel: 'Maîtriser la graphie « ph » du son [f]',
          activity: LearningActivity.dictee,
        ),
        Competence(
          id: 'graphie_gu_ce2',
          childLabel: 'Écrire le son « gu »',
          adultLabel: 'Maîtriser la graphie « gu » du son [g]',
          activity: LearningActivity.dictee,
        ),
        Competence(
          id: 'production_ecrit_ce2',
          childLabel: 'Écrire une histoire plus longue',
          adultLabel: 'Produire un texte narratif structuré',
          activity: LearningActivity.storyFactory,
        ),
      ],
    ),
    CurriculumDomain(
      id: 'fr_oral',
      subject: 'francais',
      label: 'Oral',
      emoji: '🗣️',
      colorValue: 0xFFB966D9,
      place: 'La Clairière qui écoute',
      narration:
          'Ninon la dauphine remonte à la surface. '
          '« Ici, on écoute avant de parler. Tends bien l\'oreille ! »',
      ce1: [
        Competence(
          id: 'ecouter_consigne_ce1',
          childLabel: 'Écouter et comprendre une consigne',
          adultLabel: 'Écouter pour comprendre une consigne orale',
          activity: LearningActivity.dictee,
        ),
        Competence(
          id: 'phonologie_sons_ce1',
          childLabel: 'Reconnaître les sons',
          adultLabel: 'Discriminer les sons de la langue',
          activity: LearningActivity.phonetique,
        ),
      ],
      ce2: [
        Competence(
          id: 'ecouter_recit_ce2',
          childLabel: 'Écouter une histoire entière',
          adultLabel: 'Écouter un récit long et en restituer l\'essentiel',
          activity: LearningActivity.tale,
        ),
        Competence(
          id: 'phonologie_complexe_ce2',
          childLabel: 'Distinguer les sons proches',
          adultLabel: 'Discriminer des sons proches et des graphies complexes',
          activity: LearningActivity.frenchQuiz,
        ),
      ],
    ),
    CurriculumDomain(
      id: 'fr_vocabulaire',
      subject: 'francais',
      label: 'Vocabulaire',
      emoji: '💬',
      colorValue: 0xFFC2185B,
      place: 'Le Marché des mots',
      narration:
          'Sur les étals, ce ne sont pas des fruits mais des mots. '
          'Ainy le crabe en choisit un : « Celui-là, il veut dire quoi ? »',
      ce1: [
        Competence(
          id: 'vocabulaire_contraires_ce1',
          childLabel: 'Trouver le contraire d\'un mot',
          adultLabel: 'Identifier des mots de sens contraire',
          activity: LearningActivity.frenchQuiz,
        ),
        Competence(
          id: 'vocabulaire_familles_ce1',
          childLabel: 'Les mots qui vont ensemble',
          adultLabel: 'Regrouper des mots par champ lexical',
          activity: LearningActivity.frenchQuiz,
        ),
      ],
      ce2: [
        Competence(
          id: 'vocabulaire_synonymes_ce2',
          childLabel: 'Les mots qui veulent dire pareil',
          adultLabel: 'Identifier des synonymes',
          activity: LearningActivity.frenchQuiz,
        ),
        Competence(
          id: 'vocabulaire_sens_contexte_ce2',
          childLabel: 'Comprendre un mot dans la phrase',
          adultLabel: 'Déduire le sens d\'un mot d\'après son contexte',
          activity: LearningActivity.tale,
        ),
      ],
    ),
    CurriculumDomain(
      id: 'fr_grammaire',
      subject: 'francais',
      label: 'Grammaire et orthographe',
      emoji: '🧱',
      colorValue: 0xFF7E57C2,
      place: 'Le Chantier des phrases',
      narration:
          'Des mots empilés comme des briques attendent d\'être assemblés. '
          'Papa Écureuil tend un casque : « À toi de bâtir ! »',
      ce1: [
        Competence(
          id: 'construire_phrase_simple_ce1',
          childLabel: 'Construire une phrase',
          adultLabel: 'Construire une phrase simple bien ordonnée',
          activity: LearningActivity.sentence,
        ),
        Competence(
          id: 'reperer_le_verbe_ce1',
          childLabel: 'Trouver le verbe',
          adultLabel: 'Identifier le verbe dans une phrase',
          activity: LearningActivity.sentence,
        ),
        Competence(
          id: 'reperer_le_nom_ce1',
          childLabel: 'Trouver le nom',
          adultLabel: 'Identifier le nom et son déterminant',
          activity: LearningActivity.sentence,
        ),
        Competence(
          id: 'accord_sujet_verbe_ce1',
          childLabel: 'Accorder le verbe',
          adultLabel: 'Réaliser l\'accord sujet-verbe',
          activity: LearningActivity.sentence,
        ),
      ],
      ce2: [
        Competence(
          id: 'groupe_nominal_enrichi_ce2',
          childLabel: 'Enrichir un groupe de mots',
          adultLabel: 'Construire et enrichir un groupe nominal',
          activity: LearningActivity.sentence,
        ),
        Competence(
          id: 'reperer_adjectif_ce2',
          childLabel: 'Trouver l\'adjectif',
          adultLabel: 'Identifier l\'adjectif qualificatif',
          activity: LearningActivity.sentence,
        ),
        Competence(
          id: 'accord_nom_adjectif_ce2',
          childLabel: 'Accorder l\'adjectif',
          adultLabel: 'Réaliser l\'accord dans le groupe nominal',
          activity: LearningActivity.sentence,
        ),
        Competence(
          id: 'conjugaison_imparfait_ce2',
          childLabel: 'Parler du passé',
          adultLabel: 'Conjuguer à l\'imparfait',
          activity: LearningActivity.sentence,
        ),
        Competence(
          id: 'construire_phrase_avec_complement_ce2',
          childLabel: 'Dire où et quand',
          adultLabel: 'Construire une phrase avec un complément',
          activity: LearningActivity.sentence,
        ),
        // Reprise d'une compétence du CE1 : elle est nommée comme les
        // autres étapes, sans mention de retard ni de rattrapage.
        Competence(
          id: 'accord_sujet_verbe_ce2',
          childLabel: 'Accorder le verbe',
          adultLabel: 'Consolider l\'accord sujet-verbe',
          activity: LearningActivity.sentence,
        ),
      ],
    ),

    // ══════════════════════════════════════════════════════════
    // MATHÉMATIQUES
    // ══════════════════════════════════════════════════════════
  ];

  static const List<CurriculumDomain> maths = [
    CurriculumDomain(
      id: 'ma_nombres',
      subject: 'maths',
      label: 'Nombres et calculs',
      emoji: '🔢',
      colorValue: 0xFF42A5F5,
      place: 'La Vallée des nombres',
      narration:
          'Des barres et des cubes scintillent dans la vallée. '
          'Bébé Phoque en empile trois : « Regarde, ça fait une dizaine ! »',
      ce1: [
        Competence(
          id: 'composer_nombres_jusqua_100',
          childLabel: 'Construire les nombres jusqu\'à 100',
          adultLabel: 'Composer et décomposer les nombres jusqu\'à 100',
          activity: LearningActivity.numberBars,
        ),
        Competence(
          id: 'composer_decomposer_nombres_jusqua_1000',
          childLabel: 'Construire les nombres jusqu\'à 1000',
          adultLabel: 'Composer et décomposer les nombres jusqu\'à 1 000',
          activity: LearningActivity.numberBars,
        ),
        Competence(
          id: 'grouper_dix_unites_en_dizaine',
          childLabel: 'Grouper dix par dix',
          adultLabel: 'Comprendre le groupement par dix',
          activity: LearningActivity.numberBars,
        ),
        Competence(
          id: 'addition_soustraction_ce1',
          childLabel: 'Additionner et soustraire',
          adultLabel: 'Additionner et soustraire dans les nombres jusqu\'à 100',
          activity: LearningActivity.mathQuiz,
        ),
      ],
      ce2: [
        Competence(
          id: 'composer_decomposer_nombres_jusqua_10000',
          childLabel: 'Construire les grands nombres',
          adultLabel: 'Composer et décomposer les nombres jusqu\'à 10 000',
          activity: LearningActivity.numberBars,
        ),
        Competence(
          id: 'valeur_position_chiffre',
          childLabel: 'La place change tout',
          adultLabel: 'Comprendre la valeur positionnelle des chiffres',
          activity: LearningActivity.numberBars,
        ),
        Competence(
          id: 'multiplication_ce2',
          childLabel: 'Les tables de multiplication',
          adultLabel: 'Mémoriser et utiliser les tables de multiplication',
          activity: LearningActivity.multiplication,
        ),
        Competence(
          id: 'division_partage_ce2',
          childLabel: 'Partager en parts égales',
          adultLabel: 'Aborder la division par le partage',
          activity: LearningActivity.problem,
        ),
      ],
    ),
    CurriculumDomain(
      id: 'ma_problemes',
      subject: 'maths',
      label: 'Résolution de problèmes',
      emoji: '🧩',
      colorValue: 0xFF26A69A,
      place: 'Le Pont des énigmes',
      narration:
          'Un pont barré par une énigme. Barbe Noire le chat s\'assied : '
          '« Pas de panique. On avance une étape à la fois. »',
      ce1: [
        Competence(
          id: 'probleme_addition_une_etape_ce1',
          childLabel: 'Problèmes où on ajoute',
          adultLabel: 'Résoudre un problème additif en une étape',
          activity: LearningActivity.problem,
        ),
        Competence(
          id: 'probleme_soustraction_une_etape_ce1',
          childLabel: 'Problèmes où on enlève',
          adultLabel: 'Résoudre un problème soustractif en une étape',
          activity: LearningActivity.problem,
        ),
        Competence(
          id: 'probleme_comparaison_ce1',
          childLabel: 'Problèmes où on compare',
          adultLabel: 'Résoudre un problème de comparaison',
          activity: LearningActivity.problem,
        ),
      ],
      ce2: [
        Competence(
          id: 'probleme_partage_ce2',
          childLabel: 'Problèmes de partage',
          adultLabel: 'Résoudre un problème de partage équitable',
          activity: LearningActivity.problem,
        ),
        Competence(
          id: 'probleme_deux_etapes_ce2',
          childLabel: 'Problèmes en deux étapes',
          adultLabel: 'Résoudre un problème à deux étapes',
          activity: LearningActivity.problem,
        ),
      ],
    ),
    CurriculumDomain(
      id: 'ma_mesures',
      subject: 'maths',
      label: 'Grandeurs et mesures',
      emoji: '📏',
      colorValue: 0xFF01579B,
      place: 'L\'Atelier des mesures',
      narration:
          'Des règles, des balances et des horloges partout. '
          'Billy l\'oiseau se pose sur une balance : « Combien je pèse ? »',
      ce1: [
        Competence(
          id: 'longueurs_ce1',
          childLabel: 'Mesurer des longueurs',
          adultLabel: 'Comparer et mesurer des longueurs (cm, m)',
          activity: LearningActivity.market,
        ),
        Competence(
          id: 'temps_ce1',
          childLabel: 'Lire l\'heure et les durées',
          adultLabel: 'Repérer des durées et lire l\'heure',
          activity: LearningActivity.mathQuiz,
        ),
        Competence(
          id: 'monnaie_ce1',
          childLabel: 'Compter la monnaie',
          adultLabel: 'Utiliser la monnaie (euros et centimes)',
          activity: LearningActivity.market,
        ),
      ],
      ce2: [
        Competence(
          id: 'masses_ce2',
          childLabel: 'Peser des objets',
          adultLabel: 'Comparer et mesurer des masses (g, kg)',
          activity: LearningActivity.market,
        ),
        Competence(
          id: 'contenances_ce2',
          childLabel: 'Mesurer des liquides',
          adultLabel: 'Comparer et mesurer des contenances (L, cL)',
          activity: LearningActivity.market,
        ),
      ],
    ),
    CurriculumDomain(
      id: 'ma_geometrie',
      subject: 'maths',
      label: 'Espace et géométrie',
      emoji: '🔺',
      colorValue: 0xFF0288D1,
      place: 'La Forêt des formes',
      narration:
          'Les arbres ont des troncs carrés et des feuilles triangulaires. '
          '« Bienvenue dans la forêt où tout a une forme ! »',
      ce1: [
        Competence(
          id: 'formes_planes_ce1',
          childLabel: 'Reconnaître les formes',
          adultLabel: 'Reconnaître et nommer les figures planes',
          activity: LearningActivity.mathQuiz,
        ),
        Competence(
          id: 'se_reperer_espace_ce1',
          childLabel: 'Se repérer dans l\'espace',
          adultLabel: 'Se repérer et se déplacer sur un plan',
          activity: LearningActivity.treasureMap,
        ),
      ],
      ce2: [
        Competence(
          id: 'points_cardinaux_ce2',
          childLabel: 'Nord, sud, est, ouest',
          adultLabel: 'Se repérer avec les points cardinaux',
          activity: LearningActivity.treasureMap,
        ),
        Competence(
          id: 'solides_ce2',
          childLabel: 'Les formes en volume',
          adultLabel: 'Reconnaître et décrire des solides',
          activity: LearningActivity.mathQuiz,
        ),
      ],
    ),
  ];

  /// Nombre total de compétences du parcours pour un niveau.
  static int totalCompetences(String level) =>
      all.fold(0, (sum, d) => sum + d.forLevel(level).length);
}
