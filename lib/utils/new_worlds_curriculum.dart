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
    {
      'id': 'e7', 'question': 'Que peux-tu faire si un bruit fort te dérange ?',
      'type': 'strategy',
      'choices': ['Mettre mes mains sur mes oreilles ou demander un endroit calme', 'Crier plus fort que le bruit', 'Rester sans rien dire', 'Courir partout'],
      'answer': 'Mettre mes mains sur mes oreilles ou demander un endroit calme', 'emoji': '🎧',
      'lesson': 'C\'est bien de protéger tes oreilles ou de demander une pause calme quand un bruit te dérange. Ton corps a le droit d\'être écouté. 🎧',
    },
    {
      'id': 'e8', 'question': 'Comment se concentrer quand il y a trop de bruit autour ?',
      'type': 'strategy',
      'choices': ['Demander un endroit plus calme ou un casque', 'Essayer très fort sans rien dire', 'Abandonner l\'activité', 'Se fâcher contre les autres'],
      'answer': 'Demander un endroit plus calme ou un casque', 'emoji': '🎯',
      'lesson': 'Demander de l\'aide pour mieux te concentrer, ce n\'est pas un échec — c\'est une super stratégie ! 🎯',
    },
    {
      'id': 'e9', 'question': 'Que faire quand on doit attendre son tour et que c\'est difficile ?',
      'type': 'strategy',
      'choices': ['Respirer, compter, ou penser à autre chose en attendant', 'Pousser pour passer devant', 'Pleurer très fort', 'Partir en courant'],
      'answer': 'Respirer, compter, ou penser à autre chose en attendant', 'emoji': '⏳',
      'lesson': 'Attendre, c\'est difficile pour tout le monde ! Respirer ou compter jusqu\'à 10 peut vraiment aider. ⏳',
    },
    {
      'id': 'e10', 'question': 'Comment se sent-on souvent avant un grand changement (déménager, nouvelle école) ?',
      'type': 'identify',
      'choices': ['De l\'inquiétude, et c\'est normal', 'Toujours très content', 'Rien du tout', 'Toujours en colère'],
      'answer': 'De l\'inquiétude, et c\'est normal', 'emoji': '😟',
      'lesson': 'Les changements peuvent inquiéter, même les adultes ! En parler aide à se sentir moins seul. 🧡',
    },
    {
      'id': 'e11', 'question': 'Que peut-on faire pour se préparer à un changement (nouvelle activité, nouvel endroit) ?',
      'type': 'strategy',
      'choices': ['Demander ce qui va se passer, à l\'avance', 'Ne rien demander et espérer', 'Refuser d\'y aller', 'Faire semblant que ça n\'arrive pas'],
      'answer': 'Demander ce qui va se passer, à l\'avance', 'emoji': '🗓️',
      'lesson': 'Savoir à l\'avance ce qui va se passer aide beaucoup à se sentir prêt et moins inquiet. 🗓️',
    },
    {
      'id': 'e12', 'question': 'Comment faire une tâche qui semble trop grande (ranger sa chambre, un gros devoir) ?',
      'type': 'strategy',
      'choices': ['La découper en petites étapes', 'Tout faire d\'un coup sans s\'arrêter', 'Ne rien faire', 'Demander à quelqu\'un de tout faire à ma place'],
      'answer': 'La découper en petites étapes', 'emoji': '🧩',
      'lesson': 'Une étape à la fois, et une grande tâche devient beaucoup plus facile ! 🧩',
    },
    {
      'id': 'e13', 'question': 'Que faire quand on sent qu\'on va "exploser" (trop d\'émotions d\'un coup) ?',
      'type': 'strategy',
      'choices': ['Aller dans un coin calme et respirer', 'Garder tout à l\'intérieur', 'Crier sur les autres', 'Casser quelque chose'],
      'answer': 'Aller dans un coin calme et respirer', 'emoji': '🌊',
      'lesson': 'Se retirer un instant dans un endroit calme pour respirer, ce n\'est pas fuir — c\'est prendre soin de soi. 🌊',
    },
    {
      'id': 'e14', 'question': 'Pourquoi est-ce important de demander une pause quand on en a besoin ?',
      'type': 'reflection',
      'choices': ['Parce que ton corps et ton cerveau ont besoin de repos', 'Ce n\'est jamais permis', 'Seulement si on est malade', 'Ça montre qu\'on est faible'],
      'answer': 'Parce que ton corps et ton cerveau ont besoin de repos', 'emoji': '🛑',
      'lesson': 'Demander une pause, c\'est écouter ses besoins. C\'est une force, pas une faiblesse. 🛑💙',
    },
    {
      'id': 'e15', 'question': 'Comment se féliciter après avoir réussi quelque chose de difficile pour soi ?',
      'type': 'reflection',
      'choices': ['Se dire "je suis fier(e) de moi"', 'Passer vite à autre chose sans y penser', 'Dire que ce n\'était rien', 'Attendre que quelqu\'un le remarque'],
      'answer': 'Se dire "je suis fier(e) de moi"', 'emoji': '🏅',
      'lesson': 'Prendre un instant pour se féliciter soi-même, ça fait du bien et ça donne envie de continuer. 🏅',
    },
    {
      'id': 'e16', 'question': 'Que peut-on faire si on ne comprend pas une consigne ?',
      'type': 'strategy',
      'choices': ['Demander de la répéter ou de l\'expliquer autrement', 'Faire semblant d\'avoir compris', 'Abandonner', 'Se sentir bête et ne rien dire'],
      'answer': 'Demander de la répéter ou de l\'expliquer autrement', 'emoji': '❓',
      'lesson': 'Poser une question quand on ne comprend pas, c\'est malin, pas embêtant ! On a tous besoin d\'explications parfois. ❓💡',
    },
  ];

  // ── PETITS PHILOSOPHES ────────────────────────────────────
  // Pas de "mauvaise réponse" ici : chaque choix est une réflexion valable.
  // Voir DiscoveryWorldScreen : world['type'] == 'philo' change l'affichage.
  static const List<Map<String, dynamic>> philosophy = [
    {
      'id': 'ph1', 'question': 'Qu\'est-ce qui rend quelqu\'un vraiment courageux ?',
      'choices': ['Ne jamais avoir peur', 'Avoir peur et le faire quand même', 'Être très fort', 'Ne jamais pleurer'],
      'answer': 'Avoir peur et le faire quand même', 'emoji': '🦸',
      'lesson': 'Le vrai courage, ce n\'est pas l\'absence de peur : c\'est avancer même quand on a peur. 💪',
    },
    {
      'id': 'ph2', 'question': 'Peut-on être ami avec quelqu\'un de très différent de soi ?',
      'choices': ['Oui, la différence rend l\'amitié plus riche', 'Non, il faut se ressembler', 'Seulement un petit peu', 'Je ne sais pas'],
      'answer': 'Oui, la différence rend l\'amitié plus riche', 'emoji': '🤝',
      'lesson': 'Beaucoup de belles amitiés naissent entre personnes différentes : chacun apprend de l\'autre. 🤝',
    },
    {
      'id': 'ph3', 'question': 'Qu\'est-ce que le bonheur, pour toi ?',
      'choices': ['Un moment avec les gens qu\'on aime', 'Avoir plein de jouets', 'Ne jamais être triste', 'Gagner à tous les jeux'],
      'answer': 'Un moment avec les gens qu\'on aime', 'emoji': '😊',
      'lesson': 'Le bonheur, ça peut être tout petit : un câlin, un rire, un rayon de soleil. Il n\'y a pas une seule bonne réponse. ☀️',
    },
    {
      'id': 'ph4', 'question': 'Pourquoi dit-on la vérité, même quand c\'est difficile ?',
      'choices': ['Pour que les autres nous fassent confiance', 'Parce qu\'on n\'a pas le choix', 'Pour éviter les problèmes', 'Ça ne sert à rien'],
      'answer': 'Pour que les autres nous fassent confiance', 'emoji': '💬',
      'lesson': 'Dire la vérité construit la confiance, petit à petit, même quand c\'est dur sur le moment. 🌟',
    },
    {
      'id': 'ph5', 'question': 'Est-ce grave de faire une erreur ?',
      'choices': ['Non, c\'est comme ça qu\'on apprend', 'Oui, il ne faut jamais se tromper', 'Seulement à l\'école', 'Ça dépend des gens'],
      'answer': 'Non, c\'est comme ça qu\'on apprend', 'emoji': '🌱',
      'lesson': 'Les erreurs sont des marches sur le chemin de l\'apprentissage — même les grands se trompent ! 🧗',
    },
    {
      'id': 'ph6', 'question': 'Qu\'est-ce que ça veut dire, être juste ?',
      'choices': ['Traiter les gens équitablement', 'Toujours gagner', 'Avoir toujours raison', 'Être le plus fort'],
      'answer': 'Traiter les gens équitablement', 'emoji': '⚖️',
      'lesson': 'Être juste, c\'est essayer de traiter chacun avec équité, même quand c\'est plus simple de faire autrement. ⚖️',
    },
    {
      'id': 'ph7', 'question': 'Pourquoi est-ce important d\'écouter les autres ?',
      'choices': ['Pour comprendre ce qu\'ils ressentent', 'Pour pouvoir répondre vite', 'Ce n\'est pas important', 'Seulement les adultes doivent écouter'],
      'answer': 'Pour comprendre ce qu\'ils ressentent', 'emoji': '👂',
      'lesson': 'Écouter vraiment quelqu\'un, c\'est lui montrer qu\'il compte. C\'est un des plus beaux cadeaux qu\'on puisse offrir. 👂💛',
    },
    {
      'id': 'ph8', 'question': 'Qu\'est-ce qui te rend unique ?',
      'choices': ['Ma façon de voir le monde', 'Mes passions et mes goûts', 'Mon histoire et mes souvenirs', 'Un mélange de tout ça'],
      'answer': 'Un mélange de tout ça', 'emoji': '🌈',
      'lesson': 'Chaque personne est une combinaison unique d\'histoire, de goûts et de façon de voir les choses. Il n\'y a personne exactement comme toi ! 🌈',
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
    {
      'id': 'g7', 'question': 'Quelle est la plus haute montagne du monde ?',
      'choices': ['L\'Everest', 'Le Mont Blanc', 'Le Kilimandjaro', 'Les Alpes'],
      'answer': 'L\'Everest', 'emoji': '🏔️',
      'funFact': 'L\'Everest culmine à 8 849 mètres, entre le Népal et le Tibet !',
    },
    {
      'id': 'g8', 'question': 'Quel est le plus grand désert chaud du monde ?',
      'choices': ['Le Sahara', 'Le Gobi', 'Le Kalahari', 'L\'Atacama'],
      'answer': 'Le Sahara', 'emoji': '🏜️',
      'funFact': 'Le Sahara est presque aussi grand que les États-Unis !',
    },
    {
      'id': 'g9', 'question': 'Quelle est la plus haute montagne de France ?',
      'choices': ['Le Mont Blanc', 'Le Puy de Dôme', 'Le Mont Ventoux', 'Les Vosges'],
      'answer': 'Le Mont Blanc', 'emoji': '⛰️',
      'funFact': 'Le Mont Blanc culmine à 4 809 mètres, entre la France et l\'Italie !',
    },
    {
      'id': 'g10', 'question': 'Quel est le plus grand pays du monde ?',
      'choices': ['La Chine', 'Le Canada', 'La Russie', 'Les États-Unis'],
      'answer': 'La Russie', 'emoji': '🇷🇺',
      'funFact': 'La Russie s\'étend sur 11 fuseaux horaires différents !',
    },
    {
      'id': 'g11', 'question': 'Comment appelle-t-on les régions les plus froides de la Terre ?',
      'choices': ['Les pôles', 'Les tropiques', 'Les déserts', 'Les plaines'],
      'answer': 'Les pôles', 'emoji': '❄️',
      'funFact': 'Il y a deux pôles : le pôle Nord (Arctique) et le pôle Sud (Antarctique) !',
    },
    {
      'id': 'g12', 'question': 'Quel fleuve traverse Paris ?',
      'choices': ['La Seine', 'La Loire', 'Le Rhône', 'La Garonne'],
      'answer': 'La Seine', 'emoji': '🌉',
      'funFact': 'La Seine traverse Paris sur environ 13 km et compte 37 ponts !',
    },
    {
      'id': 'g13', 'question': 'Sur quel continent se trouve l\'Égypte ?',
      'choices': ['L\'Afrique', 'L\'Asie', 'L\'Europe', 'L\'Amérique'],
      'answer': 'L\'Afrique', 'emoji': '🌍',
      'funFact': 'L\'Égypte est un peu à la frontière entre l\'Afrique et l\'Asie, mais elle est classée en Afrique !',
    },
    {
      'id': 'g14', 'question': 'Quel océan sépare l\'Europe de l\'Amérique ?',
      'choices': ['L\'Atlantique', 'Le Pacifique', 'L\'Indien', 'L\'Arctique'],
      'answer': 'L\'Atlantique', 'emoji': '🌊',
      'funFact': 'Il faut environ 7 heures en avion pour traverser l\'Atlantique entre Paris et New York !',
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
    {
      'id': 'h5', 'question': 'Qui étaient les hommes préhistoriques qui peignaient dans les grottes ?',
      'choices': ['Les hommes de Cro-Magnon', 'Les Gaulois', 'Les Romains', 'Les Vikings'],
      'answer': 'Les hommes de Cro-Magnon', 'emoji': '🎨',
      'funFact': 'Les peintures de la grotte de Lascaux ont environ 17 000 ans !',
    },
    {
      'id': 'h6', 'question': 'Qui était le chef gaulois qui a résisté à Jules César ?',
      'choices': ['Vercingétorix', 'Astérix', 'Clovis', 'Charlemagne'],
      'answer': 'Vercingétorix', 'emoji': '⚔️',
      'funFact': 'Vercingétorix s\'est rendu à Jules César en 52 avant J.-C., lors de la bataille d\'Alésia.',
    },
    {
      'id': 'h7', 'question': 'Qui était le premier roi des Francs à se faire baptiser ?',
      'choices': ['Clovis', 'Charlemagne', 'Louis XIV', 'Napoléon'],
      'answer': 'Clovis', 'emoji': '👑',
      'funFact': 'Le baptême de Clovis, vers l\'an 496, marque le début du royaume de France.',
    },
    {
      'id': 'h8', 'question': 'Quel empereur a été couronné à Noël en l\'an 800 ?',
      'choices': ['Charlemagne', 'Napoléon', 'Clovis', 'Louis XIV'],
      'answer': 'Charlemagne', 'emoji': '👑',
      'funFact': 'Charlemagne a créé des écoles dans tout son empire pour apprendre à lire et à écrire !',
    },
    {
      'id': 'h9', 'question': 'Quel roi de France est surnommé le Roi Soleil ?',
      'choices': ['Louis XIV', 'Louis XVI', 'François Ier', 'Henri IV'],
      'answer': 'Louis XIV', 'emoji': '☀️',
      'funFact': 'Louis XIV a fait construire le magnifique château de Versailles !',
    },
    {
      'id': 'h10', 'question': 'Comment s\'appelle la prison prise d\'assaut le 14 juillet 1789 ?',
      'choices': ['La Bastille', 'Le Louvre', 'Versailles', 'La Conciergerie'],
      'answer': 'La Bastille', 'emoji': '🏰',
      'funFact': 'La prise de la Bastille est devenue le symbole de la fin de la monarchie absolue en France.',
    },
    {
      'id': 'h11', 'question': 'Qui est devenu empereur des Français en 1804 ?',
      'choices': ['Napoléon Bonaparte', 'Louis XVI', 'Charlemagne', 'Louis XIV'],
      'answer': 'Napoléon Bonaparte', 'emoji': '🎖️',
      'funFact': 'Napoléon a créé le Code civil, un ensemble de lois encore utilisé aujourd\'hui en France !',
    },
    {
      'id': 'h12', 'question': 'En quelle année la Seconde Guerre mondiale s\'est-elle terminée ?',
      'choices': ['1945', '1918', '1939', '1989'],
      'answer': '1945', 'emoji': '🕊️',
      'funFact': 'Le 8 mai 1945 marque la fin de la guerre en Europe, c\'est un jour férié en France.',
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
      'choices': ['206', '300', '100', '250'],
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
      'id': 'philosophy', 'title': 'Petits Philosophes', 'emoji': '🦉',
      'color': 0xFF7E57C2, 'questions': philosophy,
      'mascotId': 'papa_seal',
      'type': 'philo',
      'description': 'Réfléchis à de grandes questions, il n\'y a pas de mauvaise réponse !',
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
