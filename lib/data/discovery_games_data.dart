/// Contenu des jeux de découverte (Chasse au trésor, Voyage dans le temps,
/// Météo Express). Chaque jeu a deux jeux de données entièrement distincts :
/// un pour le CE1, un pour le CE2 — jamais mélangés.

// ══════════════════════════════════════════════════════════════
// 1. CHASSE AU TRÉSOR — se repérer sur un plan
// ══════════════════════════════════════════════════════════════

/// Un lieu placé sur la grille du plan.
class MapLandmark {
  final String emoji;
  final String name;
  final int row;
  final int col;
  const MapLandmark(this.emoji, this.name, this.row, this.col);
}

/// Une mission : rejoindre une case cible en suivant une consigne.
class TreasureMission {
  final String instruction;
  final int targetRow;
  final int targetCol;
  final String reward; // pièce de puzzle gagnée
  const TreasureMission({
    required this.instruction,
    required this.targetRow,
    required this.targetCol,
    required this.reward,
  });
}

class TreasureHuntData {
  static const int gridSize = 5;

  // — CE1 : repérer des lieux familiers, vocabulaire simple —
  static const List<MapLandmark> ce1Landmarks = [
    MapLandmark('🏠', 'la maison', 4, 0),
    MapLandmark('🏫', 'l\'école', 0, 2),
    MapLandmark('🌳', 'le parc', 2, 4),
    MapLandmark('📚', 'la bibliothèque', 4, 4),
    MapLandmark('🏪', 'la boulangerie', 2, 1),
  ];

  static const List<TreasureMission> ce1Missions = [
    TreasureMission(
      instruction: 'Va jusqu\'à 🏫 l\'école !',
      targetRow: 0, targetCol: 2, reward: '🧩',
    ),
    TreasureMission(
      instruction: 'Maintenant, rejoins 🌳 le parc !',
      targetRow: 2, targetCol: 4, reward: '🧩',
    ),
    TreasureMission(
      instruction: 'Direction 📚 la bibliothèque !',
      targetRow: 4, targetCol: 4, reward: '🧩',
    ),
    TreasureMission(
      instruction: 'Passe par 🏪 la boulangerie !',
      targetRow: 2, targetCol: 1, reward: '🧩',
    ),
    TreasureMission(
      instruction: 'Rentre à 🏠 la maison !',
      targetRow: 4, targetCol: 0, reward: '🧩',
    ),
  ];

  // — CE2 : points cardinaux, légende, déplacements comptés —
  static const List<MapLandmark> ce2Landmarks = [
    MapLandmark('🏰', 'le château', 0, 0),
    MapLandmark('⛰️', 'la montagne', 0, 4),
    MapLandmark('🌊', 'la rivière', 2, 2),
    MapLandmark('🌲', 'la forêt', 4, 1),
    MapLandmark('⚓', 'le port', 4, 4),
  ];

  static const List<TreasureMission> ce2Missions = [
    TreasureMission(
      instruction: 'Le trésor est tout au NORD-OUEST du plan 🧭',
      targetRow: 0, targetCol: 0, reward: '🗺️',
    ),
    TreasureMission(
      instruction: 'Va 2 cases vers le SUD, puis 2 cases vers l\'EST 🧭',
      targetRow: 2, targetCol: 2, reward: '🗺️',
    ),
    TreasureMission(
      instruction: 'Rejoins la case la plus au SUD-EST 🧭',
      targetRow: 4, targetCol: 4, reward: '🗺️',
    ),
    TreasureMission(
      instruction: 'Le trésor est à l\'OUEST de ⚓ le port, tout au SUD 🧭',
      targetRow: 4, targetCol: 1, reward: '🗺️',
    ),
    TreasureMission(
      instruction: 'Monte tout au NORD, à l\'EST du plan 🧭',
      targetRow: 0, targetCol: 4, reward: '🗺️',
    ),
  ];
}

// ══════════════════════════════════════════════════════════════
// 2. VOYAGE DANS LE TEMPS — remettre dans l'ordre chronologique
// ══════════════════════════════════════════════════════════════

/// Une frise à remettre dans l'ordre. [items] est DÉJÀ dans le bon
/// ordre chronologique — le jeu les mélange à l'affichage.
class TimelineRound {
  final String title;
  final List<String> emojis;
  final List<String> labels;
  final String explanation;
  const TimelineRound({
    required this.title,
    required this.emojis,
    required this.labels,
    required this.explanation,
  });
}

