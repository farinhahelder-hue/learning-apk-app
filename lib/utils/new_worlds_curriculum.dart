/// Nouveaux mondes pédagogiques :
/// Animaux 🐾 • Émotions 💛 • Géographie 🌍 • Histoire 🏛️ • Univers 🪐 • Faits incroyables 🤯
class NewWorldsCurriculum {

  // ── ANIMAUX ───────────────────────────────────────────────
  static const List<Map<String, dynamic>> animals = [
    {
      'id': 'a1', 'question': 'Comment s\'appelle le bébé du lion ?',
      'choices': ['Lionceau', 'Louveteau', 'Ourson', 'Poulain'],
      'answer': 'Lionceau', 'emoji': '🦁',
      'funFact': 'Les lionceaux ouvrent les yeux à 10 jours !',
    },
    {
      'id': 'a2', 'question': 'Quel animal dort debout ?',
      'choices': ['Le cheval', 'Le chien', 'Le lapin', 'Le poisson'],
      'answer': 'Le cheval', 'emoji': '🐴',
      'funFact': 'Les chevaux peuvent dormir debout grâce à leurs articulations qui se bloquent !',
    },
    {
      'id': 'a3', 'question': 'Combien de pattes a une araignée ?',
      'choices': ['6', '8', '10', '4'],
      'answer': '8', 'emoji': '🕷️',
      'funFact': 'Les araignées ont 8 pattes, contrairement aux insectes qui en ont 6 !',
    },
    {
      'id': 'a4', 'question': 'Quel est le plus grand animal du monde ?',
      'choices': ['L\'éléphant', 'La baleine bleue', 'Le requin baleine', 'La girafe'],
      'answer': 'La baleine bleue', 'emoji': '🐋',
      'funFact': 'La baleine bleue peut peser jusqu\'à 200 tonnes — autant que 30 éléphants !',
    },
    {
      'id': 'a5', 'question': 'Quel animal change de couleur ?',
      'choices': ['Le caméléon', 'Le lézard', 'La grenouille', 'Le gecko'],
      'answer': 'Le caméléon', 'emoji': '🦎',
      'funFact': 'Le caméléon change de couleur pour communiquer ses émotions, pas pour se camoufler !',
    },
    {
      'id': 'a6', 'question': 'Quel oiseau ne peut pas voler ?',
      'choices': ['Le pingouin', 'Le perroquet', 'L\'aigle', 'La mouette'],
      'answer': 'Le pingouin', 'emoji': '🐧',
      'funFact': 'Les pingouins "volent" dans l\'eau ! Leurs ailes sont des nageoires parfaites.',
    },
    {
      'id': 'a7', 'question': 'Combien de cœurs a le poulpe ?',
      'choices': ['1', '2', '3', '4'],
      'answer': '3', 'emoji': '🐙',
      'funFact': 'Le poulpe a 3 cœurs et son sang est bleu ! C\'est un vrai super-héros de la mer.',
    },
    {
      'id': 'a8', 'question': 'Quel animal est le plus rapide sur terre ?',
      'choices': ['Le lion', 'Le guépard', 'Le cheval', 'L\'autruche'],
      'answer': 'Le guépard', 'emoji': '🐆',
      'funFact': 'Le guépard peut courir à 110 km/h — aussi vite qu\'une voiture sur autoroute !',
    },
  ];

