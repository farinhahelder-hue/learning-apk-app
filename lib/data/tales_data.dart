/// Histoires à lire ou à écouter, avec questions de compréhension.
///
/// CE1 : récits courts, questions sur des informations explicites.
/// CE2 : récits plus longs, avec des questions d'inférence — il faut
/// deviner ce qui n'est pas écrit noir sur blanc.

class TaleQuestion {
  final String question;
  final List<String> choices;
  final String answer;

  /// Explication donnée après la réponse, quelle qu'elle soit.
  final String explanation;

  /// true si la réponse demande de déduire (implicite).
  final bool isInference;

  const TaleQuestion({
    required this.question,
    required this.choices,
    required this.answer,
    required this.explanation,
    this.isInference = false,
  });
}

class Tale {
  final String id;
  final String level;
  final String title;
  final String emoji;

  /// Le récit, découpé en paragraphes pour ne pas surcharger l'écran.
  final List<String> paragraphs;

  final List<TaleQuestion> questions;
  final String competence;

  const Tale({
    required this.id,
    required this.level,
    required this.title,
    required this.emoji,
    required this.paragraphs,
    required this.questions,
    required this.competence,
  });

  String get fullText => paragraphs.join(' ');
}

class TalesData {
  static List<Tale> forLevel(String level) => level == 'CE2' ? ce2 : ce1;

  // ── CE1 : récits courts, questions explicites ──
  static const List<Tale> ce1 = [
    Tale(
      id: 'tale_ce1_01',
      level: 'CE1',
      title: 'La noisette de Noisette',
      emoji: '🐿️',
      competence: 'lecture_comprehension_ce1',
      paragraphs: [
        'Noisette est un petit écureuil roux. Ce matin, il a trouvé une '
            'grosse noisette au pied du grand chêne.',
        'Il la cache sous une feuille rouge, puis il part jouer avec son ami '
            'le merle. Quand il revient, la feuille a bougé !',
        'C\'est le vent qui l\'a soulevée. La noisette est toujours là. '
            'Noisette est bien content.',
      ],
      questions: [
        TaleQuestion(
          question: 'Où Noisette a-t-il trouvé la noisette ?',
          choices: ['Au pied du grand chêne', 'Dans une maison', 'Sur la plage', 'Dans un arbre creux'],
          answer: 'Au pied du grand chêne',
          explanation: 'C\'est écrit dans la première phrase : au pied du grand chêne.',
        ),
        TaleQuestion(
          question: 'Sous quoi cache-t-il sa noisette ?',
          choices: ['Une feuille rouge', 'Une pierre', 'De la mousse', 'Un chapeau'],
          answer: 'Une feuille rouge',
          explanation: 'Il la cache sous une feuille rouge avant d\'aller jouer.',
        ),
        TaleQuestion(
          question: 'Qui a fait bouger la feuille ?',
          choices: ['Le vent', 'Le merle', 'Un renard', 'Un enfant'],
          answer: 'Le vent',
          explanation: 'L\'histoire le dit : c\'est le vent qui a soulevé la feuille.',
        ),
      ],
    ),
    Tale(
      id: 'tale_ce1_02',
      level: 'CE1',
      title: 'La flaque bleue',
      emoji: '🌧️',
      competence: 'lecture_comprehension_ce1',
      paragraphs: [
        'Il a plu toute la nuit. Ce matin, devant l\'école, il y a une grande '
            'flaque d\'eau.',
        'Lina met ses bottes jaunes et saute dedans. Splash ! L\'eau éclabousse '
            'partout.',
        'Son ami Tom rit très fort. Ensemble, ils comptent les gouttes sur la '
            'vitre de la classe.',
      ],
      questions: [
        TaleQuestion(
          question: 'Quand a-t-il plu ?',
          choices: ['Toute la nuit', 'À midi', 'Pendant la récréation', 'Il n\'a pas plu'],
          answer: 'Toute la nuit',
          explanation: 'La première phrase le dit : il a plu toute la nuit.',
        ),
        TaleQuestion(
          question: 'De quelle couleur sont les bottes de Lina ?',
          choices: ['Jaunes', 'Rouges', 'Bleues', 'Vertes'],
          answer: 'Jaunes',
          explanation: 'Lina met ses bottes jaunes pour sauter dans la flaque.',
        ),
        TaleQuestion(
          question: 'Que comptent Lina et Tom à la fin ?',
          choices: ['Les gouttes sur la vitre', 'Les flaques', 'Les bottes', 'Les nuages'],
          answer: 'Les gouttes sur la vitre',
          explanation: 'À la fin, ils comptent les gouttes sur la vitre de la classe.',
        ),
      ],
    ),
    Tale(
      id: 'tale_ce1_03',
      level: 'CE1',
      title: 'Le phoque qui chantait faux',
      emoji: '🦭',
      competence: 'lecture_voix_haute_ce1',
      paragraphs: [
        'Papa Phoque adore chanter. Le problème, c\'est qu\'il chante très, '
            'très faux.',
        'Les poissons se bouchent les oreilles. Les mouettes s\'envolent. '
            'Mais Papa Phoque continue, tout content.',
        'Un jour, un petit crabe s\'approche et dit : « Moi, j\'aime bien '
            'quand tu chantes. » Papa Phoque sourit jusqu\'aux moustaches.',
      ],
      questions: [
        TaleQuestion(
          question: 'Qu\'est-ce que Papa Phoque adore faire ?',
          choices: ['Chanter', 'Danser', 'Dormir', 'Nager vite'],
          answer: 'Chanter',
          explanation: 'Dès la première phrase : Papa Phoque adore chanter.',
        ),
        TaleQuestion(
          question: 'Que font les mouettes quand il chante ?',
          choices: ['Elles s\'envolent', 'Elles chantent avec lui', 'Elles applaudissent', 'Elles dorment'],
          answer: 'Elles s\'envolent',
          explanation: 'Les poissons se bouchent les oreilles et les mouettes s\'envolent.',
        ),
        TaleQuestion(
          question: 'Qui dit qu\'il aime bien sa chanson ?',
          choices: ['Un petit crabe', 'Une mouette', 'Un poisson', 'Personne'],
          answer: 'Un petit crabe',
          explanation: 'C\'est un petit crabe qui s\'approche et le complimente.',
        ),
      ],
    ),
  ];