class TimeTravelData {
  // — CE1 : le temps vécu, la vie quotidienne —
  static const List<TimelineRound> ce1Rounds = [
    TimelineRound(
      title: 'Range la journée d\'Emilie dans l\'ordre',
      emojis: ['🌅', '🏫', '🍽️', '🌙'],
      labels: ['Le réveil', 'L\'école', 'Le dîner', 'La nuit'],
      explanation: 'Une journée commence au réveil et se termine la nuit !',
    ),
    TimelineRound(
      title: 'Range la vie dans l\'ordre',
      emojis: ['👶', '🧒', '🧑', '👵'],
      labels: ['Le bébé', 'L\'enfant', 'L\'adulte', 'La grand-mère'],
      explanation: 'On grandit petit à petit : bébé, enfant, adulte, puis on vieillit.',
    ),
    TimelineRound(
      title: 'Range les saisons dans l\'ordre',
      emojis: ['🌸', '☀️', '🍂', '❄️'],
      labels: ['Le printemps', 'L\'été', 'L\'automne', 'L\'hiver'],
      explanation: 'Les saisons se suivent toujours dans cet ordre !',
    ),
    TimelineRound(
      title: 'Range l\'année scolaire dans l\'ordre',
      emojis: ['🎒', '🎄', '🐣', '🏖️'],
      labels: ['La rentrée', 'Noël', 'Pâques', 'Les grandes vacances'],
      explanation: 'L\'année scolaire va de la rentrée aux grandes vacances.',
    ),
  ];

  // — CE2 : les grandes périodes historiques —
  static const List<TimelineRound> ce2Rounds = [
    TimelineRound(
      title: 'Range les grandes périodes dans l\'ordre',
      emojis: ['🦣', '🏛️', '🏰', '🚀'],
      labels: ['La Préhistoire', 'L\'Antiquité', 'Le Moyen Âge', 'L\'époque actuelle'],
      explanation: 'Préhistoire → Antiquité → Moyen Âge → époque contemporaine.',
    ),
    TimelineRound(
      title: 'Range ces personnages du plus ancien au plus récent',
      emojis: ['🎨', '⚔️', '👑', '🎖️'],
      labels: ['Homme de Cro-Magnon', 'Vercingétorix', 'Louis XIV', 'Napoléon'],
      explanation: 'Cro-Magnon (préhistoire), Vercingétorix (-52), Louis XIV (1600s), Napoléon (1800s).',
    ),
    TimelineRound(
      title: 'Range ces monuments du plus ancien au plus récent',
      emojis: ['🗿', '🏛️', '⛪', '🗼'],
      labels: ['Menhirs de Carnac', 'Arènes de Nîmes', 'Cathédrale Notre-Dame', 'Tour Eiffel'],
      explanation: 'Les menhirs datent de la préhistoire, la Tour Eiffel de 1889 !',
    ),
    TimelineRound(
      title: 'Range ces inventions dans l\'ordre',
      emojis: ['🔥', '🛞', '📖', '💻'],
      labels: ['La maîtrise du feu', 'La roue', 'L\'imprimerie', 'L\'ordinateur'],
      explanation: 'Le feu date de la préhistoire, l\'ordinateur du XXe siècle !',
    ),
  ];
}

// ══════════════════════════════════════════════════════════════
// 3. MÉTÉO EXPRESS — lire et comprendre la météo
// ══════════════════════════════════════════════════════════════

/// Une question météo. [tableRows] est optionnel : s'il est fourni,
/// un petit tableau de températures s'affiche au-dessus de la question.
class WeatherQuestion {
  final String prompt;
  final String bigSymbol;
  final List<String> choices;
  final String answer;
  final String explanation;
  final List<List<String>>? tableRows; // [ville, temp] pour le CE2
  const WeatherQuestion({
    required this.prompt,
    required this.bigSymbol,
    required this.choices,
    required this.answer,
    required this.explanation,
    this.tableRows,
  });
}

