// Mapping officiel programme CE1 + début CE2 (Eduscol / Cycle 2)
import '../models/exercise.dart';
import '../data/math_exercises.dart';
import '../data/french_exercises.dart';
import '../data/science_exercises.dart';
import '../data/skill_exercises.dart';

class Curriculum {
  // Mapping skillId -> catégorie d'exercices génériques (fallback si
  // SkillExercises n'a rien de spécifique pour ce skillId).
  static const Map<String, String> categoryMap = {
    'sk_add20': 'addition',      'sk_add100': 'addition',
    'sk_sub20': 'subtraction',   'sk_sub100': 'subtraction',
    'sk_mult2_5': 'multiplication', 'sk_mult6_9': 'multiplication',
    'sk_shapes2d': 'geometry',   'sk_shapes3d': 'geometry',
    'sk_angles': 'geometry',     'sk_count100': 'logic',
    'sk_count1000': 'logic',     'sk_fractions': 'logic',
    'sk_length': 'logic',        'sk_mass': 'logic',
    'sk_time': 'logic',          'sk_money': 'logic',
    'sk_read_simple': 'lecture', 'sk_read_text': 'lecture',
    'sk_spell_basic': 'orthographe', 'sk_spell_homophones': 'orthographe',
    'sk_conj_present': 'conjugaison', 'sk_conj_etre_avoir': 'conjugaison',
    'sk_gram_phrase': 'grammaire', 'sk_gram_nature': 'grammaire',
    'sk_vocab_animals': 'vocabulaire', 'sk_read_poetry': 'vocabulaire',
  };

  /// Une compétence a du contenu jouable si SkillExercises en a, ou si elle
  /// est mappée vers une catégorie d'exercices génériques.
  static bool skillHasContent(String skillId) =>
      SkillExercises.getBySkill(skillId).isNotEmpty ||
      categoryMap.containsKey(skillId);

  /// Résout les exercices d'une compétence : priorité à SkillExercises
  /// (contenu spécifique), sinon la catégorie générique de la matière.
  static List<Exercise> exercisesForSkill(String subject, String skillId) {
    final specific = SkillExercises.getBySkill(skillId);
    if (specific.isNotEmpty) return specific;

    final cat = categoryMap[skillId];
    if (cat == null) return const [];
    switch (subject) {
      case 'math':    return MathExercises.getByCategory(cat);
      case 'french':  return FrenchExercises.getByCategory(cat);
      case 'science': return ScienceExercises.getByCategory(cat);
      default:        return const [];
    }
  }

  /// Toutes les compétences (de tous les mondes) d'un niveau donné
  /// ('CE1' ou 'CE2'), chacune enrichie de son 'subject' et 'worldId'.
  static List<Map<String, dynamic>> skillsForLevel(String level) {
    final result = <Map<String, dynamic>>[];
    for (final world in worlds) {
      final subject = world['subject'] as String;
      final worldId = world['id'] as String;
      for (final skill in (world['skills'] as List<Map<String, dynamic>>)) {
        if (skill['level'] == level) {
          result.add({...skill, 'subject': subject, 'worldId': worldId});
        }
      }
    }
    return result;
  }

  /// Tous les exercices jouables d'un niveau donné, tous mondes confondus.
  static List<Exercise> exercisesForLevel(String level) {
    final result = <Exercise>[];
    for (final skill in skillsForLevel(level)) {
      result.addAll(exercisesForSkill(skill['subject'] as String, skill['id'] as String));
    }
    return result;
  }
  static const List<Map<String, dynamic>> periods = [
    {
      'id': 'P1', 'label': 'Période 1', 'emoji': '🍂',
      'subtitle': 'Septembre – Octobre',
    },
    {
      'id': 'P2', 'label': 'Période 2', 'emoji': '🎃',
      'subtitle': 'Novembre – Décembre',
    },
    {
      'id': 'P3', 'label': 'Période 3', 'emoji': '☃️',
      'subtitle': 'Janvier – Février',
    },
    {
      'id': 'P4', 'label': 'Période 4', 'emoji': '🌸',
      'subtitle': 'Mars – Avril',
    },
    {
      'id': 'P5', 'label': 'Période 5', 'emoji': '☀️',
      'subtitle': 'Mai – Juin',
    },
  ];