  // ── CE2 : récits plus longs, questions d'inférence ──
  static const List<Tale> ce2 = [
    Tale(
      id: 'tale_ce2_01',
      level: 'CE2',
      title: 'Le grenier de grand-mère',
      emoji: '🏚️',
      competence: 'lecture_texte_long_ce2',
      paragraphs: [
        'Chaque été, Jade passe une semaine chez sa grand-mère. Cette année, '
            'elle a enfin le droit de monter au grenier toute seule.',
        'L\'escalier craque sous ses pas. La poussière danse dans le rayon de '
            'soleil qui passe par la petite fenêtre ronde. Il fait chaud, très chaud.',
        'Dans un coin, Jade découvre une malle en bois fermée par une sangle. '
            'À l\'intérieur : des photos jaunies, un carnet à la couverture usée, '
            'et une paire de chaussons de danse rose pâle.',
        'Sur la première page du carnet, une écriture fine : « Mon premier '
            'spectacle — j\'avais huit ans. » Jade regarde les chaussons, puis '
            'l\'escalier, puis les chaussons encore. Elle descend en courant.',
      ],
      questions: [
        TaleQuestion(
          question: 'À quelle saison se passe l\'histoire ?',
          choices: ['En été', 'En hiver', 'Au printemps', 'En automne'],
          answer: 'En été',
          explanation: 'C\'est écrit au début : chaque été, Jade va chez sa grand-mère.',
        ),
        TaleQuestion(
          question: 'Que trouve Jade dans la malle ?',
          choices: [
            'Des photos, un carnet et des chaussons de danse',
            'Des jouets et des livres',
            'Des vêtements et un miroir',
            'Rien du tout',
          ],
          answer: 'Des photos, un carnet et des chaussons de danse',
          explanation: 'La malle contient des photos jaunies, un carnet et des chaussons roses.',
        ),
        TaleQuestion(
          question: 'À qui appartenaient probablement les chaussons ?',
          choices: [
            'À sa grand-mère quand elle était petite',
            'À Jade',
            'À sa maman',
            'À une inconnue',
          ],
          answer: 'À sa grand-mère quand elle était petite',
          explanation:
              'Ce n\'est pas écrit directement : on le devine. Les affaires sont '
              'dans le grenier de la grand-mère, et le carnet parle d\'un premier '
              'spectacle à huit ans.',
          isInference: true,
        ),
        TaleQuestion(
          question: 'Pourquoi Jade descend-elle en courant, à ton avis ?',
          choices: [
            'Pour poser des questions à sa grand-mère',
            'Parce qu\'elle a peur du grenier',
            'Parce qu\'elle a faim',
            'Parce qu\'il est tard',
          ],
          answer: 'Pour poser des questions à sa grand-mère',
          explanation:
              'Le texte ne le dit pas. Mais elle vient de découvrir un secret sur '
              'sa grand-mère : elle a sûrement envie d\'en savoir plus.',
          isInference: true,
        ),
      ],
    ),
    Tale(
      id: 'tale_ce2_02',
      level: 'CE2',
      title: 'La lanterne du phare',
      emoji: '🗼',
      competence: 'lecture_inference_ce2',
      paragraphs: [
        'Le vieux Martin habite le phare depuis quarante ans. Chaque soir, il '
            'monte les cent trente marches pour allumer la lanterne.',
        'Ce soir-là, la tempête est forte. Les vagues frappent les rochers si '
            'haut que l\'écume atteint les vitres. Martin monte plus lentement '
            'que d\'habitude : ses genoux le font souffrir.',
        'En haut, il allume la lanterne. Le faisceau balaie la mer. Au loin, '
            'un tout petit point lumineux clignote trois fois, puis s\'arrête.',
        'Martin sourit et redescend. Demain, il ira au port acheter du pain, '
            'et il saluera le capitaine du chalutier.',
      ],
      questions: [
        TaleQuestion(
          question: 'Combien de marches Martin monte-t-il chaque soir ?',
          choices: ['Cent trente', 'Quarante', 'Trois', 'Cent'],
          answer: 'Cent trente',
          explanation: 'Le texte précise : les cent trente marches du phare.',
        ),
        TaleQuestion(
          question: 'Pourquoi Martin monte-t-il plus lentement ce soir-là ?',
          choices: [
            'Ses genoux lui font mal',
            'Il n\'a pas envie',
            'Il fait trop noir',
            'Il est en retard',
          ],
          answer: 'Ses genoux lui font mal',
          explanation: 'C\'est écrit : ses genoux le font souffrir.',
        ),
        TaleQuestion(
          question: 'Que signifie le petit point qui clignote trois fois ?',
          choices: [
            'Un bateau répond au phare',
            'Une étoile s\'allume',
            'Un orage arrive',
            'Une erreur de la lanterne',
          ],
          answer: 'Un bateau répond au phare',
          explanation:
              'Ce n\'est pas dit clairement. Mais Martin sourit, et il parle du '
              'chalutier le lendemain : le point lumineux était un bateau qui '
              'lui répondait.',
          isInference: true,
        ),
        TaleQuestion(
          question: 'Quel âge a probablement Martin ?',
          choices: [
            'Il est âgé',
            'C\'est un enfant',
            'Il est adolescent',
            'On ne peut rien deviner',
          ],
          answer: 'Il est âgé',
          explanation:
              'Le texte dit « le vieux Martin », qu\'il habite là depuis quarante '
              'ans, et que ses genoux le font souffrir. Tous ces indices vont '
              'dans le même sens.',
          isInference: true,
        ),
      ],
    ),
    Tale(
      id: 'tale_ce2_03',
      level: 'CE2',
      title: 'Le concours de la classe',
      emoji: '🎨',
      competence: 'lecture_personnages_ce2',
      paragraphs: [
        'La maîtresse annonce un concours de dessin. Le thème : « Mon endroit '
            'préféré. » Toute la classe s\'agite.',
        'Sacha dessine sa cabane dans le jardin. Inès choisit la bibliothèque '
            'du quartier. Malo, lui, reste devant sa feuille blanche pendant '
            'vingt minutes.',
        'À la fin de l\'heure, Malo n\'a dessiné qu\'un banc, très simplement, '
            'sous un arbre. « C\'est le banc où je m\'assois quand il y a trop '
            'de bruit dans la cour », explique-t-il doucement.',
        'La maîtresse regarde longuement le dessin. Elle ne dit rien, mais elle '
            'l\'affiche au milieu du tableau.',
      ],
      questions: [
        TaleQuestion(
          question: 'Quel est le thème du concours ?',
          choices: ['Mon endroit préféré', 'Les animaux', 'Les vacances', 'Ma famille'],
          answer: 'Mon endroit préféré',
          explanation: 'La maîtresse annonce le thème : « Mon endroit préféré ».',
        ),
        TaleQuestion(
          question: 'Qu\'a dessiné Inès ?',
          choices: [
            'La bibliothèque du quartier',
            'Une cabane',
            'Un banc',
            'Une plage',
          ],
          answer: 'La bibliothèque du quartier',
          explanation: 'Inès choisit la bibliothèque du quartier.',
        ),
        TaleQuestion(
          question: 'Pourquoi Malo aime-t-il ce banc, à ton avis ?',
          choices: [
            'Parce qu\'il y trouve du calme',
            'Parce qu\'il est joli',
            'Parce que ses amis y sont',
            'Parce qu\'il est neuf',
          ],
          answer: 'Parce qu\'il y trouve du calme',
          explanation:
              'Malo dit qu\'il s\'y assoit « quand il y a trop de bruit dans la '
              'cour ». On devine qu\'il y va pour se reposer du bruit.',
          isInference: true,
        ),
        TaleQuestion(
          question: 'Que pense la maîtresse du dessin de Malo ?',
          choices: [
            'Elle le trouve important',
            'Elle ne l\'aime pas',
            'Elle ne l\'a pas vu',
            'Elle le trouve raté',
          ],
          answer: 'Elle le trouve important',
          explanation:
              'Elle ne dit rien — mais elle l\'affiche au milieu du tableau. '
              'Ce geste en dit plus que des mots.',
          isInference: true,
        ),
      ],
    ),
    Tale(
      id: 'tale_ce2_04',
      level: 'CE2',
      title: 'La nuit du phare',
      emoji: '🗼',
      competence: 'ecouter_recit_ce2',
      paragraphs: [
        'Chaque soir, Jonas monte les cent trente marches du phare. En haut, '
            'il allume la grande lampe qui tourne au-dessus de la mer.',
        'Cette nuit-là, le vent souffle si fort que les vitres tremblent. '
            'Jonas s\'assoit contre le mur et compte les tours de la lampe '
            'pour ne pas penser au bruit.',
        'Vers deux heures du matin, la lampe s\'éteint d\'un coup. Le noir '
            'remplit la pièce. Jonas cherche la lampe de poche dans sa poche, '
            'trouve l\'échelle, et remet le fil à sa place.',
        'Au matin, un pêcheur lui fait signe depuis son bateau. « Ta lumière '
            'est revenue juste à temps », crie-t-il. Jonas répond seulement '
            'par un signe de la main, et redescend dormir.',
      ],
      questions: [
        TaleQuestion(
          question: 'Que fait Jonas chaque soir ?',
          choices: [
            'Il allume la lampe du phare',
            'Il pêche en mer',
            'Il compte les bateaux',
            'Il répare l\'échelle',
          ],
          answer: 'Il allume la lampe du phare',
          explanation:
              'Le texte le dit au début : en haut du phare, il allume la '
              'grande lampe.',
        ),
        TaleQuestion(
          question: 'Pourquoi Jonas compte-t-il les tours de la lampe ?',
          choices: [
            'Pour ne pas penser au bruit du vent',
            'Pour s\'endormir plus vite',
            'Pour vérifier l\'heure',
            'Parce que le pêcheur le lui demande',
          ],
          answer: 'Pour ne pas penser au bruit du vent',
          explanation:
              'Le texte dit qu\'il compte « pour ne pas penser au bruit ». '
              'Compter, c\'est sa façon de se calmer.',
        ),
        TaleQuestion(
          question: 'Pourquoi le pêcheur remercie-t-il Jonas ?',
          choices: [
            'La lumière l\'a aidé à rentrer',
            'Jonas lui a donné du poisson',
            'Jonas a réparé son bateau',
            'Il a dormi dans le phare',
          ],
          answer: 'La lumière l\'a aidé à rentrer',
          explanation:
              'Ce n\'est pas écrit en toutes lettres. Mais il crie « juste à '
              'temps » : sans la lampe, il n\'aurait pas retrouvé son chemin.',
          isInference: true,
        ),
      ],
    ),
    Tale(
      id: 'tale_ce2_05',
      level: 'CE2',
      title: 'Le mot inconnu',
      emoji: '🔍',
      competence: 'vocabulaire_sens_contexte_ce2',
      paragraphs: [
        'Lila lit une lettre de sa grand-mère. « Le jardin est envahi de '
            'lianées », écrit-elle. Lila ne connaît pas ce mot.',
        'Elle continue à lire : « Elles grimpent le long du mur, s\'accrochent '
            'partout, et il faut les couper deux fois par an. »',
        'Lila lève les yeux. Elle regarde par la fenêtre le lierre qui monte '
            'sur la façade de l\'immeuble d\'en face. « Ah, se dit-elle. Je vois '
            'ce que c\'est. »',
        'Elle reprend sa lecture sans aller chercher le dictionnaire.',
      ],
      questions: [
        TaleQuestion(
          question: 'Que sont probablement les « lianées » ?',
          choices: [
            'Des plantes qui grimpent',
            'Des oiseaux du jardin',
            'Des outils de jardinage',
            'Des pierres du mur',
          ],
          answer: 'Des plantes qui grimpent',
          explanation:
              'Le mot n\'est pas expliqué, mais la phrase suivante dit qu\'elles '
              'grimpent le long du mur et qu\'on les coupe : ce sont des plantes.',
          isInference: true,
        ),
        TaleQuestion(
          question: 'Qu\'est-ce qui aide Lila à comprendre le mot ?',
          choices: [
            'Le reste de la phrase',
            'Le dictionnaire',
            'Sa grand-mère au téléphone',
            'Un dessin dans la lettre',
          ],
          answer: 'Le reste de la phrase',
          explanation:
              'Elle devine grâce à ce qui est écrit autour du mot. C\'est ce '
              'qu\'on appelle comprendre grâce au contexte.',
        ),
        TaleQuestion(
          question: 'Pourquoi Lila ne prend-elle pas le dictionnaire ?',
          choices: [
            'Elle a compris toute seule',
            'Elle n\'en a pas',
            'Elle n\'aime pas lire',
            'Sa grand-mère l\'a interdit',
          ],
          answer: 'Elle a compris toute seule',
          explanation:
              'Le texte ne le dit pas directement, mais elle pense « je vois ce '
              'que c\'est » juste avant de reprendre sa lecture.',
          isInference: true,
        ),
      ],
    ),
  ];
}