class WeatherExpressData {
  // — CE1 : reconnaître les symboles, associer tenue et saison —
  static const List<WeatherQuestion> ce1Questions = [
    WeatherQuestion(
      prompt: 'Quel temps fait-il ?',
      bigSymbol: '☀️',
      choices: ['Il fait soleil', 'Il pleut', 'Il neige', 'Il y a du vent'],
      answer: 'Il fait soleil',
      explanation: 'Le soleil ☀️ veut dire qu\'il fait beau et chaud !',
    ),
    WeatherQuestion(
      prompt: 'Quel temps fait-il ?',
      bigSymbol: '🌧️',
      choices: ['Il pleut', 'Il fait soleil', 'Il neige', 'Il fait nuit'],
      answer: 'Il pleut',
      explanation: 'Avec la pluie 🌧️, on prend un parapluie !',
    ),
    WeatherQuestion(
      prompt: 'Quel temps fait-il ?',
      bigSymbol: '❄️',
      choices: ['Il neige', 'Il pleut', 'Il fait chaud', 'Il y a du brouillard'],
      answer: 'Il neige',
      explanation: 'La neige ❄️ tombe quand il fait très froid !',
    ),
    WeatherQuestion(
      prompt: 'Que met-on quand il fait ce temps ?',
      bigSymbol: '❄️',
      choices: ['Un manteau et un bonnet', 'Un maillot de bain', 'Des lunettes de soleil', 'Des sandales'],
      answer: 'Un manteau et un bonnet',
      explanation: 'Quand il neige, on se couvre bien pour avoir chaud ! 🧣',
    ),
    WeatherQuestion(
      prompt: 'À quelle saison correspond ce temps ?',
      bigSymbol: '🏖️',
      choices: ['L\'été', 'L\'hiver', 'L\'automne', 'Le printemps'],
      answer: 'L\'été',
      explanation: 'En été, il fait chaud et on va à la plage ! 🏖️',
    ),
    WeatherQuestion(
      prompt: 'À quelle saison les feuilles tombent-elles ?',
      bigSymbol: '🍂',
      choices: ['L\'automne', 'L\'été', 'L\'hiver', 'Le printemps'],
      answer: 'L\'automne',
      explanation: 'En automne 🍂, les feuilles des arbres jaunissent et tombent.',
    ),
    WeatherQuestion(
      prompt: 'Quel temps fait-il ?',
      bigSymbol: '💨',
      choices: ['Il y a du vent', 'Il fait soleil', 'Il neige', 'Il fait nuit'],
      answer: 'Il y a du vent',
      explanation: 'Le vent 💨 fait bouger les arbres et vole les chapeaux !',
    ),
  ];

  // — CE2 : lire un tableau, comparer, distinguer météo et climat —
  static const List<WeatherQuestion> ce2Questions = [
    WeatherQuestion(
      prompt: 'Quelle ville est la plus chaude ?',
      bigSymbol: '🌡️',
      tableRows: [['Paris', '12°C'], ['Nice', '19°C'], ['Lille', '9°C']],
      choices: ['Nice', 'Paris', 'Lille', 'Toutes pareilles'],
      answer: 'Nice',
      explanation: 'Nice affiche 19°C : c\'est la température la plus élevée du tableau.',
    ),
    WeatherQuestion(
      prompt: 'Quelle ville est la plus froide ?',
      bigSymbol: '🌡️',
      tableRows: [['Paris', '12°C'], ['Nice', '19°C'], ['Lille', '9°C']],
      choices: ['Lille', 'Nice', 'Paris', 'Aucune'],
      answer: 'Lille',
      explanation: 'Lille affiche 9°C : c\'est la plus petite température du tableau.',
    ),
    WeatherQuestion(
      prompt: 'Combien de degrés d\'écart entre Nice et Lille ?',
      bigSymbol: '🌡️',
      tableRows: [['Nice', '19°C'], ['Lille', '9°C']],
      choices: ['10°C', '28°C', '9°C', '19°C'],
      answer: '10°C',
      explanation: '19 − 9 = 10. Il y a 10 degrés d\'écart entre les deux villes.',
    ),
    WeatherQuestion(
      prompt: 'Quelle température est en dessous de zéro ?',
      bigSymbol: '🥶',
      tableRows: [['Lundi', '3°C'], ['Mardi', '-2°C'], ['Mercredi', '5°C']],
      choices: ['-2°C (mardi)', '3°C (lundi)', '5°C (mercredi)', 'Aucune'],
      answer: '-2°C (mardi)',
      explanation: 'Sous zéro, la température est négative : -2°C. L\'eau gèle !',
    ),
    WeatherQuestion(
      prompt: 'La météo, c\'est...',
      bigSymbol: '📺',
      choices: [
        'Le temps qu\'il fait sur quelques jours',
        'Le temps sur 30 ans',
        'La température de la maison',
        'Le nom d\'une saison',
      ],
      answer: 'Le temps qu\'il fait sur quelques jours',
      explanation: 'La météo décrit le temps à court terme (aujourd\'hui, demain).',
    ),
    WeatherQuestion(
      prompt: 'Le climat, c\'est...',
      bigSymbol: '🌍',
      choices: [
        'Le temps habituel d\'une région sur de nombreuses années',
        'Le temps de demain',
        'La pluie d\'aujourd\'hui',
        'Un bulletin télé',
      ],
      answer: 'Le temps habituel d\'une région sur de nombreuses années',
      explanation: 'Le climat, c\'est la tendance sur très longtemps — pas juste demain !',
    ),
    WeatherQuestion(
      prompt: 'Que veut dire une "prévision" météo ?',
      bigSymbol: '🔮',
      choices: [
        'Ce qu\'on pense qu\'il va se passer',
        'Ce qui s\'est passé hier',
        'Ce qui se passe maintenant',
        'Une saison',
      ],
      answer: 'Ce qu\'on pense qu\'il va se passer',
      explanation: 'Prévoir, c\'est annoncer à l\'avance : la météo prévoit le temps à venir.',
    ),
  ];
}
