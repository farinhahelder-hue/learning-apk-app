import '../models/exercise.dart';

class ScienceExercises {
  static List<Exercise> getByCategory(String category) {
    return _all.where((e) => e.id.startsWith(category)).toList();
  }

  static const List<Exercise> _all = [
    // --- ANIMAUX ---
    Exercise(
        id: 'animaux_1',
        subject: 'science',
        type: 'qcm',
        question: 'Quel animal est le roi de la jungle ?',
        options: ['Léopard', 'Lion', 'Tigre', 'Éléphant'],
        correctAnswer: 'Lion',
        difficulty: 1,
        points: 10),
    Exercise(
        id: 'animaux_2',
        subject: 'science',
        type: 'qcm',
        question: 'Quel animal peut voler ?',
        options: ['Chien', 'Chat', 'Aigle', 'Lapin'],
        correctAnswer: 'Aigle',
        difficulty: 1,
        points: 10),
    Exercise(
        id: 'animaux_3',
        subject: 'science',
        type: 'qcm',
        question: 'Quel animal vit dans la mer et a 8 bras ?',
        options: ['Dauphin', 'Requin', 'Pieuvre', 'Baleine'],
        correctAnswer: 'Pieuvre',
        difficulty: 1,
        points: 10),
    Exercise(
        id: 'animaux_4',
        subject: 'science',
        type: 'qcm',
        question: 'Comment appelle-t-on les animaux qui mangent des plantes ?',
        options: ['Carnivores', 'Herbivores', 'Omnivores', 'Insectivores'],
        correctAnswer: 'Herbivores',
        difficulty: 2,
        points: 15),
    Exercise(
        id: 'animaux_5',
        subject: 'science',
        type: 'qcm',
        question: 'Quel animal hiberne en hiver ?',
        options: ['Lapin', 'Ours', 'Vache', 'Cheval'],
        correctAnswer: 'Ours',
        difficulty: 1,
        points: 10),

    // --- CORPS HUMAIN ---
    Exercise(
        id: 'corps_1',
        subject: 'science',
        type: 'qcm',
        question: 'Combien de doigts avons-nous en tout ?',
        options: ['8', '9', '10', '12'],
        correctAnswer: '10',
        difficulty: 1,
        points: 10),
    Exercise(
        id: 'corps_2',
        subject: 'science',
        type: 'qcm',
        question: 'Quel organe fait battre notre sang ?',
        options: ['Le poumon', 'Le foie', 'Le cœur', 'L’estomac'],
        correctAnswer: 'Le cœur',
        difficulty: 1,
        points: 10),
    Exercise(
        id: 'corps_3',
        subject: 'science',
        type: 'qcm',
        question: 'Avec quoi respire-t-on ?',
        options: [
          'Le cœur',
          'Les poumons',
          'Le nez et la bouche',
          'Les poumons, le nez et la bouche'
        ],
        correctAnswer: 'Les poumons, le nez et la bouche',
        difficulty: 2,
        points: 15),
    Exercise(
        id: 'corps_4',
        subject: 'science',
        type: 'qcm',
        question: 'Combien d’os avons-nous dans le corps (environ) ?',
        options: ['50', '100', '206', '300'],
        correctAnswer: '206',
        difficulty: 3,
        points: 20),
    Exercise(
        id: 'corps_5',
        subject: 'science',
        type: 'qcm',
        question: 'Quel sens utilise-t-on pour écouter de la musique ?',
        options: ['La vue', 'L’odo rat', 'L’ouïe', 'Le toucher'],
        correctAnswer: 'L’ouïe',
        difficulty: 1,
        points: 10),

    // --- NATURE ---
    Exercise(
        id: 'nature_1',
        subject: 'science',
        type: 'qcm',
        question: 'De quoi les plantes ont-elles besoin pour pousser ?',
        options: ['De lait', 'D’eau et de soleil', 'De sucre', 'De vent'],
        correctAnswer: 'D’eau et de soleil',
        difficulty: 1,
        points: 10),
    Exercise(
        id: 'nature_2',
        subject: 'science',
        type: 'qcm',
        question: 'Comment s’appelle la couche d’air autour de la Terre ?',
        options: [
          'La biosphere',
          'L’atmosphère',
          'L’ionosphère',
          'La lithosphère'
        ],
        correctAnswer: 'L’atmosphère',
        difficulty: 2,
        points: 15),
    Exercise(
        id: 'nature_3',
        subject: 'science',
        type: 'qcm',
        question: 'Quel est l’astre qui éclaire la Terre le jour ?',
        options: ['La Lune', 'Mars', 'Le Soleil', 'Vénus'],
        correctAnswer: 'Le Soleil',
        difficulty: 1,
        points: 10),

    // --- METEO ---
    Exercise(
        id: 'meteo_1',
        subject: 'science',
        type: 'qcm',
        question: 'En quelle saison tombent les feuilles des arbres ?',
        options: ['Le printemps', 'L’été', 'L’automne', 'L’hiver'],
        correctAnswer: 'L’automne',
        difficulty: 1,
        points: 10),
    Exercise(
        id: 'meteo_2',
        subject: 'science',
        type: 'qcm',
        question: 'Quelle saison vient après l’hiver ?',
        options: ['L’été', 'L’automne', 'Le printemps', 'La pluie'],
        correctAnswer: 'Le printemps',
        difficulty: 1,
        points: 10),
    Exercise(
        id: 'meteo_3',
        subject: 'science',
        type: 'qcm',
        question:
            'Que voit-on dans le ciel après la pluie quand le soleil revient ?',
        options: ['Des nuages', 'Un arc-en-ciel', 'Des étoiles', 'La Lune'],
        correctAnswer: 'Un arc-en-ciel',
        difficulty: 1,
        points: 10),
    Exercise(
        id: 'meteo_4',
        subject: 'science',
        type: 'qcm',
        question: 'Combien y a-t-il de saisons en France ?',
        options: ['2', '3', '4', '5'],
        correctAnswer: '4',
        difficulty: 1,
        points: 10),

    // --- PLANTES ---
    Exercise(
        id: 'plantes_1',
        subject: 'science',
        type: 'qcm',
        question: 'Comment s’appelle la partie de la plante sous la terre ?',
        options: ['La tige', 'La feuille', 'La racine', 'La fleur'],
        correctAnswer: 'La racine',
        difficulty: 1,
        points: 10),
    Exercise(
        id: 'plantes_2',
        subject: 'science',
        type: 'qcm',
        question: 'Que fait une graine quand on l’arrose et la met au soleil ?',
        options: ['Elle fond', 'Elle germe', 'Elle vole', 'Elle chante'],
        correctAnswer: 'Elle germe',
        difficulty: 1,
        points: 10),
    Exercise(
        id: 'plantes_3',
        subject: 'science',
        type: 'qcm',
        question: 'Quelle partie de la plante capte la lumière du soleil ?',
        options: ['La racine', 'La tige', 'La feuille', 'La graine'],
        correctAnswer: 'La feuille',
        difficulty: 1,
        points: 10),
  ];
}
