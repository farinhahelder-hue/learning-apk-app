/// Théâtre des personnages — comprendre ce que vit quelqu'un d'autre.
///
/// Trois temps par scène :
///
/// 1. **Ce que ressent le personnage.** Il y a une réponse que la scène
///    soutient mieux que les autres, et l'explication montre TOUJOURS sur
///    quel détail elle s'appuie. On ne demande jamais de deviner dans le
///    vide.
/// 2. **Pourquoi.** Une inférence, signalée comme telle.
/// 3. **Ce qu'il pourrait faire.** Là, aucune réponse n'est fausse. Il y a
///    plusieurs façons correctes de réagir à une situation, et s'éloigner
///    un moment en est une. L'application ne classe pas les réactions
///    d'Emilie en bonnes et mauvaises.
///
/// Les scènes évitent volontairement les situations où un personnage se
/// moque d'un autre : l'objectif est de lire une intention, pas de
/// s'entraîner à encaisser.
library;

class TheatreChoice {
  final String label;

  /// Ce que le théâtre répond à ce choix. Jamais « non », jamais « faux ».
  final String response;

  const TheatreChoice({required this.label, required this.response});
}

class TheatreQuestion {
  final String question;
  final List<TheatreChoice> choices;

  /// Le choix le mieux soutenu par la scène. `null` quand la question
  /// n'a pas de bonne réponse — c'est le cas des questions « et toi, que
  /// ferais-tu ? ».
  final String? bestAnswer;

  /// Le détail de la scène sur lequel s'appuie [bestAnswer].
  final String? evidence;

  /// true quand la réponse n'est pas écrite noir sur blanc.
  final bool isInference;

  const TheatreQuestion({
    required this.question,
    required this.choices,
    this.bestAnswer,
    this.evidence,
    this.isInference = false,
  });

  bool get hasBestAnswer => bestAnswer != null;
}

class TheatreScene {
  final String id;
  final String level;
  final String title;
  final String setting;
  final String settingEmoji;

  /// La scène, réplique par réplique. Chaque entrée est « emoji|texte ».
  final List<String> lines;

  final String focusCharacter;
  final String competence;

  /// Les trois temps, dans l'ordre.
  final List<TheatreQuestion> questions;

  const TheatreScene({
    required this.id,
    required this.level,
    required this.title,
    required this.setting,
    required this.settingEmoji,
    required this.lines,
    required this.focusCharacter,
    required this.competence,
    required this.questions,
  });

  String get fullText => lines.map((l) => l.split('|').last).join(' ');
}

class TheatreData {
  static List<TheatreScene> forLevel(String level) =>
      level == 'CE2' ? ce2 : ce1;

