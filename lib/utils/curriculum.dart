// Mapping officiel programme CE1 + début CE2 (Eduscol / Cycle 2)
class Curriculum {
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
