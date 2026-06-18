// 🏙️ Système narratif - Emilie part à l'aventure pour sauver le Royaume des Savoirs
class StoryChapter {
  final String id;
  final String title;
  final String emoji;
  final String narrative; // texte raconté avant le chapitre
  final String worldId; // monde lié
  final String skillId; // compétence requise
  final int requiredStars; // étoiles nécessaires pour débloquer
  final String rewardText; // texte après victoire
  final String rewardEmoji;

  const StoryChapter({
    required this.id,
    required this.title,
    required this.emoji,
    required this.narrative,
    required this.worldId,
    required this.skillId,
    required this.requiredStars,
    required this.rewardText,
    required this.rewardEmoji,
  });
}

class Story {
  static const List<StoryChapter> chapters = [
    StoryChapter(
      id: 'ch1',
      title: 'Le Sortilège du Roi Calculus',
      emoji: '🤄',
      narrative:
          'Le méchant roi Calculus a volé tous les nombres du Royaume !\n'
          'Sans les chiffres, personne ne peut compter, mesurer, ni cuisiner.\n'
          'Émilie, tú es la seule à pouvoir les retrouver !\n'
          '📜 Mission : Maîtrise les additions pour briser le premier sortilège !',
      worldId: 'math_numbers',
      skillId: 'sk_add20',
      requiredStars: 0,
      rewardText:
          'Bravo ! Les petits nombres sont libérés ! Émilie repart avec +1 pouvoir mathématique !',
      rewardEmoji: '🔢',
    ),
    StoryChapter(
      id: 'ch2',
      title: 'La Forêt des Mots Perdus',
      emoji: '🌲',
      narrative: 'La forêt magique a perdu tous ses mots !\n'
          'Les arbres ne savent plus comment s’appeler, les animaux sont silencieux…\n'
          '📜 Mission : Apprends l’orthographe pour rendre la parole à la forêt !',
      worldId: 'french_spelling',
      skillId: 'sk_spell_basic',
      requiredStars: 3,
      rewardText:
          'La forêt chante à nouveau ! Tu as retrouvé 100 mots magiques !',
      rewardEmoji: '🌳',
    ),
    StoryChapter(
      id: 'ch3',
      title: 'La Tour des Formes Brisées',
      emoji: '📍',
      narrative: 'La Tour du Savant Géomètre s’est effondrée !\n'
          'Carrés, triangles et cercles sont mélangés partout dans la ville.\n'
          '📜 Mission : Reconnais les formes pour reconstruire la Tour !',
      worldId: 'math_geometry',
      skillId: 'sk_shapes2d',
      requiredStars: 6,
      rewardText:
          'La Tour est reconstruite ! Émilie est nommée Architecte du Royaume !',
      rewardEmoji: '🏛️',
    ),
    StoryChapter(
      id: 'ch4',
      title: 'Le Dragon de la Grammaire',
      emoji: '🐉',
      narrative:
          'Un dragon terrible crâche des phrases sans verbe, des noms sans sujet…\n'
          'Tout le monde parle en charabia ! C’est le chaos !\n'
          '📜 Mission : Apprends la grammaire pour dompter le dragon !',
      worldId: 'french_grammar',
      skillId: 'sk_gram_phrase',
      requiredStars: 10,
      rewardText:
          'Le dragon est dompté ! Il t’obéit maintenant et récite des poèmes !',
      rewardEmoji: '🐉',
    ),
    StoryChapter(
      id: 'ch5',
      title: 'Le Trésor du Marchand de Mesures',
      emoji: '💰',
      narrative:
          'Le vieux marchand a caché son trésor quelque part dans le Royaume.\n'
          'Pour le trouver, tu dois maîtriser les longueurs, la monnaie et les masses.\n'
          '📜 Mission : Apprends les mesures pour suivre la carte au trésor !',
      worldId: 'math_measures',
      skillId: 'sk_money',
      requiredStars: 15,
      rewardText:
          'Le trésor est à toi ! Et dedans… un parchemin avec la prochaine aventure !',
      rewardEmoji: '🗃️',
    ),
    StoryChapter(
      id: 'ch6',
      title: 'Le Labyrinthe du Temps',
      emoji: '⏰',
      narrative: 'La machine à remonter le temps est bloquée !\n'
          'Le savant fou a mélangé tous les verbes : passé, présent, futur, tout est à l’envers !\n'
          '📜 Mission : Maîtrise la conjugaison pour réparer la machine !',
      worldId: 'french_conjugation',
      skillId: 'sk_conj_present',
      requiredStars: 20,
      rewardText:
          'La machine est réparée ! Tu peux voyager dans le temps... et en CE2 !',
      rewardEmoji: '⌛',
    ),
  ];

  static StoryChapter? currentChapter(int totalStars) {
    for (final ch in chapters.reversed) {
      if (totalStars >= ch.requiredStars) return ch;
    }
    return chapters.first;
  }

  static StoryChapter? nextChapter(int totalStars) {
    for (final ch in chapters) {
      if (totalStars < ch.requiredStars) return ch;
    }
    return null;
  }
}