  // ── ÉMOTIONS & PSYCHOLOGIE ENFANT ─────────────────────────
  static const List<Map<String, dynamic>> emotions = [
    {
      'id': 'e1', 'question': 'Comment te sens-tu quand tu réussis quelque chose ?',
      'type': 'reflection',
      'choices': ['Fier(e) et content(e)', 'Triste', 'En colère', 'Fatigué(e)'],
      'answer': 'Fier(e) et content(e)', 'emoji': '😊',
      'lesson': 'La fierté est une belle émotion ! Elle te dit que tu as bien travaillé. 🌟',
    },
    {
      'id': 'e2', 'question': 'Que fait-on quand on est en colère ?',
      'type': 'strategy',
      'choices': ['On respire 3 fois', 'On crie très fort', 'On frappe', 'On part en courant'],
      'answer': 'On respire 3 fois', 'emoji': '😤',
      'lesson': 'Respirer lentement calme le corps. Inspire 4 secondes, souffle 4 secondes ! 🌬️',
    },
    {
      'id': 'e3', 'question': 'Quelle émotion ressent-on quand quelqu\'un prend notre jouet ?',
      'type': 'identify',
      'choices': ['De la colère', 'De la joie', 'De la surprise', 'De la peur'],
      'answer': 'De la colère', 'emoji': '😠',
      'lesson': 'C\'est normal de ressentir de la colère. L\'important c\'est de dire comment on se sent avec des mots.',
    },
    {
      'id': 'e4', 'question': 'Comment aider un ami qui est triste ?',
      'type': 'empathy',
      'choices': ['L\'écouter et lui faire un câlin', 'L\'ignorer', 'Se moquer de lui', 'Partir jouer ailleurs'],
      'answer': 'L\'écouter et lui faire un câlin', 'emoji': '🤗',
      'lesson': 'L\'empathie c\'est comprendre comment se sent l\'autre. C\'est un super pouvoir ! 💛',
    },
    {
      'id': 'e5', 'question': 'Que ressent-on avant une chose inconnue ?',
      'type': 'identify',
      'choices': ['De l\'appréhension', 'De l\'ennui', 'De la honte', 'Du dégoût'],
      'answer': 'De l\'appréhension', 'emoji': '😨',
      'lesson': 'L\'appréhension (ou peur de l\'inconnu) est normale ! Elle nous prépare à faire face.',
    },
    {
      'id': 'e6', 'question': 'Quand on fait une erreur, que doit-on faire ?',
      'type': 'strategy',
      'choices': ['S\'excuser et apprendre', 'Mentir', 'Pleurer toute la journée', 'Blâmer les autres'],
      'answer': 'S\'excuser et apprendre', 'emoji': '💡',
      'lesson': 'Les erreurs sont nos meilleurs professeurs ! Chaque erreur nous rend plus intelligent(e). 🧠',
    },
  ];

  // ── GÉOGRAPHIE ────────────────────────────────────────────
  static const List<Map<String, dynamic>> geography = [
    {
      'id': 'g1', 'question': 'Quelle est la capitale de la France ?',
      'choices': ['Lyon', 'Paris', 'Marseille', 'Bordeaux'],
      'answer': 'Paris', 'emoji': '🗼',
      'funFact': 'Paris est surnommée la Ville Lumière ! Elle a plus de 2000 ans d\'histoire.',
    },
    {
      'id': 'g2', 'question': 'Combien de continents y a-t-il sur Terre ?',
      'choices': ['5', '6', '7', '8'],
      'answer': '7', 'emoji': '🌍',
      'funFact': 'Les 7 continents sont : Europe, Asie, Afrique, Amériques (Nord+Sud), Océanie, Antarctique !',
    },
    {
      'id': 'g3', 'question': 'Quel est le plus grand océan du monde ?',
      'choices': ['L\'Atlantique', 'L\'Indien', 'Le Pacifique', 'L\'Arctique'],
      'answer': 'Le Pacifique', 'emoji': '🌊',
      'funFact': 'L\'océan Pacifique est si grand qu\'on pourrait y mettre tous les continents !',
    },
    {
      'id': 'g4', 'question': 'Dans quel pays se trouve la Tour Eiffel ?',
      'choices': ['Italie', 'Espagne', 'France', 'Belgique'],
      'answer': 'France', 'emoji': '🗼',
      'funFact': 'La Tour Eiffel a été construite en 1889 pour l\'Exposition Universelle de Paris !',
    },
    {
      'id': 'g5', 'question': 'Quel est le plus long fleuve du monde ?',
      'choices': ['Le Nil', 'L\'Amazone', 'Le Mississippi', 'Le Gange'],
      'answer': 'Le Nil', 'emoji': '🏜️',
      'funFact': 'Le Nil s\'étend sur plus de 6 600 km en Afrique. Il a nourri la civilisation égyptienne !',
    },
    {
      'id': 'g6', 'question': 'Quel pays a le plus grand nombre d\'habitants ?',
      'choices': ['Les États-Unis', 'L\'Inde', 'La Chine', 'Le Brésil'],
      'answer': 'L\'Inde', 'emoji': '🇮🇳',
      'funFact': 'Depuis 2023, l\'Inde est le pays le plus peuplé avec plus de 1,4 milliard d\'habitants !',
    },
  ];

