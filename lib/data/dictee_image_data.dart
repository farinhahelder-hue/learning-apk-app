/// Mots de la « Dictée image ».
///
/// Chaque mot est fourni en deux découpages :
/// - lettre par lettre (par défaut) ;
/// - en blocs phonologiques (ch, ou, eau, on…), activable dans les réglages.
/// Le bon choix dépend d'Emilie : c'est une option pédagogique, pas une règle.
class DicteeWord {
  final String emoji;
  final String word;

  /// Découpage en blocs phonologiques, par exemple ['ch', 'a', 't'].
  /// La concaténation doit toujours redonner [word].
  final List<String> blocks;

  final String competence;

  const DicteeWord({
    required this.emoji,
    required this.word,
    required this.blocks,
    required this.competence,
  });

  /// Découpage lettre par lettre.
  List<String> get letters => word.split('');

  List<String> piecesFor({required bool useBlocks}) =>
      useBlocks ? blocks : letters;
}

class DicteeImageData {
  static List<DicteeWord> forLevel(String level) =>
      level == 'CE2' ? ce2 : ce1;

  // ── CE1 : mots réguliers et fréquents ──
  static const List<DicteeWord> ce1 = [
    DicteeWord(
      emoji: '🐱', word: 'chat',
      blocks: ['ch', 'a', 't'],
      competence: 'ecrire_mots_frequents_ce1',
    ),
    DicteeWord(
      emoji: '🌙', word: 'lune',
      blocks: ['l', 'u', 'n', 'e'],
      competence: 'ecrire_mots_frequents_ce1',
    ),
    DicteeWord(
      emoji: '🏫', word: 'école',
      blocks: ['é', 'c', 'o', 'l', 'e'],
      competence: 'ecrire_mots_avec_accents_ce1',
    ),
    DicteeWord(
      emoji: '⛵', word: 'bateau',
      blocks: ['b', 'a', 't', 'eau'],
      competence: 'graphie_eau_ce1',
    ),
    DicteeWord(
      emoji: '🌸', word: 'fleur',
      blocks: ['f', 'l', 'eu', 'r'],
      competence: 'ecrire_mots_frequents_ce1',
    ),
    DicteeWord(
      emoji: '🐭', word: 'souris',
      blocks: ['s', 'ou', 'r', 'i', 's'],
      competence: 'graphie_ou_ce1',
    ),
    DicteeWord(
      emoji: '🏠', word: 'maison',
      blocks: ['m', 'ai', 's', 'on'],
      competence: 'graphies_ai_on_ce1',
    ),
    DicteeWord(
      emoji: '🐴', word: 'cheval',
      blocks: ['ch', 'e', 'v', 'a', 'l'],
      competence: 'graphie_ch_ce1',
    ),
  ];

  // ── CE2 : mots plus longs et plus complexes ──
  static const List<DicteeWord> ce2 = [
    DicteeWord(
      emoji: '🏰', word: 'château',
      blocks: ['ch', 'â', 't', 'eau'],
      competence: 'ecrire_mots_complexes_ce2',
    ),
    DicteeWord(
      emoji: '🐦', word: 'oiseau',
      blocks: ['oi', 's', 'eau'],
      competence: 'graphies_oi_eau_ce2',
    ),
    DicteeWord(
      emoji: '⛰️', word: 'montagne',
      blocks: ['m', 'on', 't', 'a', 'gn', 'e'],
      competence: 'graphie_gn_ce2',
    ),
    DicteeWord(
      emoji: '🍫', word: 'chocolat',
      blocks: ['ch', 'o', 'c', 'o', 'l', 'a', 't'],
      competence: 'lettre_muette_finale_ce2',
    ),
    DicteeWord(
      emoji: '🦋', word: 'papillon',
      blocks: ['p', 'a', 'p', 'i', 'll', 'on'],
      competence: 'graphie_ill_ce2',
    ),
    DicteeWord(
      emoji: '🐘', word: 'éléphant',
      blocks: ['é', 'l', 'é', 'ph', 'an', 't'],
      competence: 'graphie_ph_ce2',
    ),
    DicteeWord(
      emoji: '🐿️', word: 'écureuil',
      blocks: ['é', 'c', 'u', 'r', 'eu', 'il'],
      competence: 'ecrire_mots_complexes_ce2',
    ),
    DicteeWord(
      emoji: '🎸', word: 'guitare',
      blocks: ['gu', 'i', 't', 'a', 'r', 'e'],
      competence: 'graphie_gu_ce2',
    ),
  ];
}