  // ══════════════════════════════════════════════════════════
  // CE1 — émotions lisibles, indices explicites
  // ══════════════════════════════════════════════════════════
  static const List<TheatreScene> ce1 = [
    TheatreScene(
      id: 'th_ce1_01',
      level: 'CE1',
      title: 'La tour qui tombe',
      setting: 'Dans la salle de jeux',
      settingEmoji: '🧱',
      focusCharacter: 'Bébé Phoque',
      competence: 'theatre_emotions_ce1',
      lines: [
        '🦭|Bébé Phoque a construit une très haute tour de cubes.',
        '🐿️|Papa Écureuil passe à côté et son sac accroche la tour.',
        '🧱|Tous les cubes tombent par terre.',
        '🦭|Bébé Phoque ne dit rien. Il serre les poings et regarde le sol.',
      ],
      questions: [
        TheatreQuestion(
          question: 'Comment se sent Bébé Phoque ?',
          choices: [
            TheatreChoice(
              label: 'En colère',
              response:
                  'Oui. Il serre les poings : c\'est souvent le signe d\'une '
                  'colère qu\'on garde à l\'intérieur.',
            ),
            TheatreChoice(
              label: 'Content',
              response:
                  'Regarde ce qu\'il fait de son corps : il serre les poings '
                  'et baisse les yeux. On fait rarement ça quand on est content.',
            ),
            TheatreChoice(
              label: 'Fatigué',
              response:
                  'C\'est possible aussi, mais la scène montre surtout sa tour '
                  'qui vient de tomber et ses poings serrés.',
            ),
          ],
          bestAnswer: 'En colère',
          evidence: 'Il serre les poings et regarde le sol.',
        ),
        TheatreQuestion(
          question: 'Pourquoi ne dit-il rien ?',
          choices: [
            TheatreChoice(
              label: 'Il n\'arrive pas à parler tout de suite',
              response:
                  'Quand une émotion est très forte, les mots mettent parfois '
                  'du temps à venir. Ça arrive à beaucoup de gens.',
            ),
            TheatreChoice(
              label: 'Il n\'a rien remarqué',
              response:
                  'Il a forcément remarqué : c\'est sa tour, et il regarde '
                  'les cubes par terre.',
            ),
            TheatreChoice(
              label: 'Il trouve ça drôle',
              response:
                  'Si c\'était drôle pour lui, son corps le montrerait '
                  'autrement — il rirait au lieu de serrer les poings.',
            ),
          ],
          bestAnswer: 'Il n\'arrive pas à parler tout de suite',
          evidence: 'Ce n\'est pas écrit : on le devine à son silence.',
          isInference: true,
        ),
        TheatreQuestion(
          question: 'Que pourrait faire Bébé Phoque ?',
          choices: [
            TheatreChoice(
              label: 'Dire qu\'il est en colère',
              response:
                  'Mettre un mot sur ce qu\'on ressent, c\'est souvent ce qui '
                  'aide le plus — et ça n\'oblige personne à se disputer.',
            ),
            TheatreChoice(
              label: 'S\'éloigner un moment',
              response:
                  'Très bonne idée. Prendre un moment seul pour laisser '
                  'redescendre la colère, ce n\'est pas fuir.',
            ),
            TheatreChoice(
              label: 'Reconstruire sa tour plus tard',
              response:
                  'Oui. Rien ne presse : la tour pourra être refaite quand '
                  'il en aura de nouveau envie.',
            ),
          ],
        ),
      ],
    ),
    TheatreScene(
      id: 'th_ce1_02',
      level: 'CE1',
      title: 'Le bruit de la cantine',
      setting: 'À la cantine',
      settingEmoji: '🍽️',
      focusCharacter: 'Ainy le crabe',
      competence: 'theatre_emotions_ce1',
      lines: [
        '🦀|Ainy s\'assoit à table avec son plateau.',
        '🍽️|Autour, cinquante enfants parlent en même temps. Les couverts claquent.',
        '🦀|Ainy pose ses mains sur ses oreilles et ferme les yeux.',
        '🦭|Bébé Phoque le voit et s\'approche doucement.',
      ],
      questions: [
        TheatreQuestion(
          question: 'Que vit Ainy en ce moment ?',
          choices: [
            TheatreChoice(
              label: 'Il y a trop de bruit pour lui',
              response:
                  'Oui. Il met ses mains sur ses oreilles : son corps essaie '
                  'de faire baisser le bruit tout seul.',
            ),
            TheatreChoice(
              label: 'Il joue à cache-cache',
              response:
                  'La scène ne parle pas de jeu. Elle parle de cinquante voix '
                  'et de couverts qui claquent.',
            ),
            TheatreChoice(
              label: 'Il n\'aime pas son repas',
              response:
                  'Peut-être, mais ce n\'est pas son plateau qu\'il cache : '
                  'ce sont ses oreilles.',
            ),
          ],
          bestAnswer: 'Il y a trop de bruit pour lui',
          evidence: 'Il pose ses mains sur ses oreilles et ferme les yeux.',
        ),
        TheatreQuestion(
          question: 'Pourquoi Bébé Phoque s\'approche-t-il doucement ?',
          choices: [
            TheatreChoice(
              label: 'Pour ne pas ajouter du bruit',
              response:
                  'Exactement. Il a compris que le bruit était le problème, '
                  'donc il en fait le moins possible.',
            ),
            TheatreChoice(
              label: 'Parce qu\'il a peur',
              response:
                  'Rien dans la scène ne dit qu\'il a peur. Il choisit '
                  'simplement d\'être discret.',
            ),
            TheatreChoice(
              label: 'Pour faire une surprise',
              response:
                  'Une surprise serait une mauvaise idée ici : Ainy est déjà '
                  'submergé par ce qui l\'entoure.',
            ),
          ],
          bestAnswer: 'Pour ne pas ajouter du bruit',
          evidence: 'Ce n\'est pas écrit : on le devine parce qu\'il vient « doucement ».',
          isInference: true,
        ),
        TheatreQuestion(
          question: 'Que pourrait faire Ainy ?',
          choices: [
            TheatreChoice(
              label: 'Aller dans un endroit plus calme',
              response:
                  'Oui. Changer d\'endroit quand c\'est trop, c\'est une bonne '
                  'décision, pas un caprice.',
            ),
            TheatreChoice(
              label: 'Demander à un adulte',
              response:
                  'Très bien. Les adultes peuvent souvent proposer une '
                  'solution qu\'on n\'avait pas vue.',
            ),
            TheatreChoice(
              label: 'Garder ses mains sur ses oreilles',
              response:
                  'C\'est déjà une façon de se protéger, et elle marche. '
                  'Il peut la garder aussi longtemps qu\'il en a besoin.',
            ),
          ],
        ),
      ],
    ),
    TheatreScene(
      id: 'th_ce1_03',
      level: 'CE1',
      title: 'Le dessin offert',
      setting: 'Dans la cour',
      settingEmoji: '🎨',
      focusCharacter: 'Monika',
      competence: 'theatre_intentions_ce1',
      lines: [
        '🎐|Monika a passé toute la récréation à faire un dessin.',
        '🎐|Elle le tend à Billy sans rien dire.',
        '🐦|Billy le prend, le regarde longtemps, et le range dans son cartable.',
        '🎐|Monika sourit et repart jouer.',
      ],
      questions: [
        TheatreQuestion(
          question: 'Pourquoi Monika donne-t-elle son dessin à Billy ?',
          choices: [
            TheatreChoice(
              label: 'Pour lui faire plaisir',
              response:
                  'Oui. Elle y a passé toute la récréation et elle le donne : '
                  'c\'est un cadeau.',
            ),
            TheatreChoice(
              label: 'Parce qu\'elle ne l\'aime pas',
              response:
                  'On ne passe pas une récréation entière sur un dessin qu\'on '
                  'veut jeter. Et elle sourit après.',
            ),
            TheatreChoice(
              label: 'Pour qu\'il le termine',
              response:
                  'La scène ne dit pas que le dessin est inachevé, et elle ne '
                  'lui demande rien.',
            ),
          ],
          bestAnswer: 'Pour lui faire plaisir',
          evidence: 'Elle y a passé toute la récréation, puis elle sourit.',
        ),
        TheatreQuestion(
          question: 'Billy n\'a rien dit. Qu\'en penses-tu ?',
          choices: [
            TheatreChoice(
              label: 'Le dessin lui plaît quand même',
              response:
                  'Il l\'a regardé longtemps et rangé dans son cartable pour '
                  'le garder. Les gestes disent parfois plus que les mots.',
            ),
            TheatreChoice(
              label: 'Il n\'aime pas le dessin',
              response:
                  'S\'il ne l\'aimait pas, il ne le rangerait pas '
                  'précieusement dans son cartable.',
            ),
            TheatreChoice(
              label: 'Il n\'a pas compris',
              response:
                  'Il a compris : il l\'a pris, regardé, puis gardé. Il ne l\'a '
                  'simplement pas dit avec des mots.',
            ),
          ],
          bestAnswer: 'Le dessin lui plaît quand même',
          evidence: 'Il le regarde longtemps et le range dans son cartable.',
          isInference: true,
        ),
        TheatreQuestion(
          question: 'Et toi, comment dirais-tu merci ?',
          choices: [
            TheatreChoice(
              label: 'Avec des mots',
              response:
                  'C\'est clair et ça ne laisse pas de doute. Beaucoup de gens '
                  'préfèrent ça.',
            ),
            TheatreChoice(
              label: 'Avec un geste ou un sourire',
              response:
                  'Ça marche très bien aussi. Tout le monde ne dit pas merci '
                  'avec des mots, et ce n\'est pas moins sincère.',
            ),
            TheatreChoice(
              label: 'En faisant un dessin en retour',
              response:
                  'Belle idée : c\'est répondre dans la même langue que le '
                  'cadeau qu\'on a reçu.',
            ),
          ],
        ),
      ],
    ),
  ];

