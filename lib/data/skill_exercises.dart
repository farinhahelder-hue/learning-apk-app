import '../models/exercise.dart';

/// Exercices rattachés à une compétence précise de la Carte du monde
/// (lib/utils/curriculum.dart), qu'elle soit de niveau CE1 ou CE2.
class SkillExercises {
  static List<Exercise> getBySkill(String skillId) {
    return _all.where((e) => e.id.startsWith(skillId)).toList();
  }

  static const List<Exercise> _all = [
    // --- NOMBRES JUSQU'À 1000 (CE2) ---
    Exercise(id: 'sk_count1000_1', subject: 'math', type: 'qcm',
        question: 'Quel nombre vient après 299 ?',
        options: ['290', '300', '298', '399'], correctAnswer: '300', difficulty: 2, points: 15),
    Exercise(id: 'sk_count1000_2', subject: 'math', type: 'qcm',
        question: 'Combien y a-t-il de dizaines dans 350 ?',
        options: ['3', '5', '35', '350'], correctAnswer: '35', difficulty: 3, points: 20),
    Exercise(id: 'sk_count1000_3', subject: 'math', type: 'qcm',
        question: 'Quel est le chiffre des centaines dans 742 ?',
        options: ['2', '4', '7', '42'], correctAnswer: '7', difficulty: 2, points: 15),
    Exercise(id: 'sk_count1000_4', subject: 'math', type: 'qcm',
        question: 'Combien font 400 + 60 + 5 ?',
        options: ['465', '456', '645', '564'], correctAnswer: '465', difficulty: 2, points: 15),

    // --- TABLES ×6 À ×9 (CE2) ---
    Exercise(id: 'sk_mult6_9_1', subject: 'math', type: 'qcm',
        question: 'Combien font 6 × 7 ?',
        options: ['36', '40', '42', '48'], correctAnswer: '42', difficulty: 2, points: 15),
    Exercise(id: 'sk_mult6_9_2', subject: 'math', type: 'qcm',
        question: 'Combien font 8 × 9 ?',
        options: ['63', '70', '72', '81'], correctAnswer: '72', difficulty: 2, points: 15),
    Exercise(id: 'sk_mult6_9_3', subject: 'math', type: 'qcm',
        question: 'Combien font 7 × 7 ?',
        options: ['42', '45', '49', '56'], correctAnswer: '49', difficulty: 2, points: 15),
    Exercise(id: 'sk_mult6_9_4', subject: 'math', type: 'qcm',
        question: 'Combien font 9 × 6 ?',
        options: ['48', '54', '56', '63'], correctAnswer: '54', difficulty: 3, points: 20),

    // --- DIVISION SIMPLE (CE2) ---
    Exercise(id: 'sk_division_1', subject: 'math', type: 'qcm',
        question: 'Combien font 12 ÷ 4 ?',
        options: ['2', '3', '4', '6'], correctAnswer: '3', difficulty: 2, points: 15),
    Exercise(id: 'sk_division_2', subject: 'math', type: 'qcm',
        question: 'Combien font 20 ÷ 5 ?',
        options: ['3', '4', '5', '6'], correctAnswer: '4', difficulty: 2, points: 15),
    Exercise(id: 'sk_division_3', subject: 'math', type: 'qcm',
        question: 'Combien font 18 ÷ 3 ?',
        options: ['4', '5', '6', '7'], correctAnswer: '6', difficulty: 2, points: 15),
    Exercise(id: 'sk_division_4', subject: 'math', type: 'qcm',
        question: 'Je partage 24 bonbons entre 6 enfants. Chacun en reçoit combien ?',
        options: ['3', '4', '5', '6'], correctAnswer: '4', difficulty: 2, points: 15),

    // --- PÉRIMÈTRE (CE2) ---
    Exercise(id: 'sk_perimeter_1', subject: 'math', type: 'qcm',
        question: 'Un carré a des côtés de 4 cm. Quel est son périmètre ?',
        options: ['8 cm', '12 cm', '16 cm', '4 cm'], correctAnswer: '16 cm', difficulty: 2, points: 15),
    Exercise(id: 'sk_perimeter_2', subject: 'math', type: 'qcm',
        question: 'Un rectangle mesure 5 cm et 3 cm. Quel est son périmètre ?',
        options: ['8 cm', '15 cm', '16 cm', '10 cm'], correctAnswer: '16 cm', difficulty: 3, points: 20),

    // --- IMPARFAIT (CE2) ---
    Exercise(id: 'sk_conj_imparfait_1', subject: 'french', type: 'qcm',
        question: 'Conjugue à l’imparfait : Je ___ (jouer) au parc.',
        options: ['joue', 'jouais', 'jouera', 'jouons'], correctAnswer: 'jouais', difficulty: 2, points: 15),
    Exercise(id: 'sk_conj_imparfait_2', subject: 'french', type: 'qcm',
        question: 'Conjugue à l’imparfait : Il ___ (être) content.',
        options: ['était', 'est', 'sera', 'étant'], correctAnswer: 'était', difficulty: 2, points: 15),
    Exercise(id: 'sk_conj_imparfait_3', subject: 'french', type: 'qcm',
        question: 'Conjugue à l’imparfait : Nous ___ (manger) une pizza.',
        options: ['mangeons', 'mangions', 'mangerons', 'mangeais'], correctAnswer: 'mangions', difficulty: 3, points: 20),

    // --- ADJECTIF QUALIFICATIF (CE2) ---
    Exercise(id: 'sk_gram_adj_1', subject: 'french', type: 'qcm',
        question: 'Dans "une belle fleur rouge", combien y a-t-il d’adjectifs ?',
        options: ['0', '1', '2', '3'], correctAnswer: '2', difficulty: 2, points: 15),
    Exercise(id: 'sk_gram_adj_2', subject: 'french', type: 'qcm',
        question: 'Quel adjectif est au féminin ?',
        options: ['grand', 'petit', 'jolie', 'rapide'], correctAnswer: 'jolie', difficulty: 2, points: 15),
    Exercise(id: 'sk_gram_adj_3', subject: 'french', type: 'qcm',
        question: 'Comment met-on "beau" au pluriel ?',
        options: ['beau', 'beaux', 'beaus', 'belle'], correctAnswer: 'beaux', difficulty: 3, points: 20),

    // --- COMPLÉMENT CIRCONSTANCIEL (CE2) ---
    Exercise(id: 'sk_gram_ccl_1', subject: 'french', type: 'qcm',
        question: 'Dans "Emilie joue dans le jardin", où joue-t-elle ?',
        options: ['Emilie', 'joue', 'dans le jardin', 'le jardin'], correctAnswer: 'dans le jardin', difficulty: 2, points: 15),
    Exercise(id: 'sk_gram_ccl_2', subject: 'french', type: 'qcm',
        question: 'Un complément circonstanciel de lieu répond à la question :',
        options: ['Qui ?', 'Que fait-il ?', 'Où ?', 'Pourquoi ?'], correctAnswer: 'Où ?', difficulty: 2, points: 15),

    // --- MOTS CE2 ---
    Exercise(id: 'sk_spell_ce2_1', subject: 'french', type: 'qcm',
        question: 'Quelle est la bonne orthographe ?',
        options: ['biccyclette', 'bicyclette', 'bisyclette', 'bisiclete'], correctAnswer: 'bicyclette', difficulty: 3, points: 20),
    Exercise(id: 'sk_spell_ce2_2', subject: 'french', type: 'qcm',
        question: 'Quelle est la bonne orthographe du repas du matin ?',
        options: ['ptit déjeuner', 'petit déjeuner', 'petit déjeuné', 'pétit déjeuner'],
        correctAnswer: 'petit déjeuner', difficulty: 2, points: 15),
    Exercise(id: 'sk_spell_ce2_3', subject: 'french', type: 'qcm',
        question: 'Quelle est la bonne orthographe ?',
        options: ['necessaire', 'nécessaire', 'néssessaire', 'nécéssaire'], correctAnswer: 'nécessaire', difficulty: 3, points: 20),

    // ============================================================
    // Compétences ajoutées pour compléter la couverture CE1/CE2
    // ============================================================

    // --- SYMÉTRIE AXIALE (CE1) ---
    Exercise(id: 'sk_symmetry_1', subject: 'math', type: 'qcm',
        question: 'Quelle lettre a un axe de symétrie vertical ?',
        options: ['A', 'F', 'G', 'N'], correctAnswer: 'A', difficulty: 2, points: 15,
        hint: 'Imagine plier la lettre en deux, verticalement.'),
    Exercise(id: 'sk_symmetry_2', subject: 'math', type: 'qcm',
        question: 'Combien d’axes de symétrie a un carré ?',
        options: ['1', '2', '4', '0'], correctAnswer: '4', difficulty: 2, points: 15,
        hint: '2 axes droits + 2 diagonales'),
    Exercise(id: 'sk_symmetry_3', subject: 'math', type: 'qcm',
        question: 'Un axe de symétrie partage une figure en…',
        options: ['2 parties identiques', '3 parties différentes', '4 parties', '2 parties différentes'],
        correctAnswer: '2 parties identiques', difficulty: 1, points: 10),
    Exercise(id: 'sk_symmetry_4', subject: 'math', type: 'qcm',
        question: 'Quelle forme a un axe de symétrie vertical ?',
        options: ['Un cœur ❤️', 'La lettre Z', 'La lettre S', 'Un triangle scalène'],
        correctAnswer: 'Un cœur ❤️', difficulty: 2, points: 15),

    // --- LETTRES MUETTES (CE1) ---
    Exercise(id: 'sk_spell_silent_1', subject: 'french', type: 'qcm',
        question: 'Dans quel mot n’entend-on pas la dernière lettre ?',
        options: ['chat', 'ami', 'stylo', 'radio'], correctAnswer: 'chat', difficulty: 1, points: 10,
        hint: 'Le T final de CHAT ne s’entend pas.'),
    Exercise(id: 'sk_spell_silent_2', subject: 'french', type: 'qcm',
        question: 'Quelle lettre ne s’entend pas dans "trop" ?',
        options: ['t', 'r', 'o', 'p'], correctAnswer: 'p', difficulty: 1, points: 10),
    Exercise(id: 'sk_spell_silent_3', subject: 'french', type: 'qcm',
        question: 'Quelle lettre ne s’entend pas dans "nid" ?',
        options: ['n', 'i', 'd', 'aucune'], correctAnswer: 'd', difficulty: 1, points: 10),
    Exercise(id: 'sk_spell_silent_4', subject: 'french', type: 'writing',
        question: 'Écris le mot "gros" (la dernière lettre ne s’entend pas)',
        prompt: 'Écris : gros', correctAnswer: 'gros', difficulty: 2, points: 15,
        hint: 'G-R-O-S (le S est muet)'),

    // --- ACCENTS ET TIRETS (CE1) ---
    Exercise(id: 'sk_spell_accents_1', subject: 'french', type: 'qcm',
        question: 'Quel mot a un accent aigu (é) ?',
        options: ['élève', 'fenêtre', 'forêt', 'très'], correctAnswer: 'élève', difficulty: 1, points: 10),
    Exercise(id: 'sk_spell_accents_2', subject: 'french', type: 'qcm',
        question: 'Quel mot a un accent circonflexe (ê) ?',
        options: ['fenêtre', 'élève', 'après', 'numéro'], correctAnswer: 'fenêtre', difficulty: 2, points: 15),
    Exercise(id: 'sk_spell_accents_3', subject: 'french', type: 'qcm',
        question: 'Quel mot a un accent grave (è) ?',
        options: ['très', 'école', 'fenêtre', 'numéro'], correctAnswer: 'très', difficulty: 2, points: 15),
    Exercise(id: 'sk_spell_accents_4', subject: 'french', type: 'qcm',
        question: 'Quel mot s’écrit avec un tiret ?',
        options: ['grand-père', 'grandmere', 'petitfils', 'mamie'], correctAnswer: 'grand-père', difficulty: 2, points: 15),
    Exercise(id: 'sk_spell_accents_5', subject: 'french', type: 'writing',
        question: 'Écris le mot "forêt" (n’oublie pas l’accent circonflexe)',
        prompt: 'Écris : forêt', correctAnswer: 'forêt', difficulty: 2, points: 15,
        hint: 'F-O-R-Ê-T'),

    // --- PLURIEL EN -S / -X (CE1) ---
    Exercise(id: 'sk_spell_pluriel_1', subject: 'french', type: 'qcm',
        question: 'Comment écrit-on "un chat" au pluriel ?',
        options: ['un chats', 'des chat', 'des chats', 'les chatx'], correctAnswer: 'des chats', difficulty: 1, points: 10),
    Exercise(id: 'sk_spell_pluriel_2', subject: 'french', type: 'qcm',
        question: 'Comment écrit-on "un chou" au pluriel ?',
        options: ['des chous', 'des choux', 'des choues', 'des chou'], correctAnswer: 'des choux', difficulty: 2, points: 15,
        hint: 'Les mots en -OU prennent souvent un X : chou, bijou, genou...'),
    Exercise(id: 'sk_spell_pluriel_3', subject: 'french', type: 'qcm',
        question: 'Comment écrit-on "un gâteau" au pluriel ?',
        options: ['des gâteaus', 'des gâteaux', 'des gâteau', 'des gâteaues'], correctAnswer: 'des gâteaux', difficulty: 2, points: 15,
        hint: 'Les mots en -EAU prennent un X.'),
    Exercise(id: 'sk_spell_pluriel_4', subject: 'french', type: 'qcm',
        question: 'Comment écrit-on "un cheveu" au pluriel ?',
        options: ['des cheveux', 'des cheveus', 'des cheveu', 'des chevaux'], correctAnswer: 'des cheveux', difficulty: 2, points: 15,
        hint: 'Les mots en -EU prennent un X.'),
    Exercise(id: 'sk_spell_pluriel_5', subject: 'french', type: 'qcm',
        question: 'Comment écrit-on "un pneu" au pluriel ? (exception !)',
        options: ['des pneux', 'des pneus', 'des pneu', 'des pneuxs'], correctAnswer: 'des pneus', difficulty: 3, points: 20,
        hint: 'PNEU fait exception : il prend juste un S.'),

    // --- GN ET GV (CE1) ---
    Exercise(id: 'sk_gram_gns_1', subject: 'french', type: 'qcm',
        question: 'Dans "Le petit chat dort", quel est le groupe nominal (GN) ?',
        options: ['Le petit chat', 'dort', 'petit', 'chat dort'], correctAnswer: 'Le petit chat', difficulty: 2, points: 15),
    Exercise(id: 'sk_gram_gns_2', subject: 'french', type: 'qcm',
        question: 'Dans "Le petit chat dort", quel est le groupe verbal (GV) ?',
        options: ['dort', 'Le petit chat', 'petit', 'Le'], correctAnswer: 'dort', difficulty: 2, points: 15),
    Exercise(id: 'sk_gram_gns_3', subject: 'french', type: 'qcm',
        question: 'Dans "Ma sœur mange une pomme", quel est le GN sujet ?',
        options: ['Ma sœur', 'mange', 'une pomme', 'mange une pomme'], correctAnswer: 'Ma sœur', difficulty: 2, points: 15),
    Exercise(id: 'sk_gram_gns_4', subject: 'french', type: 'qcm',
        question: 'Dans "Les enfants jouent dans le jardin", quel est le GV ?',
        options: ['jouent dans le jardin', 'Les enfants', 'le jardin', 'dans le jardin'],
        correctAnswer: 'jouent dans le jardin', difficulty: 3, points: 20),

    // --- ACCORD SUJET-VERBE (CE1) ---
    Exercise(id: 'sk_gram_accord_1', subject: 'french', type: 'qcm',
        question: 'Complète : Les chats ___ (dormir).',
        options: ['dort', 'dorment', 'dors', 'dormons'], correctAnswer: 'dorment', difficulty: 2, points: 15),
    Exercise(id: 'sk_gram_accord_2', subject: 'french', type: 'qcm',
        question: 'Complète : Le chien ___ (courir).',
        options: ['courent', 'court', 'cours', 'courons'], correctAnswer: 'court', difficulty: 2, points: 15),
    Exercise(id: 'sk_gram_accord_3', subject: 'french', type: 'qcm',
        question: 'Complète : Nous ___ (chanter) une chanson.',
        options: ['chante', 'chantez', 'chantons', 'chantent'], correctAnswer: 'chantons', difficulty: 1, points: 10),
    Exercise(id: 'sk_gram_accord_4', subject: 'french', type: 'qcm',
        question: 'Complète : Mes amis ___ (arriver) demain.',
        options: ['arrive', 'arrivent', 'arrives', 'arrivons'], correctAnswer: 'arrivent', difficulty: 2, points: 15),

    // --- PASSÉ COMPOSÉ (CE1) ---
    Exercise(id: 'sk_conj_passe_1', subject: 'french', type: 'qcm',
        question: 'Conjugue au passé composé : Je ___ (manger) une pomme.',
        options: ['ai mangé', 'mange', 'mangerai', 'mangeais'], correctAnswer: 'ai mangé', difficulty: 2, points: 15),
    Exercise(id: 'sk_conj_passe_2', subject: 'french', type: 'qcm',
        question: 'Conjugue au passé composé : Tu ___ (aller) à l’école.',
        options: ['es allé', 'vas', 'iras', 'allais'], correctAnswer: 'es allé', difficulty: 2, points: 15),
    Exercise(id: 'sk_conj_passe_3', subject: 'french', type: 'qcm',
        question: 'Conjugue au passé composé : Elle ___ (jouer) dans le jardin.',
        options: ['a joué', 'joue', 'jouera', 'jouait'], correctAnswer: 'a joué', difficulty: 2, points: 15),
    Exercise(id: 'sk_conj_passe_4', subject: 'french', type: 'qcm',
        question: 'Conjugue au passé composé : Nous ___ (finir) nos devoirs.',
        options: ['avons fini', 'finissons', 'finirons', 'finissions'], correctAnswer: 'avons fini', difficulty: 3, points: 20),

    // --- FUTUR SIMPLE (CE1) ---
    Exercise(id: 'sk_conj_futur_1', subject: 'french', type: 'qcm',
        question: 'Conjugue au futur simple : Je ___ (manger) une pomme demain.',
        options: ['mangerai', 'mange', 'ai mangé', 'mangeais'], correctAnswer: 'mangerai', difficulty: 2, points: 15),
    Exercise(id: 'sk_conj_futur_2', subject: 'french', type: 'qcm',
        question: 'Conjugue au futur simple : Tu ___ (jouer) demain.',
        options: ['joueras', 'joues', 'as joué', 'jouais'], correctAnswer: 'joueras', difficulty: 2, points: 15),
    Exercise(id: 'sk_conj_futur_3', subject: 'french', type: 'qcm',
        question: 'Conjugue au futur simple : Nous ___ (partir) en vacances.',
        options: ['partirons', 'partons', 'sommes partis', 'partions'], correctAnswer: 'partirons', difficulty: 2, points: 15),
    Exercise(id: 'sk_conj_futur_4', subject: 'french', type: 'qcm',
        question: 'Conjugue au futur simple : Ils ___ (être) contents.',
        options: ['seront', 'sont', 'ont été', 'étaient'], correctAnswer: 'seront', difficulty: 3, points: 20),

    // --- VOLUMES : L, cL (CE2) ---
    Exercise(id: 'sk_volume_1', subject: 'math', type: 'qcm',
        question: 'Combien de centilitres (cL) y a-t-il dans 1 litre (L) ?',
        options: ['10', '100', '1000', '50'], correctAnswer: '100', difficulty: 2, points: 15),
    Exercise(id: 'sk_volume_2', subject: 'math', type: 'qcm',
        question: 'Une bouteille contient 1 L. Combien de verres de 20 cL peut-on remplir ?',
        options: ['4', '5', '10', '2'], correctAnswer: '5', difficulty: 3, points: 20),
    Exercise(id: 'sk_volume_3', subject: 'math', type: 'qcm',
        question: 'Combien font 2 L + 50 cL, en centilitres ?',
        options: ['250 cL', '205 cL', '52 cL', '2050 cL'], correctAnswer: '250 cL', difficulty: 3, points: 20),
    Exercise(id: 'sk_volume_4', subject: 'math', type: 'qcm',
        question: 'Quel objet contient environ 1 litre de liquide ?',
        options: ['Une brique de lait', 'Une piscine', 'Une cuillère', 'Un dé à coudre'],
        correctAnswer: 'Une brique de lait', difficulty: 1, points: 10),

    // --- TEXTE NARRATIF LONG (CE2) ---
    Exercise(id: 'sk_read_long_1', subject: 'french', type: 'qcm',
        question: 'Lis : "Le matin, Léo se réveille tôt. Il prend son petit-déjeuner puis part '
            'à l’école avec son sac à dos rouge. Sur le chemin, il retrouve son amie Zoé et ils '
            'marchent ensemble en discutant de leur sortie au zoo prévue pour vendredi." '
            'Quelle couleur est le sac de Léo ?',
        options: ['rouge', 'bleu', 'vert', 'noir'], correctAnswer: 'rouge', difficulty: 2, points: 15),
    Exercise(id: 'sk_read_long_2', subject: 'french', type: 'qcm',
        question: 'Lis : "Un samedi après-midi, la petite souris Noisette explore le grenier de '
            'la vieille maison. Elle trouve une boîte pleine de vieilles photos et un chapeau '
            'poussiéreux. Soudain, elle entend un bruit et se cache derrière une malle en bois." '
            'Que trouve Noisette dans le grenier ?',
        options: ['Une boîte de photos et un chapeau', 'Un fromage', 'Un livre', 'Un miroir'],
        correctAnswer: 'Une boîte de photos et un chapeau', difficulty: 2, points: 15),
    Exercise(id: 'sk_read_long_3', subject: 'french', type: 'qcm',
        question: 'Lis : "Emma adore jardiner avec sa grand-mère. Ensemble, elles plantent des '
            'tomates, des carottes et des fraises. Chaque matin, Emma arrose les plantes avant '
            'd’aller à l’école. Elle a hâte de goûter les premières fraises de l’été." '
            'Quel fruit Emma a-t-elle hâte de goûter ?',
        options: ['Les fraises', 'Les tomates', 'Les carottes', 'Les pommes'],
        correctAnswer: 'Les fraises', difficulty: 2, points: 15),
    Exercise(id: 'sk_read_long_4', subject: 'french', type: 'qcm',
        question: 'Lis : "Le vieux pêcheur partait chaque matin avant le lever du soleil. Il '
            'ramait doucement pour ne pas réveiller les mouettes endormies sur les rochers. Ce '
            'jour-là, il remonta son filet et découvrit, émerveillé, un magnifique poisson aux '
            'écailles dorées." Que découvre le pêcheur dans son filet ?',
        options: ['Un poisson aux écailles dorées', 'Une bouteille', 'Un trésor', 'Rien du tout'],
        correctAnswer: 'Un poisson aux écailles dorées', difficulty: 3, points: 20),

    // --- INFÉRER L'IMPLICITE (CE2) ---
    Exercise(id: 'sk_read_infer_1', subject: 'french', type: 'qcm',
        question: 'Léa met son manteau, son écharpe et ses bottes avant de sortir. '
            'Quel temps fait-il probablement ?',
        options: ['Il fait froid', 'Il fait très chaud', 'C’est l’été', 'Il fait nuit'],
        correctAnswer: 'Il fait froid', difficulty: 2, points: 15),
    Exercise(id: 'sk_read_infer_2', subject: 'french', type: 'qcm',
        question: 'Paul rentre à la maison trempé, avec un parapluie cassé à la main. '
            'Que s’est-il probablement passé ?',
        options: ['Il a marché sous la pluie et son parapluie s’est cassé', 'Il est tombé dans la piscine',
          'Il a fait la vaisselle', 'Il a arrosé le jardin'],
        correctAnswer: 'Il a marché sous la pluie et son parapluie s’est cassé', difficulty: 3, points: 20),
    Exercise(id: 'sk_read_infer_3', subject: 'french', type: 'qcm',
        question: 'La salle de classe est silencieuse, tous les enfants ont la tête baissée sur '
            'leur feuille. Que sont-ils probablement en train de faire ?',
        options: ['Un contrôle ou un exercice', 'La récréation', 'Un chant', 'Une sieste'],
        correctAnswer: 'Un contrôle ou un exercice', difficulty: 2, points: 15),
    Exercise(id: 'sk_read_infer_4', subject: 'french', type: 'qcm',
        question: 'Le chien remue la queue et court vers la porte dès qu’il entend une clé '
            'tourner dans la serrure. Que va-t-il probablement se passer ?',
        options: ['Quelqu’un de la famille rentre', 'Il va pleuvoir', 'Le chien va manger', 'Le chien va dormir'],
        correctAnswer: 'Quelqu’un de la famille rentre', difficulty: 2, points: 15),
  ];
}
