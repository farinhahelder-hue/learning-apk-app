import '../models/exercise.dart';
import '../models/mascot.dart';

class FrenchExercises {
  static List<Exercise> getByCategory(String category) {
    return _all.where((e) => e.id.startsWith(category)).toList();
  }

  static const List<Exercise> _all = [
    // --- ÉCRITURE (Writing exercises) ---
    Exercise(id: 'ecriture_1', subject: 'french', type: 'writing',
        question: 'Écris le mot "chat"',
        prompt: 'Écris : chat', correctAnswer: 'chat', difficulty: 1, points: 15,
        mascot: Mascot.seal, hint: "C'est un animal qui fait \"miaou\""),
    Exercise(id: 'ecriture_2', subject: 'french', type: 'writing',
        question: 'Écris le mot "maison"',
        prompt: 'Écris : maison', correctAnswer: 'maison', difficulty: 1, points: 15,
        mascot: Mascot.seal, hint: "Où tu habites"),
    Exercise(id: 'ecriture_3', subject: 'french', type: 'writing',
        question: "Complète : l'_ _ _ _ (animal qui fait miaou)",
        prompt: 'Écris le mot', correctAnswer: 'chat', difficulty: 1, points: 15,
        mascot: Mascot.seal, hint: 'CHAT'),
    Exercise(id: 'ecriture_4', subject: 'french', type: 'writing',
        question: 'Écris le mot "école"',
        prompt: 'Écris : école', correctAnswer: 'école', difficulty: 2, points: 20,
        mascot: Mascot.seal, hint: "Lieu d'apprentissage"),
    Exercise(id: 'ecriture_5', subject: 'french', type: 'writing',
        question: 'Écris le mot "papillon"',
        prompt: 'Écris : papillon', correctAnswer: 'papillon', difficulty: 2, points: 20,
        mascot: Mascot.seal, hint: 'Un insecte coloré'),
    Exercise(id: 'ecriture_6', subject: 'french', type: 'writing',
        question: "Écris le mot \"bonjour\" pour saluer",
        prompt: 'Écris : bonjour', correctAnswer: 'bonjour', difficulty: 1, points: 15,
        mascot: Mascot.seal, hint: 'Salutation'),
    Exercise(id: 'ecriture_7', subject: 'french', type: 'writing',
        question: 'Écris le nom du roi de la jungle',
        prompt: 'Écris : lion', correctAnswer: 'lion', difficulty: 1, points: 15,
        mascot: Mascot.seal, hint: 'ROAR'),
    Exercise(id: 'ecriture_8', subject: 'french', type: 'writing',
        question: 'Écris la couleur du ciel',
        prompt: 'Écris : bleu', correctAnswer: 'bleu', difficulty: 1, points: 15,
        mascot: Mascot.seal, hint: 'La couleur du ciel est...'),

    // --- LECTURE (Reading exercises) ---
    Exercise(id: 'lecture_1', subject: 'french', type: 'qcm',
        question: 'Lis : "Le chat mange une souris" - Qui mange ?',
        options: ['La souris', 'Le chat', 'Un élève', 'La maîtresse'],
        correctAnswer: 'Le chat', difficulty: 1, points: 10, mascot: Mascot.seal),
    Exercise(id: 'lecture_2', subject: 'french', type: 'qcm',
        question: 'Lis : "Marie lit un livre rouge" - Quelle est la couleur du livre ?',
        options: ['Bleu', 'Vert', 'Rouge', 'Jaune'],
        correctAnswer: 'Rouge', difficulty: 1, points: 10, mascot: Mascot.seal),
    Exercise(id: 'lecture_3', subject: 'french', type: 'qcm',
        question: "Qu'est-ce qu'une histoire qui fait rire ?",
        options: ['Une poésie', 'Une blague', 'Un poisson', 'Une lettre'],
        correctAnswer: 'Une blague', difficulty: 1, points: 10, mascot: Mascot.seal),
    Exercise(id: 'lecture_4', subject: 'french', type: 'qcm',
        question: 'Quel animal dit "Cocorico" ?',
        options: ['Le chien', 'Le coq', 'La vache', 'Le chat'],
        correctAnswer: 'Le coq', difficulty: 1, points: 10, mascot: Mascot.seal),
    Exercise(id: 'lecture_5', subject: 'french', type: 'qcm',
        question: 'Quel animal vit dans l\'eau et fait des bulles ?',
        options: ['Le chat', 'Le poisson', 'L\'oiseau', 'Le lapin'],
        correctAnswer: 'Le poisson', difficulty: 1, points: 10, mascot: Mascot.seal),
    Exercise(id: 'lecture_6', subject: 'french', type: 'qcm',
        question: 'Quel insecte a des ailes colorées ?',
        options: ['La fourmi', 'Le papillon', 'Le cafard', 'L\'araignée'],
        correctAnswer: 'Le papillon', difficulty: 1, points: 10, mascot: Mascot.seal),

    // --- COMPLÉTER MOTS (Complete words) ---
    Exercise(id: 'complet_1', subject: 'french', type: 'complete',
        question: 'Complète : la g _ _ _ _ (animal à cou long)',
        displayWord: 'la g _ _ _ _', correctAnswer: 'girafe', difficulty: 1, points: 15,
        mascot: Mascot.squirrel, hint: 'GIRAFE'),
    Exercise(id: 'complet_2', subject: 'french', type: 'complete',
        question: 'Complète : un c _ _ _ _ (animal qui fait miaou)',
        displayWord: 'un c _ _ _ _', correctAnswer: 'chat', difficulty: 1, points: 15,
        mascot: Mascot.squirrel, hint: 'CHAT'),
    Exercise(id: 'complet_3', subject: 'french', type: 'complete',
        question: "Complète : l'_ _ _ _ _ (lieu d'apprentissage)",
        displayWord: "l'_ _ _ _ _", correctAnswer: 'école', difficulty: 2, points: 20,
        mascot: Mascot.squirrel, hint: 'ÉCOLE'),
    Exercise(id: 'complet_4', subject: 'french', type: 'complete',
        question: 'Trouve le fruit : b _ _ _ n e',
        displayWord: 'b _ _ _ n e', correctAnswer: 'banane', difficulty: 1, points: 15,
        mascot: Mascot.squirrel, hint: 'BANANE'),
    Exercise(id: 'complet_5', subject: 'french', type: 'complete',
        question: "Complète : la r _ _ _ _ (animal qui rugit)",
        displayWord: 'la r _ _ _ _', correctAnswer: 'girafe', difficulty: 2, points: 20,
        mascot: Mascot.squirrel, hint: 'LION'),
    Exercise(id: 'complet_6', subject: 'french', type: 'complete',
        question: 'Le contraire de nuit : j _ _ _',
        displayWord: 'j _ _ _', correctAnswer: 'jour', difficulty: 1, points: 15,
        mascot: Mascot.squirrel, hint: 'JOUR'),
    Exercise(id: 'complet_7', subject: 'french', type: 'complete',
        question: 'Un point sur la tête : t _ _ _',
        displayWord: 't _ _ _', correctAnswer: 'tête', difficulty: 1, points: 15,
        mascot: Mascot.squirrel, hint: 'TÊTE'),
    Exercise(id: 'complet_8', subject: 'french', type: 'complete',
        question: "Animal noir et blanc : p _ n g _ _ _ n",
        displayWord: 'p _ n g _ _ _ n', correctAnswer: 'pingouin', difficulty: 2, points: 20,
        mascot: Mascot.squirrel, hint: 'PINGOUIN'),

    // --- PHONÉTIQUE (Phonics) ---
    Exercise(id: 'phonetique_1', subject: 'french', type: 'phonetic',
        question: 'Quel son entends-tu dans "chat" ? (a ou o)',
        phoneticTarget: 'a', correctAnswer: 'a', difficulty: 1, points: 15,
        mascot: Mascot.jellyfish, audioWord: 'chat'),
    Exercise(id: 'phonetique_2', subject: 'french', type: 'phonetic',
        question: 'Quel son à la fin de "bateau" ?',
        phoneticTarget: 'o', correctAnswer: 'o', difficulty: 2, points: 20,
        mascot: Mascot.jellyfish, audioWord: 'bateau'),
    Exercise(id: 'phonetique_3', subject: 'french', type: 'phonetic',
        question: 'Compte les syllabes dans "hippopotame"',
        phoneticTarget: 'syllables', correctAnswer: '5', difficulty: 2, points: 20,
        mascot: Mascot.jellyfish, audioWord: 'hippopotame'),
    Exercise(id: 'phonetique_4', subject: 'french', type: 'phonetic',
        question: 'Quel son dans "sauter" ? (o)',
        phoneticTarget: 'o', correctAnswer: 'o', difficulty: 1, points: 15,
        mascot: Mascot.jellyfish, audioWord: 'sauter'),
    Exercise(id: 'phonetique_5', subject: 'french', type: 'phonetic',
        question: 'Trouve le mot qui rime avec "chat"',
        options: ['poney', 'rat', 'voiture', 'livre'],
        correctAnswer: 'rat', difficulty: 1, points: 15, mascot: Mascot.jellyfish),
    Exercise(id: 'phonetique_6', subject: 'french', type: 'phonetic',
        question: 'Quel son commence "marron" ? (m)',
        phoneticTarget: 'm', correctAnswer: 'm', difficulty: 1, points: 15,
        mascot: Mascot.jellyfish, audioWord: 'marron'),
    Exercise(id: 'phonetique_7', subject: 'french', type: 'phonetic',
        question: 'Rime "ami" avec...',
        options: ['tapis', 'dur', 'aime', 'lundi'],
        correctAnswer: 'aime', difficulty: 1, points: 15, mascot: Mascot.jellyfish),

    // --- ORTHOGRAPHE ---
    Exercise(id: 'orthographe_1', subject: 'french', type: 'qcm',
        question: "Comment s'écrit l'animal qui fait \"miaou\" ?",
        options: ['cha', 'chat', 'sha', 'chats'],
        correctAnswer: 'chat', difficulty: 1, points: 10, mascot: Mascot.seal),
    Exercise(id: 'orthographe_2', subject: 'french', type: 'qcm',
        question: 'Quelle est la bonne orthographe ?',
        options: ['maision', 'maison', 'meison', 'mazon'],
        correctAnswer: 'maison', difficulty: 1, points: 10, mascot: Mascot.seal),
    Exercise(id: 'orthographe_3', subject: 'french', type: 'qcm',
        question: 'Quelle est la bonne écriture du fruit jaune ?',
        options: ['banane', 'bananee', 'bannane', 'bananne'],
        correctAnswer: 'banane', difficulty: 1, points: 10, mascot: Mascot.seal),
    Exercise(id: 'orthographe_4', subject: 'french', type: 'qcm',
        question: "Comment écrit-on l'animal qui pond des œufs ?",
        options: ['poule', 'poulle', 'pol', 'poul'],
        correctAnswer: 'poule', difficulty: 1, points: 10, mascot: Mascot.seal),
    Exercise(id: 'orthographe_5', subject: 'french', type: 'qcm',
        question: "Quelle est la bonne orthographe de l'école ?",
        options: ['ecole', 'école', 'Ecole', 'écol'],
        correctAnswer: 'école', difficulty: 2, points: 15, mascot: Mascot.seal),
    Exercise(id: 'orthographe_6', subject: 'french', type: 'qcm',
        question: 'Comment écrit-on le petit du chat ?',
        options: ['chaton', 'chatton', 'shaton', 'cchaton'],
        correctAnswer: 'chaton', difficulty: 1, points: 10, mascot: Mascot.seal),
    Exercise(id: 'orthographe_7', subject: 'french', type: 'qcm',
        question: 'Le mot pour dire "pas cher" : g _ _ _ _',
        options: ['gratuit', 'pas cher', 'bio', 'local'],
        correctAnswer: 'gratuit', difficulty: 2, points: 15, mascot: Mascot.seal),

    // --- CONJUGAISON ---
    Exercise(id: 'conjugaison_1', subject: 'french', type: 'qcm',
        question: 'Conjugue : Je ___ (manger) au présent.',
        options: ['mange', 'manges', 'mangez', 'mangent'],
        correctAnswer: 'mange', difficulty: 1, points: 10, mascot: Mascot.squirrel),
    Exercise(id: 'conjugaison_2', subject: 'french', type: 'qcm',
        question: 'Conjugue : Tu ___ (jouer) au présent.',
        options: ['joue', 'joues', 'jouez', 'jouent'],
        correctAnswer: 'joues', difficulty: 1, points: 10, mascot: Mascot.squirrel),
    Exercise(id: 'conjugaison_3', subject: 'french', type: 'qcm',
        question: 'Conjugue : Nous ___ (chanter) au présent.',
        options: ['chante', 'chantes', 'chantons', 'chantez'],
        correctAnswer: 'chantons', difficulty: 2, points: 15, mascot: Mascot.squirrel),
    Exercise(id: 'conjugaison_4', subject: 'french', type: 'qcm',
        question: 'Conjugue : Ils ___ (courir) au présent.',
        options: ['courent', 'courons', 'courez', 'court'],
        correctAnswer: 'courent', difficulty: 2, points: 15, mascot: Mascot.squirrel),
    Exercise(id: 'conjugaison_5', subject: 'french', type: 'qcm',
        question: 'Conjugue : Elle ___ (être) au présent.',
        options: ['est', 'es', 'êtes', 'suis'],
        correctAnswer: 'est', difficulty: 1, points: 10, mascot: Mascot.squirrel),
    Exercise(id: 'conjugaison_6', subject: 'french', type: 'qcm',
        question: 'Conjugue : Je ___ (être) au présent.',
        options: ['suis', 'est', 'es', 'êtes'],
        correctAnswer: 'suis', difficulty: 1, points: 10, mascot: Mascot.squirrel),

    // --- VOCABULAIRE ---
    Exercise(id: 'vocabulaire_1', subject: 'french', type: 'qcm',
        question: 'Quel est le contraire de "grand" ?',
        options: ['gros', 'petit', 'long', 'haut'],
        correctAnswer: 'petit', difficulty: 1, points: 10, mascot: Mascot.jellyfish),
    Exercise(id: 'vocabulaire_2', subject: 'french', type: 'qcm',
        question: 'Quel est le contraire de "chaud" ?',
        options: ['tiède', 'froid', 'brûlant', 'humide'],
        correctAnswer: 'froid', difficulty: 1, points: 10, mascot: Mascot.jellyfish),
    Exercise(id: 'vocabulaire_3', subject: 'french', type: 'qcm',
        question: 'Quel mot signifie "heureux" ?',
        options: ['triste', 'joyeux', 'colère', 'fatigue'],
        correctAnswer: 'joyeux', difficulty: 1, points: 10, mascot: Mascot.jellyfish),
    Exercise(id: 'vocabulaire_4', subject: 'french', type: 'qcm',
        question: 'Comment appelle-t-on le petit du chien ?',
        options: ['chaton', 'chiot', 'poulain', 'lapereau'],
        correctAnswer: 'chiot', difficulty: 1, points: 10, mascot: Mascot.jellyfish),
    Exercise(id: 'vocabulaire_5', subject: 'french', type: 'qcm',
        question: 'Quel est le féminin de "acteur" ?',
        options: ['acteuse', 'actrice', 'acterice', 'acteure'],
        correctAnswer: 'actrice', difficulty: 2, points: 15, mascot: Mascot.jellyfish),
    Exercise(id: 'vocabulaire_6', subject: 'french', type: 'qcm',
        question: 'Comment appelle-t-on le bébé cheval ?',
        options: ['veau', 'poulain', 'agneau', 'canard'],
        correctAnswer: 'poulain', difficulty: 2, points: 15, mascot: Mascot.jellyfish),

    // --- GRAMMAIRE ---
    Exercise(id: 'grammaire_1', subject: 'french', type: 'qcm',
        question: 'Dans "le gros chien aboie", quel est le sujet ?',
        options: ['gros', 'chien', 'le gros chien', 'aboie'],
        correctAnswer: 'le gros chien', difficulty: 2, points: 15, mascot: Mascot.seal),
    Exercise(id: 'grammaire_2', subject: 'french', type: 'qcm',
        question: "Quel est l'article féminin ?",
        options: ['le', 'la', 'les', 'un'],
        correctAnswer: 'la', difficulty: 1, points: 10, mascot: Mascot.seal),
    Exercise(id: 'grammaire_3', subject: 'french', type: 'qcm',
        question: 'Mets au pluriel : "un chat" →',
        options: ['un chats', 'des chat', 'des chats', 'les chat'],
        correctAnswer: 'des chats', difficulty: 1, points: 10, mascot: Mascot.seal),
    Exercise(id: 'grammaire_4', subject: 'french', type: 'qcm',
        question: 'Quelle phrase est complète ? (verbe + sujet)',
        options: ['Le chat.', 'Mange.', 'Le chat mange.', 'Chat mange'],
        correctAnswer: 'Le chat mange.', difficulty: 2, points: 15, mascot: Mascot.seal),
    Exercise(id: 'grammaire_5', subject: 'french', type: 'qcm',
        question: 'Trouve le verbe : "Le garçon court"',
        options: ['Le', 'garçon', 'court', 'Le garçon'],
        correctAnswer: 'court', difficulty: 1, points: 10, mascot: Mascot.seal),
    Exercise(id: 'grammaire_6', subject: 'french', type: 'qcm',
        question: '"un" est un article...',
        options: ['masculin', 'féminin', 'pluriel', 'possessif'],
        correctAnswer: 'masculin', difficulty: 1, points: 10, mascot: Mascot.seal),

    // ============================================================
    // EXERCICES "MOTS 24 BLEU" (Laura Diaz - CE2)
    // Liste de 24 mots de la "liste bleue" pour dictée
    // ============================================================
    // Partie 1 : Mots à choisir (QCM)
    Exercise(
      id: 'mots24_1', subject: 'french', type: 'qcm',
      question: 'Mots 24 bleu - 1/4 : Quel est le bon mot ? "Le ___ a chanté toute la nuit." (oiseau/oiseau)',
      options: ['osEAU', 'oIsEAU', 'oiseau', 'OIZO'],
      correctAnswer: 'oiseau', difficulty: 1, points: 10,
      mascot: Mascot.seal, hint: 'O-I-S-E-A-U'
    ),
    Exercise(
      id: 'mots24_2', subject: 'french', type: 'qcm',
      question: 'Mots 24 bleu - 2/4 : Quel est le bon mot ? "J\'ai ___ à la campagne." (allé/alé)',
      options: ['alé', 'allé', 'allez', 'alée'],
      correctAnswer: 'allé', difficulty: 1, points: 10,
      mascot: Mascot.seal, hint: 'Aller au passé composé : j\'ai allé... NON ! j\'ai ALLÉ'
    ),
    Exercise(
      id: 'mots24_3', subject: 'french', type: 'qcm',
      question: 'Mots 24 bleu - 3/4 : Quel mot prend un accent ? "Le petit ___ vole dans le ciel." (herisson/hérisson)',
      options: ['herisson', 'hérisson', 'hérisson', 'herisson'],
      correctAnswer: 'hérisson', difficulty: 2, points: 15,
      mascot: Mascot.seal, hint: 'HÉRISSON = accent sur le E'
    ),
    Exercise(
      id: 'mots24_4', subject: 'french', type: 'qcm',
      question: 'Mots 24 bleu - 4/4 : "Un ___ de beurre" - Quel mot complète la phrase ? (morceau/morço)',
      options: ['morço', 'morceau', 'morçau', 'morso'],
      correctAnswer: 'morceau', difficulty: 2, points: 15,
      mascot: Mascot.seal, hint: 'MORCEAU = un bout, un fragment'
    ),

    // Partie 2 : Compléter les phrases
    Exercise(
      id: 'mots24_5', subject: 'french', type: 'qcm',
      question: 'Mots 24 bleu - 5/8 : Complète : "La ___ est pleine de étoiles." (nüe/nuit)',
      options: ['nüe', 'nuitt', 'nuit', 'nuitte'],
      correctAnswer: 'nuit', difficulty: 1, points: 10,
      mascot: Mascot.squirrel, hint: 'La NUIT tombe quand le soleil se couche'
    ),
    Exercise(
      id: 'mots24_6', subject: 'french', type: 'qcm',
      question: 'Mots 24 bleu - 6/8 : Complète : "Mon ___ s\'appelle Léo." (chatchat/chien)',
      options: ['chat', 'chatchat', 'chats', 'chatt'],
      correctAnswer: 'chat', difficulty: 1, points: 10,
      mascot: Mascot.squirrel, hint: 'Animal qui fait "miaou"'
    ),
    Exercise(
      id: 'mots24_7', subject: 'french', type: 'qcm',
      question: 'Mots 24 bleu - 7/8 : Complète : "Le ___ est rouge." (soré/soir)',
      options: ['soir', 'soré', 'sware', 'soirr'],
      correctAnswer: 'soir', difficulty: 1, points: 10,
      mascot: Mascot.squirrel, hint: 'Le SOIR, le soleil se couche'
    ),
    Exercise(
      id: 'mots24_8', subject: 'french', type: 'qcm',
      question: 'Mots 24 bleu - 8/8 : Complète : "Le ___ a chanté ce matin." (oijoiseau/oiseau)',
      options: ['oizo', 'oijoiseau', 'oiseau', 'oiseaus'],
      correctAnswer: 'oiseau', difficulty: 1, points: 10,
      mascot: Mascot.squirrel, hint: 'O-I-S-E-A-U'
    ),

    // Partie 3 : Phonique - sons à distinguer
    Exercise(
      id: 'mots24_9', subject: 'french', type: 'qcm',
      question: 'Mots 24 bleu - Phonétique 1 : Quel mot contient le son [wa] ?',
      options: ['loin', 'lion', 'lundi', 'lampe'],
      correctAnswer: 'loin', difficulty: 2, points: 15,
      mascot: Mascot.jellyfish, hint: 'LOIN = L + OIN (son [wa])'
    ),
    Exercise(
      id: 'mots24_10', subject: 'french', type: 'qcm',
      question: 'Mots 24 bleu - Phonétique 2 : Quel mot contient le son [wɑ̃] ?',
      options: ['maison', 'montagne', 'bonbon', 'vingt'],
      correctAnswer: 'vingt', difficulty: 2, points: 15,
      mascot: Mascot.jellyfish, hint: 'VINGT = son [wɑ̃] nasal'
    ),

    // Partie 4 : Orthographe - mots à mémoriser
    Exercise(
      id: 'mots24_11', subject: 'french', type: 'writing',
      question: 'Mots 24 bleu - Dictée 1 : Écris le mot "hiver" (la saison froide)',
      prompt: 'Écris : hiver', correctAnswer: 'hiver', difficulty: 1, points: 15,
      mascot: Mascot.seal, hint: 'H-I-V-E-R'
    ),
    Exercise(
      id: 'mots24_12', subject: 'french', type: 'writing',
      question: 'Mots 24 bleu - Dictée 2 : Écris le mot "forêt" (lieu avec beaucoup d\'arbres)',
      prompt: 'Écris : forêt', correctAnswer: 'forêt', difficulty: 2, points: 20,
      mascot: Mascot.seal, hint: 'F-O-R-Ê-T (accent sur le E)'
    ),
    Exercise(
      id: 'mots24_13', subject: 'french', type: 'writing',
      question: 'Mots 24 bleu - Dictée 3 : Écris le mot "noix" (fruit de l\'arbre)',
      prompt: 'Écris : noix', correctAnswer: 'noix', difficulty: 1, points: 15,
      mascot: Mascot.seal, hint: 'N-O-I-X'
    ),
    Exercise(
      id: 'mots24_14', subject: 'french', type: 'writing',
      question: 'Mots 24 bleu - Dictée 4 : Écris le mot "mur" (dans une maison)',
      prompt: 'Écris : mur', correctAnswer: 'mur', difficulty: 1, points: 15,
      mascot: Mascot.seal, hint: 'M-U-R'
    ),
    Exercise(
      id: 'mots24_15', subject: 'french', type: 'writing',
      question: 'Mots 24 bleu - Dictée 5 : Écris le mot "doux" (pas dur, pas méchant)',
      prompt: 'Écris : doux', correctAnswer: 'doux', difficulty: 1, points: 15,
      mascot: Mascot.seal, hint: 'D-O-U-X'
    ),
    Exercise(
      id: 'mots24_16', subject: 'french', type: 'writing',
      question: 'Mots 24 bleu - Dictée 6 : Écris le mot "travail" (ce qu\'on fait pour gagner sa vie)',
      prompt: 'Écris : travail', correctAnswer: 'travail', difficulty: 2, points: 20,
      mascot: Mascot.seal, hint: 'T-R-A-V-A-I-L'
    ),
    Exercise(
      id: 'mots24_17', subject: 'french', type: 'writing',
      question: 'Mots 24 bleu - Dictée 7 : Écris le mot "écureuil" (petit animal roux avec une grande queue)',
      prompt: 'Écris : écureuil', correctAnswer: 'écureuil', difficulty: 3, points: 25,
      mascot: Mascot.seal, hint: 'É-C-U-R-E-U-I-L (accents!)'
    ),
    Exercise(
      id: 'mots24_18', subject: 'french', type: 'writing',
      question: 'Mots 24 bleu - Dictée 8 : Écris le mot "fenêtre" (pour voir dehors)',
      prompt: 'Écris : fenêtre', correctAnswer: 'fenêtre', difficulty: 2, points: 20,
      mascot: Mascot.seal, hint: 'F-E-N-Ê-T-R-E'
    ),
    Exercise(
      id: 'mots24_19', subject: 'french', type: 'qcm',
      question: 'Mots 24 bleu - 9/12 : Quel est le bon mot ? "Le ___ a des épines." (rose/rôse)',
      options: ['rôse', 'rose', 'roze', 'rôsse'],
      correctAnswer: 'rose', difficulty: 1, points: 10,
      mascot: Mascot.seal, hint: 'La ROSE est une fleur'
    ),
    Exercise(
      id: 'mots24_20', subject: 'french', type: 'qcm',
      question: 'Mots 24 bleu - 10/12 : Quel mot prend un accent ? "Le ___ est jaune." (soleil/soléil)',
      options: ['soléil', 'soleil', 'soli', 'soleil'],
      correctAnswer: 'soleil', difficulty: 1, points: 10,
      mascot: Mascot.seal, hint: 'SOLEIL = grand O, pas d\'accent'
    ),
    Exercise(
      id: 'mots24_21', subject: 'french', type: 'qcm',
      question: 'Mots 24 bleu - 11/12 : Complète : "Le ___ est un fruit rouge." (fraise/fèrèse)',
      options: ['fèrèse', 'fraisse', 'fraise', 'frèse'],
      correctAnswer: 'fraise', difficulty: 1, points: 10,
      mascot: Mascot.squirrel, hint: 'La FRAISE = F-R-A-I-S-E'
    ),
    Exercise(
      id: 'mots24_22', subject: 'french', type: 'qcm',
      question: 'Mots 24 bleu - 12/12 : Quel mot est correct ? "La ___ est noire." (nüit/nuit)',
      options: ['nüe', 'nuitt', 'nuit', 'nuitte'],
      correctAnswer: 'nuit', difficulty: 1, points: 10,
      mascot: Mascot.squirrel, hint: 'La NUIT = N-U-I-T'
    ),

    // Dictée mots supplémentaires (13-18)
    Exercise(
      id: 'mots24_23', subject: 'french', type: 'writing',
      question: 'Mots 24 bleu - Dictée 9 : Écris le mot "plage" (lieu au bord de la mer)',
      prompt: 'Écris : plage', correctAnswer: 'plage', difficulty: 1, points: 15,
      mascot: Mascot.seal, hint: 'P-L-A-G-E'
    ),
    Exercise(
      id: 'mots24_24', subject: 'french', type: 'writing',
      question: 'Mots 24 bleu - Dictée 10 : Écris le mot "village" (petit village)',
      prompt: 'Écris : village', correctAnswer: 'village', difficulty: 1, points: 15,
      mascot: Mascot.seal, hint: 'V-I-L-L-A-G-E'
    ),
    Exercise(
      id: 'mots24_25', subject: 'french', type: 'writing',
      question: 'Mots 24 bleu - Dictée 11 : Écris le mot "nuage" (dans le ciel)',
      prompt: 'Écris : nuage', correctAnswer: 'nuage', difficulty: 1, points: 15,
      mascot: Mascot.seal, hint: 'N-U-A-G-E'
    ),
    Exercise(
      id: 'mots24_26', subject: 'french', type: 'writing',
      question: 'Mots 24 bleu - Dictée 12 : Écris le mot "sorcière" (personnage de conte)',
      prompt: 'Écris : sorcière', correctAnswer: 'sorcière', difficulty: 3, points: 25,
      mascot: Mascot.seal, hint: 'S-O-R-C-I-È-R-E (accent!)'
    ),
    Exercise(
      id: 'mots24_27', subject: 'french', type: 'writing',
      question: 'Mots 24 bleu - Dictée 13 : Écris le mot "sèvre" (rivière en France)',
      prompt: 'Écris : siège', correctAnswer: 'siège', difficulty: 2, points: 20,
      mascot: Mascot.seal, hint: 'S-I-È-G-E'
    ),
    Exercise(
      id: 'mots24_28', subject: 'french', type: 'writing',
      question: 'Mots 24 bleu - Dictée 14 : Écris le mot "cinquante" (5 × 10)',
      prompt: 'Écris : cinquante', correctAnswer: 'cinquante', difficulty: 2, points: 20,
      mascot: Mascot.seal, hint: 'C-I-N-Q-U-A-N-T-E'
    ),

    // Exercices de révision - Phonétique
    Exercise(
      id: 'mots24_29', subject: 'french', type: 'qcm',
      question: 'Mots 24 bleu - Révision : Quel mot contient le son [wa] ?',
      options: ['violon', 'moineau', 'camion', 'cheval'],
      correctAnswer: 'moineau', difficulty: 2, points: 15,
      mascot: Mascot.jellyfish, hint: 'MOINEAU = M + OIN +EAU (son [wa])'
    ),
    Exercise(
      id: 'mots24_30', subject: 'french', type: 'qcm',
      question: 'Mots 24 bleu - Révision : Quel mot est mal orthographié ?',
      options: ['forêt', 'fenêtre', 'ecureuil', 'village'],
      correctAnswer: 'ecureuil', difficulty: 2, points: 15,
      mascot: Mascot.jellyfish, hint: 'ECUREUIL a besoin d\'accents : É-C-U-R-E-U-I-L'
    ),
  ];
}