  // ── HISTOIRE ──────────────────────────────────────────────
  static const List<Map<String, dynamic>> history = [
    {
      'id': 'h1', 'question': 'Qui a construit les pyramides ?',
      'choices': ['Les Romains', 'Les Égyptiens', 'Les Grecs', 'Les Mayas'],
      'answer': 'Les Égyptiens', 'emoji': '🏛️',
      'funFact': 'Les pyramides ont été construites il y a 4500 ans ! Les Égyptiens utilisaient des milliers d\'ouvriers.',
    },
    {
      'id': 'h2', 'question': 'Quel était le nom de la première femme astronaute française ?',
      'choices': ['Claudie Haigneré', 'Marie Curie', 'Simone Veil', 'Jeanne d\'Arc'],
      'answer': 'Claudie Haigneré', 'emoji': '🚀',
      'funFact': 'Claudie Haigneré est partie dans l\'espace en 1996 ! Elle est une héroïne des sciences.',
    },
    {
      'id': 'h3', 'question': 'Qui était Jeanne d\'Arc ?',
      'choices': ['Une reine de France', 'Une héroïne qui a défendu la France', 'Une peintre', 'Une scientifique'],
      'answer': 'Une héroïne qui a défendu la France', 'emoji': '⚔️',
      'funFact': 'Jeanne d\'Arc avait 17 ans quand elle a mené l\'armée française ! Une vraie guerrière.',
    },
    {
      'id': 'h4', 'question': 'Depuis quelle année la France célèbre-t-elle le 14 juillet ?',
      'choices': ['1789', '1800', '1945', '1492'],
      'answer': '1789', 'emoji': '🎆',
      'funFact': 'Le 14 juillet 1789, c\'est la Révolution Française ! Les Français ont voulu plus de liberté.',
    },
  ];

  // ── UNIVERS & ESPACE ──────────────────────────────────────
  static const List<Map<String, dynamic>> universe = [
    {
      'id': 'u1', 'question': 'Combien de planètes y a-t-il dans notre système solaire ?',
      'choices': ['7', '8', '9', '10'],
      'answer': '8', 'emoji': '🪐',
      'funFact': 'Pluton était la 9e planète jusqu\'en 2006 ! Elle est maintenant appelée planète naine.',
    },
    {
      'id': 'u2', 'question': 'Quelle est la planète la plus proche du Soleil ?',
      'choices': ['Vénus', 'Mars', 'Mercure', 'La Terre'],
      'answer': 'Mercure', 'emoji': '☀️',
      'funFact': 'Mercure est si proche du Soleil qu\'une année y dure seulement 88 jours !',
    },
    {
      'id': 'u3', 'question': 'Comment s\'appelle notre galaxie ?',
      'choices': ['Andromède', 'La Voie Lactée', 'La Nébuleuse', 'La Grande Ourse'],
      'answer': 'La Voie Lactée', 'emoji': '🌌',
      'funFact': 'La Voie Lactée contient plus de 200 milliards d\'étoiles ! Le Soleil n\'est qu\'une d\'elles.',
    },
    {
      'id': 'u4', 'question': 'Qu\'est-ce qu\'une étoile filante ?',
      'choices': ['Une planète qui tombe', 'Un morceau de roche qui brûle dans l\'atmosphère', 'Un avion', 'Un satellite'],
      'answer': 'Un morceau de roche qui brûle dans l\'atmosphère', 'emoji': '🌠',
      'funFact': 'Les étoiles filantes sont des météorites qui brûlent à cause de la chaleur de l\'air !',
    },
    {
      'id': 'u5', 'question': 'Quelle est la couleur du ciel sur Mars ?',
      'choices': ['Bleu', 'Vert', 'Rouge-rosé', 'Violet'],
      'answer': 'Rouge-rosé', 'emoji': '🔴',
      'funFact': 'Le ciel martien est rouge à cause de la poussière de fer dans l\'atmosphère !',
    },
  ];