  // Carte du monde des compétences
  static const List<Map<String, dynamic>> worlds = [
    {
      'id': 'math_numbers',
      'subject': 'math',
      'title': 'Royaume des Nombres',
      'emoji': '🔢',
      'color': 0xFF4FC3F7,
      'skills': [
        {'id': 'sk_count100',  'label': 'Compter jusqu’à 100',   'period': 'P1', 'level': 'CE1'},
        {'id': 'sk_count1000', 'label': 'Compter jusqu’à 1000',  'period': 'P3', 'level': 'CE2'},
        {'id': 'sk_add20',     'label': 'Additions ≤ 20',        'period': 'P1', 'level': 'CE1'},
        {'id': 'sk_add100',    'label': 'Additions ≤ 100',       'period': 'P2', 'level': 'CE1'},
        {'id': 'sk_sub20',     'label': 'Soustractions ≤ 20',    'period': 'P1', 'level': 'CE1'},
        {'id': 'sk_sub100',    'label': 'Soustractions ≤ 100',   'period': 'P2', 'level': 'CE1'},
        {'id': 'sk_mult2_5',   'label': 'Tables ×2 à ×5',        'period': 'P3', 'level': 'CE1'},
        {'id': 'sk_mult6_9',   'label': 'Tables ×6 à ×9',        'period': 'P1', 'level': 'CE2'},
        {'id': 'sk_division',  'label': 'Division simple',       'period': 'P2', 'level': 'CE2'},
        {'id': 'sk_fractions', 'label': 'Fractions simples',     'period': 'P4', 'level': 'CE1'},
      ],
    },
    {
      'id': 'math_geometry',
      'subject': 'math',
      'title': 'Forêt des Formes',
      'emoji': '🔺',
      'color': 0xFF0288D1,
      'skills': [
        {'id': 'sk_shapes2d',   'label': 'Formes planes',        'period': 'P1', 'level': 'CE1'},
        {'id': 'sk_shapes3d',   'label': 'Solides (cube, boule)','period': 'P2', 'level': 'CE1'},
        {'id': 'sk_symmetry',   'label': 'Symétrie axiale',      'period': 'P4', 'level': 'CE1'},
        {'id': 'sk_perimeter',  'label': 'Périmètre simple',     'period': 'P3', 'level': 'CE2'},
        {'id': 'sk_angles',     'label': 'Angle droit',          'period': 'P5', 'level': 'CE1'},
      ],
    },
    {
      'id': 'math_measures',
      'subject': 'math',
      'title': 'Village des Mesures',
      'emoji': '📏',
      'color': 0xFF01579B,
      'skills': [
        {'id': 'sk_length',  'label': 'Longueurs (cm, m)',   'period': 'P2', 'level': 'CE1'},
        {'id': 'sk_mass',    'label': 'Masses (g, kg)',      'period': 'P3', 'level': 'CE1'},
        {'id': 'sk_time',    'label': 'Durées et horaires',  'period': 'P4', 'level': 'CE1'},
        {'id': 'sk_money',   'label': 'Monnaie (euros)',     'period': 'P3', 'level': 'CE1'},
        {'id': 'sk_volume',  'label': 'Volumes (L, cL)',     'period': 'P2', 'level': 'CE2'},
      ],
    },
    {
      'id': 'french_reading',
      'subject': 'french',
      'title': 'Bibliothèque Magique',
      'emoji': '📚',
      'color': 0xFFFF80AB,
      'skills': [
        {'id': 'sk_read_simple',  'label': 'Lire des phrases simples', 'period': 'P1', 'level': 'CE1'},
        {'id': 'sk_read_text',    'label': 'Comprendre un texte',       'period': 'P2', 'level': 'CE1'},
        {'id': 'sk_read_long',    'label': 'Texte narratif long',        'period': 'P1', 'level': 'CE2'},
        {'id': 'sk_read_poetry',  'label': 'Poésie et comptines',       'period': 'P3', 'level': 'CE1'},
        {'id': 'sk_read_infer',   'label': 'Inférer (implicite)',        'period': 'P4', 'level': 'CE2'},
      ],
    },
    {
      'id': 'french_spelling',
      'subject': 'french',
      'title': 'Château de l’Orthographe',
      'emoji': '✏️',
      'color': 0xFFE91E63,
      'skills': [
        {'id': 'sk_spell_basic',   'label': 'Mots usuels CE1',         'period': 'P1', 'level': 'CE1'},
        {'id': 'sk_spell_silent',  'label': 'Lettres muettes',          'period': 'P2', 'level': 'CE1'},
        {'id': 'sk_spell_accents', 'label': 'Accents et tirét',        'period': 'P2', 'level': 'CE1'},
        {'id': 'sk_spell_homophones', 'label': 'Homophones a/à et/est', 'period': 'P3', 'level': 'CE1'},
        {'id': 'sk_spell_pluriel', 'label': 'Pluriel en -s / -x',      'period': 'P3', 'level': 'CE1'},
        {'id': 'sk_spell_ce2',     'label': 'Mots usuels CE2',         'period': 'P1', 'level': 'CE2'},
      ],
    },
    {
      'id': 'french_grammar',
      'subject': 'french',
      'title': 'Tour de la Grammaire',
      'emoji': '📝',
      'color': 0xFFC2185B,
      'skills': [
        {'id': 'sk_gram_phrase',   'label': 'La phrase',              'period': 'P1', 'level': 'CE1'},
        {'id': 'sk_gram_gns',      'label': 'GN et GV',               'period': 'P2', 'level': 'CE1'},
        {'id': 'sk_gram_nature',   'label': 'Nature des mots',        'period': 'P3', 'level': 'CE1'},
        {'id': 'sk_gram_accord',   'label': 'Accord sujet-verbe',     'period': 'P4', 'level': 'CE1'},
        {'id': 'sk_gram_adj',      'label': 'Adjectif qualificatif',  'period': 'P3', 'level': 'CE2'},
        {'id': 'sk_gram_ccl',      'label': 'Compl. circonstanciel',  'period': 'P2', 'level': 'CE2'},
      ],
    },
    {
      'id': 'french_conjugation',
      'subject': 'french',
      'title': 'Lab. de la Conjugaison',
      'emoji': '🔁',
      'color': 0xFF880E4F,
      'skills': [
        {'id': 'sk_conj_present',    'label': 'Présent verbes reguliers', 'period': 'P1', 'level': 'CE1'},
        {'id': 'sk_conj_etre_avoir', 'label': 'Être et avoir au présent',  'period': 'P1', 'level': 'CE1'},
        {'id': 'sk_conj_passe',      'label': 'Passé composé',           'period': 'P4', 'level': 'CE1'},
        {'id': 'sk_conj_futur',      'label': 'Futur simple',             'period': 'P5', 'level': 'CE1'},
        {'id': 'sk_conj_imparfait',  'label': 'Imparfait',                'period': 'P2', 'level': 'CE2'},
      ],
    },
  ];
}