  // ══════════════════════════════════════════════════════════
  // CE2 — intentions plus fines, indices moins directs
  // ══════════════════════════════════════════════════════════
  static const List<TheatreScene> ce2 = [
    TheatreScene(
      id: 'th_ce2_01',
      level: 'CE2',
      title: 'La place gardée',
      setting: 'Dans le bus scolaire',
      settingEmoji: '🚌',
      focusCharacter: 'Ninon',
      competence: 'theatre_intentions_ce2',
      lines: [
        '🐬|Ninon monte dans le bus et pose son sac sur le siège d\'à côté.',
        '🦀|Ainy arrive et demande : « Je peux m\'asseoir ? »',
        '🐬|Ninon enlève son sac tout de suite. « Oui, pardon, je gardais la place pour Monika. »',
        '🐬|Puis elle ajoute : « Mais elle est absente aujourd\'hui, en fait. »',
      ],
      questions: [
        TheatreQuestion(
          question: 'Pourquoi Ninon avait-elle posé son sac là ?',
          choices: [
            TheatreChoice(
              label: 'Elle réservait la place pour une amie',
              response:
                  'Oui, elle le dit elle-même. Ce n\'était pas dirigé contre '
                  'Ainy.',
            ),
            TheatreChoice(
              label: 'Elle ne voulait personne à côté d\'elle',
              response:
                  'Si c\'était ça, elle n\'aurait pas enlevé son sac aussi '
                  'vite ni expliqué pourquoi.',
            ),
            TheatreChoice(
              label: 'Son sac était trop lourd',
              response:
                  'La scène ne parle pas du poids du sac, mais d\'une place '
                  'gardée pour quelqu\'un.',
            ),
          ],
          bestAnswer: 'Elle réservait la place pour une amie',
          evidence: 'Elle le dit : « je gardais la place pour Monika ».',
        ),
        TheatreQuestion(
          question: 'Pourquoi ajoute-t-elle que Monika est absente ?',
          choices: [
            TheatreChoice(
              label: 'Pour montrer qu\'Ainy peut vraiment rester',
              response:
                  'Bien vu. Elle enlève la dernière raison qu\'Ainy aurait de '
                  'se sentir de trop.',
            ),
            TheatreChoice(
              label: 'Pour se plaindre de son absence',
              response:
                  'Elle ne dit rien de triste ni de fâché sur Monika. Elle '
                  'donne juste une information.',
            ),
            TheatreChoice(
              label: 'Parce qu\'elle a oublié ce qu\'elle disait',
              response:
                  'Au contraire : elle complète exprès ce qu\'elle vient de '
                  'dire, avec « en fait ».',
            ),
          ],
          bestAnswer: 'Pour montrer qu\'Ainy peut vraiment rester',
          evidence: 'Ce n\'est pas écrit : on le déduit du moment où elle le dit.',
          isInference: true,
        ),
        TheatreQuestion(
          question: 'Que pourrait faire Ainy ?',
          choices: [
            TheatreChoice(
              label: 'S\'asseoir et la remercier',
              response:
                  'Simple et clair. Ninon a déjà fait comprendre que la place '
                  'était libre.',
            ),
            TheatreChoice(
              label: 'Demander si c\'est vraiment d\'accord',
              response:
                  'C\'est très bien de vérifier quand on n\'est pas sûr. '
                  'Poser la question n\'a rien d\'impoli.',
            ),
            TheatreChoice(
              label: 'Choisir une autre place',
              response:
                  'C\'est un choix valable aussi. On a le droit de préférer '
                  'être seul, même quand une place est libre.',
            ),
          ],
        ),
      ],
    ),
    TheatreScene(
      id: 'th_ce2_02',
      level: 'CE2',
      title: 'Le silence de Papa Phoque',
      setting: 'Après la classe',
      settingEmoji: '📚',
      focusCharacter: 'Papa Phoque',
      competence: 'theatre_intentions_ce2',
      lines: [
        '🦭|Papa Phoque relit le devoir de Bébé Phoque pendant un long moment.',
        '🦭|Il ne dit rien. Il repose la feuille et va préparer le goûter.',
        '🐣|Bébé Phoque, inquiet : « C\'est nul, c\'est ça ? »',
        '🦭|Papa Phoque revient avec deux tartines. « Non. Je cherchais quoi dire d\'assez précis. »',
      ],
      questions: [
        TheatreQuestion(
          question: 'Que veut dire le silence de Papa Phoque ?',
          choices: [
            TheatreChoice(
              label: 'Il réfléchissait à sa réponse',
              response:
                  'Oui, il l\'explique lui-même à la fin : il cherchait quelque '
                  'chose de précis à dire.',
            ),
            TheatreChoice(
              label: 'Le devoir était mauvais',
              response:
                  'Il répond « non » très clairement quand la question lui est '
                  'posée.',
            ),
            TheatreChoice(
              label: 'Il n\'avait pas envie de lire',
              response:
                  'Il a relu le devoir « pendant un long moment » : c\'est le '
                  'contraire du désintérêt.',
            ),
          ],
          bestAnswer: 'Il réfléchissait à sa réponse',
          evidence: 'Il le dit : « Je cherchais quoi dire d\'assez précis. »',
        ),
        TheatreQuestion(
          question: 'Pourquoi Bébé Phoque s\'inquiète-t-il ?',
          choices: [
            TheatreChoice(
              label: 'Il a interprété le silence comme un reproche',
              response:
                  'C\'est ça. Un silence ne veut rien dire tout seul — chacun '
                  'le remplit avec ce qu\'il craint.',
            ),
            TheatreChoice(
              label: 'Son père s\'est fâché',
              response:
                  'Rien dans la scène ne montre de colère : ni cri, ni geste '
                  'brusque.',
            ),
            TheatreChoice(
              label: 'Il n\'aime pas les tartines',
              response:
                  'Il s\'inquiète avant que les tartines arrivent, et sa '
                  'question porte sur son devoir.',
            ),
          ],
          bestAnswer: 'Il a interprété le silence comme un reproche',
          evidence:
              'Ce n\'est pas écrit : on le devine à sa question inquiète.',
          isInference: true,
        ),
        TheatreQuestion(
          question: 'Quand quelqu\'un se tait, que peux-tu faire ?',
          choices: [
            TheatreChoice(
              label: 'Demander ce qu\'il pense',
              response:
                  'C\'est exactement ce que fait Bébé Phoque, et ça marche : '
                  'il obtient une réponse.',
            ),
            TheatreChoice(
              label: 'Attendre un peu',
              response:
                  'Bonne idée aussi. Certaines personnes ont besoin de temps '
                  'avant de répondre.',
            ),
            TheatreChoice(
              label: 'Se dire qu\'un silence ne veut pas dire du mal',
              response:
                  'Très juste. Un silence n\'est pas une réponse : c\'est '
                  'souvent juste du temps qui passe.',
            ),
          ],
        ),
      ],
    ),
    TheatreScene(
      id: 'th_ce2_03',
      level: 'CE2',
      title: 'Le jeu interrompu',
      setting: 'Dans la cour, avant la sonnerie',
      settingEmoji: '⏰',
      focusCharacter: 'Barbe Noire',
      competence: 'theatre_emotions_ce2',
      lines: [
        '🐈‍⬛|Barbe Noire construit un circuit de billes depuis vingt minutes.',
        '⏰|La sonnerie retentit. Il reste une seule pièce à poser.',
        '🐈‍⬛|Barbe Noire ne bouge pas. Il fixe le circuit.',
        '🐿️|Papa Écureuil dit : « Je le laisse là, tu finiras demain. »',
        '🐈‍⬛|Barbe Noire hoche la tête et se lève.',
      ],
      questions: [
        TheatreQuestion(
          question: 'Pourquoi Barbe Noire ne bouge-t-il pas tout de suite ?',
          choices: [
            TheatreChoice(
              label: 'S\'arrêter si près de la fin est difficile',
              response:
                  'Oui. Il reste une seule pièce après vingt minutes : '
                  's\'arrêter là demande un vrai effort.',
            ),
            TheatreChoice(
              label: 'Il n\'a pas entendu la sonnerie',
              response:
                  'S\'il ne l\'avait pas entendue, il continuerait à jouer. '
                  'Or il s\'est figé, ce qui montre qu\'il a compris.',
            ),
            TheatreChoice(
              label: 'Il veut désobéir',
              response:
                  'Il se lève dès qu\'on lui propose une solution. Ce n\'était '
                  'pas de la désobéissance.',
            ),
          ],
          bestAnswer: 'S\'arrêter si près de la fin est difficile',
          evidence: 'Il reste une seule pièce à poser après vingt minutes.',
          isInference: true,
        ),
        TheatreQuestion(
          question: 'Pourquoi la phrase de Papa Écureuil aide-t-elle ?',
          choices: [
            TheatreChoice(
              label: 'Elle promet que le travail ne sera pas perdu',
              response:
                  'Exactement. Ce qui bloquait, ce n\'était pas la sonnerie, '
                  'c\'était l\'idée de tout perdre.',
            ),
            TheatreChoice(
              label: 'Elle donne un ordre plus fort',
              response:
                  'Ce n\'est pas un ordre : c\'est une proposition, et c\'est '
                  'sans doute pour ça qu\'elle passe.',
            ),
            TheatreChoice(
              label: 'Elle change l\'heure de la sonnerie',
              response:
                  'La sonnerie ne change pas. Ce qui change, c\'est ce qui '
                  'arrivera au circuit.',
            ),
          ],
          bestAnswer: 'Elle promet que le travail ne sera pas perdu',
          evidence: 'Il se lève juste après avoir entendu « tu finiras demain ».',
          isInference: true,
        ),
        TheatreQuestion(
          question: 'Que peux-tu demander quand on t\'interrompt ?',
          choices: [
            TheatreChoice(
              label: 'Si tu peux finir plus tard',
              response:
                  'C\'est souvent la question qui débloque tout, comme ici.',
            ),
            TheatreChoice(
              label: 'Un petit moment de plus',
              response:
                  'Demander une minute de plus est légitime. On peut te dire '
                  'non, mais la question est valable.',
            ),
            TheatreChoice(
              label: 'Qu\'on garde ton travail en l\'état',
              response:
                  'Très bonne demande. Savoir qu\'on retrouvera les choses en '
                  'place rend l\'arrêt beaucoup plus facile.',
            ),
          ],
        ),
      ],
    ),
  ];
}