  // ── FAITS INCROYABLES 🤯 ─────────────────────────────────
  static const List<Map<String, dynamic>> amazingFacts = [
    {
      'id': 'f1', 'question': 'Combien de secondes dure un battement de cœur ?',
      'choices': ['1 seconde', 'Moins d\'1 seconde', '5 secondes', '2 secondes'],
      'answer': 'Moins d\'1 seconde', 'emoji': '❤️',
      'funFact': 'Ton cœur bat environ 100 000 fois par jour ! C\'est incroyable ! 💓',
    },
    {
      'id': 'f2', 'question': 'Quelle partie du corps ne s\'arrête jamais de grandir ?',
      'choices': ['Les dents', 'Les ongles et les cheveux', 'Les yeux', 'Les oreilles'],
      'answer': 'Les ongles et les cheveux', 'emoji': '💅',
      'funFact': 'Les ongles et cheveux poussent toute la vie ! Les ongles poussent de 3mm par mois.',
    },
    {
      'id': 'f3', 'question': 'Combien d\'os a un bébé à la naissance ?',
      'choices': ['206', '300', '100', '206'],
      'answer': '300', 'emoji': '👶',
      'funFact': 'Les bébés ont 300 os ! Certains fusionnent en grandissant — les adultes n\'en ont que 206.',
    },
    {
      'id': 'f4', 'question': 'Quelle est la vitesse de la lumière ?',
      'choices': ['1 000 km/s', '300 000 km/s', '10 000 km/s', '1 000 000 km/s'],
      'answer': '300 000 km/s', 'emoji': '💡',
      'funFact': 'La lumière est si rapide qu\'elle fait 7 fois le tour de la Terre en 1 seconde !',
    },
    {
      'id': 'f5', 'question': 'Les abeilles communiquent comment ?',
      'choices': ['En faisant un son', 'En dansant', 'En changeant de couleur', 'En tapant des pattes'],
      'answer': 'En dansant', 'emoji': '🐝',
      'funFact': 'Les abeilles font une danse en 8 pour indiquer où se trouve la nourriture. Super communicantes ! 🕺',
    },
  ];

  /// Tous les nouveaux mondes
  static const List<Map<String, dynamic>> worlds = [
    {
      'id': 'animals',   'title': 'Monde Animal',        'emoji': '🦁',
      'color': 0xFF66BB6A, 'questions': animals,
      'mascotId': 'baby_seal',
      'description': 'Découvre les secrets des animaux !',
    },
    {
      'id': 'emotions',  'title': 'Mes Émotions',         'emoji': '💛',
      'color': 0xFFFFCA28, 'questions': emotions,
      'mascotId': 'papa_seal',
      'description': 'Comprends tes émotions et celles des autres',
    },
    {
      'id': 'geography', 'title': 'Tour du Monde',        'emoji': '🌍',
      'color': 0xFF26A69A, 'questions': geography,
      'mascotId': 'ainy_crab',
      'description': 'Voyage autour du monde avec Ainy !',
    },
    {
      'id': 'history',   'title': 'Voyage dans le Temps', 'emoji': '🏛️',
      'color': 0xFF8D6E63, 'questions': history,
      'mascotId': 'barbenoire_cat',
      'description': 'Remonte le temps comme un pirate !',
    },
    {
      'id': 'universe',  'title': 'L\'Univers',           'emoji': '🪐',
      'color': 0xFF5C6BC0, 'questions': universe,
      'mascotId': 'night_squirrel',
      'description': 'Explore les étoiles avec Papa Écureuil',
    },
    {
      'id': 'amazing',   'title': 'Faits Incroyables',    'emoji': '🤯',
      'color': 0xFFAB47BC, 'questions': amazingFacts,
      'mascotId': 'monika_jellyfish',
      'description': 'Des faits fous qui vont t\'épater !',
    },
  ];
}
